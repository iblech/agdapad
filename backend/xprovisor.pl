#!/usr/bin/env perl

use warnings;
use strict;
use Time::HiRes;

my $ROOT               = "/root/x";
my $NUM_HOT_SPARES     = 3;
my $NUM_COLD_SPARES    = 1;
my $NUM_TOTAL_SESSIONS = 100_000;
my $MAX_IDLE_TIME      = 600 * 1000;  # for the time being

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
    < xskeleton.conf sed -e 's+/home/\.skeleton+/home/$session+g' -e 's+__SESSION_NAME__+$session+g' > xbox-$id.conf
    systemctl start container\@xbox-$id.service
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

  my $resp = `machinectl show xbox-$id -p Leader`;
  $resp =~ /^Leader=(\d+)$/ and return $1;
  return;
}

# Assemble the netcat command for connecting to the VNC session of the given
# machine, adressed by the PID of its leader process.
sub netcat {
  my $pid = shift;
  die unless $pid;

  return qw< nsenter -a -t >, $pid, qw< nc localhost 5901 >;
}

# Check whether a VNC connection can be established to the given machine.
sub is_living {
  my $id = shift;

  return if $id =~ /off/;
  return unless my $pid = get_leader($id);
  return $pid if system("@{[ netcat($pid) ]} -z &>/dev/null") == 0;
  return;
}

# Spawn sufficiently many hot spares.
sub setup_hot_spares {
  until((() = glob "$ROOT/sessions/.hot-spare-*/*") >= $NUM_HOT_SPARES) {
    my $id = allocate_machine();
    system("rm", "-rf", "/home/.hot-spare-$id") == 0 or die;
    create_session(".hot-spare-$id", $id);
  }
}

# Spawn sufficiently many cold spares.
sub setup_cold_spares {
  until((() = glob "$ROOT/sessions/.cold-spare-*/*") >= $NUM_COLD_SPARES) {
    my $id = allocate_machine();
    system("
      set -e
      umount /home/.cold-spare-$id || true
      mkdir -p /home/.cold-spare-$id
      mount -t tmpfs none /home/.cold-spare-$id
      mkfifo /home/.cold-spare-$id/.wait
    ") == 0 or die;
    create_session(".cold-spare-$id", $id);
  }
}

# Terminate idle sessions (not any hot or cold spares, of course).
sub terminate_idle_sessions {
  # the glob() won't return sessions of hot or cold spares, as these begin with a dot
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

    my $idletime = `nsenter -a -t $pid /usr/bin/env DISPLAY=:1 XAUTHORITY=/home/guest/.Xauthority xprintidle-ng`;
    if(not $idletime =~ /^\d+$/ or $idletime > $MAX_IDLE_TIME) {
      warn "* Session $machine is idle, terminating...\n";
      rename($machine, $machine . "off");
      system("machinectl", "poweroff", "xbox-$id");
      mkdir "$ROOT/clean";
      mkdir "$ROOT/clean/$id";
    }
  }
}

# Reset the idletime of a session.
# Used when employing a hot or cold spare. For the most time, spares sit
# unused and accumulate idletime. They are not killed because
# terminate_idle_sessions purposely skips over spares. However, as soon as
# they are employed, the idletime killer might kill them.
sub reset_idletime {
  my $id = shift;

  my $pid = get_leader($id) or return;
  return system(qw<
    nsenter -a -t>, $pid, qw<
    /usr/bin/env DISPLAY=:1 XAUTHORITY=/home/guest/.Xauthority
    xdotool mousemove 0 0 mousemove restore
  >) == 0;
}

# Clean obsolete machines
sub clean_obsolete_machines {
  for my $id (glob "$ROOT/clean/*") {
    $id = (split "/", $id)[-1];

    unless(get_leader($id)) {
      warn "* Machine $id has stopped; cleaning its files.\n";
      system("rm", "-rf", "/var/lib/containers/xbox-$id");
      rmdir "$ROOT/clean/$id";
    }
  }
}

# Acquire a container for a given session name.
# Repurposes one of the available hot spares if possible; else spawns a new
# container.
# Assumes that $ROOT/sessions/$session already exists, that is that we feel
# responsible for setting up a container for $session.
sub acquire_session {
  my $session = shift;

  warn "* Acquiring a container for $session...\n";

  # Carry out one attempt of acquiring a hot spare.
  if(not -d "/home/$session" and my $hot_spare = (glob "$ROOT/sessions/.hot-spare-*/*")[0]) {
    my $id = (split "/", $hot_spare)[-1];
    warn "  Trying to use hot spare $id...\n";

    # The following rename can fail for two reasons.
    # (1) The hot spare might have vanished in the meantime.
    # (2) The home directory might have come into existence.
    if(rename("/home/.hot-spare-$id", "/home/$session")) {
      warn "  Success, using hot spare $id.\n";
      reset_idletime($id);
      rename($hot_spare, "$ROOT/sessions/$session/$id") or die;
      rmdir("$ROOT/sessions/.hot-spare-$id");
      return $id;
    } else {
      warn "  Failure, not using a hot spare.\n";
    }
  }

  # Carry out one attempt of acquiring a cold spare.
  if(-d "/home/$session" and my $cold_spare = (glob "$ROOT/sessions/.cold-spare-*/*")[0]) {
    my $id = (split "/", $cold_spare)[-1];
    warn "  Trying to use cold spare $id...\n";

    # The following rename can fail for one reason:
    # (1) The cold spare might have vanished in the meantime
    #     (for instance purposed for a different session).
    if(rename($cold_spare, "$ROOT/sessions/$session/$id")) {
      warn "  Success, using cold spare $id.\n";
      rmdir("$ROOT/sessions/.cold-spare-$id") or die;
      reset_idletime($id);
      open my $fh, ">", "/home/.cold-spare-$id/.wait" or die;
      system("mount --bind /home/$session /home/.cold-spare-$id") == 0 or die;
      print $fh "now\n" or die;
      close $fh or die;
      return $id;
    } else {
      warn "  Failure, not using a cold spare.\n";
    }
  }

  return create_session($session);
}

unless(-d "/home/.skeleton") {
  warn "* No /home/.skeleton\n";
  exit 1;
}

if($ENV{WEBSOCAT_URI} =~ /\?maintainance/) {
  setup_hot_spares();
  setup_cold_spares();
  terminate_idle_sessions();
  clean_obsolete_machines();
  exit;
}

$ENV{WEBSOCAT_URI} =~ /^\/__vnc\/(\w*)/ or die;

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

exec(netcat($pid));
