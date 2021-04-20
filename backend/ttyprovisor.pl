#!/usr/bin/env perl

use warnings;
use strict;
use Time::HiRes;

my $ROOT               = "/root/tty";
my $NUM_TOTAL_SESSIONS = 100_000;

mkdir $ROOT;
die unless -d $ROOT;

# Allocate a fresh machine id.
# Guaranteed to be distinct from earlier results.
# Happens to be an integer, but one should only rely on these to be
# alphanumeric, for the timeout code appends suffixes.
sub allocate_machine {
  mkdir "$ROOT/machines";
  -d "$ROOT/machines" or die;

  for my $i (1..$NUM_TOTAL_SESSIONS) {
    return $i if mkdir "$ROOT/machines/$i";
  }
  die;
}

# Spawn a new container; if required, set up the home directory.
# Expects that the machine id (if given) has not yet been used.
# Waits until the container is ready, and only then signals
# its availability by creating an entry under $ROOT/sessions/$session.
sub create_session {
  my ($session, $id) = @_;

  $id = allocate_machine() unless $id;
  warn "* Spawning container $id for session $session...\n";

  system("
    cd /etc/containers
    if mkdir /home/$session 2>/dev/null; then
      cp -Ta --reflink=auto /home/.skeleton /home/$session
      chown 10000 /home/$session
    fi
    < ttyskeleton.conf sed -e 's+/home/\.skeleton+/home/$session+g' > ttybox-$id.conf
    systemctl start container\@ttybox-$id.service
  ") == 0 or die;

  sleep 0.1 until is_living($id);

  mkdir "$ROOT/sessions";
  mkdir "$ROOT/sessions/$session";
  mkdir "$ROOT/sessions/$session/$id" or die;

  warn "  Success.\n";

  return $id;
}

# Return the PID of the leader process of a given container.
# Returns undefined if there is no running container with the given id.
sub get_leader {
  my $id = shift;

  return if $id =~ /off/;

  my $resp = `machinectl show ttybox-$id -p Leader`;
  $resp =~ /^Leader=(\d+)$/ and return $1;
  return;
}

# Assemble the nsenter command for connecting to the VNC session of the given
# machine, adressed by the PID of its leader process.
sub nsenter {
  my $pid = shift;
  die unless $pid;

  return qw< nsenter -a -t >, $pid;
}

# Check whether a machine is running (we can enter its namespace).
sub is_living {
  my $id = shift;

  return if $id =~ /off/;
  return unless my $pid = get_leader($id);
  return $pid if system(nsenter($pid), "true") == 0;
  return;
}

# Terminate idle sessions (not any hot or cold spares, of course).
sub terminate_idle_sessions {
  for my $machine (glob "$ROOT/sessions/*/*") {
    next if $machine =~ /off/;

    my $id = (split "/", $machine)[-1];

    my $pid = get_leader($id);
    unless($pid) {
      warn "* Session $machine is unreachable, marking as offline.\n";
      rename($machine, $machine . "off");
      mkdir "$ROOT/clean";
      mkdir "$ROOT/clean/$id";
      next;
    }

    my $idle = system(nsenter($pid), "perl", "-e", '
      my @sockets = glob "/tmp/tmux-*/*";
      exit 0 if @sockets;
      exit 1;
    ');
    if($idle) {
      warn "* Session $machine is idle, terminating...\n";
      rename($machine, $machine . "off");
      system("machinectl", "poweroff", "ttybox-$id");
      mkdir "$ROOT/clean";
      mkdir "$ROOT/clean/$id";
    }
  }
}

# Clean obsolete machines.
sub clean_obsolete_machines {
  for my $id (glob "$ROOT/clean/*") {
    $id = (split "/", $id)[-1];

    unless(get_leader($id)) {
      warn "* Machine $id has stopped; cleaning its files.\n";
      system("rm", "-rf", "/var/lib/containers/ttybox-$id");
      rmdir "$ROOT/clean/$id";
    }
  }
}

# Acquire a container for a given session name.
# Assumes that $ROOT/sessions/$session already exists, that is that we feel
# responsible for setting up a container for $session.
sub acquire_session {
  my $session = shift;

  warn "* Acquiring a container for $session...\n";

  return create_session($session);
}

unless(-d "/home/.skeleton") {
  warn "* No /home/.skeleton\n";
  exit 1;
}

if(defined $ARGV[0] and $ARGV[0] =~ /^\.maintainance/) {
  terminate_idle_sessions();
  clean_obsolete_machines();
  exit;
}

(defined $ARGV[0] and $ARGV[0] =~ /^(\w*)/) or die "Invalid session name.\n";

my $session = $1;
$session = "lobby" unless length $session;
die unless length $session < 200;

warn "* Got request for session $session.\n";

mkdir "$ROOT/sessions";

my ($machine, $pid);
for(1..2) {
  # Try to create a session, if no other agent is doing it concurrently.
  if(mkdir "$ROOT/sessions/$session") {
    acquire_session($session);
  }
  chdir "$ROOT/sessions/$session" or die;

  # Wait for up to ten seconds for a session to show up.
  my @machines;
  for(my $i = 0; $i < 100; $i++) {
    @machines = sort glob "*";
    last if @machines;
    sleep 0.1;
  }

  $machine = $machines[0];
  if(not defined $machine or (not $pid = is_living($machine) and rmdir $machine)) {
    # No session or no living session showed up; then we'll try our luck setting one up.
    acquire_session($session);
  }
}

die unless $pid;
warn "* Container $machine ($pid) is available for $session; connecting.\n";

# Ensure that home directory is readable for nginx
chmod 0755, "/home/$session";

exec(nsenter($pid), "su", "-c", "@out@/ttystartup.sh $session", "guest");
