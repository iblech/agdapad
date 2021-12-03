{-
  Welcome to Agda! :-)

  If you are new to Agda, you could play The HoTT Game, a tutorial for learning
  Agda and homotopy type theory. You can start the game using the "Help" menu
  and then navigating to a file such as 1FundamentalGroup/Quest0.agda. You
  will also need to open the accompanying guide in your browser:
  https://thehottgameguide.readthedocs.io/

  This editor runs on agdapad.quasicoherent.io. Your Agda code is stored on
  this server and should be available when you revisit the same Agdapad session.
  However, absolutely no guarantees are made. You should make backups by
  downloading (see the clipboard icon in the lower right corner).

  C-c C-l          check file
  C-c C-SPC        check hole
  C-c C-,          display goal and context
  C-c C-c          split cases
  C-c C-r          fill in boilerplate from goal
  C-c C-d          display type of expression
  C-c C-v          evaluate expression (normally this is C-c C-n)
  C-c C-a          try to find proof automatically
  C-z              enable Vi keybindings
  C-x C-+          increase font size
  \bN \alpha \to   math symbols

  "C-c" means "<Ctrl key> + c". In case your browser is intercepting C-c,
  you can also use C-u. For pasting code into the Agdapad, see the clipboard
  icon in the lower right corner.

  In text mode, use <F10> to access the menu bar, not the mouse.
-}

data ℕ : Set where
  zero : ℕ
  succ : ℕ → ℕ

pred : ℕ → ℕ
pred zero     = zero
pred (succ k) = k
