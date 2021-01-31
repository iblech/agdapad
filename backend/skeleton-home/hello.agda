{-
  Welcome to Agda! :-)

  This editor runs on agdapad.quasicoherent.io.

  C-c C-l          check file
  C-c C-SPC        check hole
  C-c C-,          display goal and context
  C-c C-c          split cases
  C-c C-r          fill in boilerplate from goal
  C-c C-d          display type of expression
  C-c C-v          evaluate expression (normally this is C-c C-n)
  C-c C-a          try to find proof automatically
  C-z              enable Vi keybindings

  \bN \alpha \to   math symbols

  "C-c" means "<Ctrl key> + c". In case your browser is intercepting C-c,
  you can also use C-u.

  In text mode, use <F10> to access the menu bar, not the mouse.
-}

data ℕ : Set where
  zero : ℕ
  succ : ℕ → ℕ

pred : ℕ → ℕ
pred zero     = zero
pred (succ k) = k
