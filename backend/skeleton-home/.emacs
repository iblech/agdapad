(load-file (let ((coding-system-for-read 'utf-8)) (shell-command-to-string "agda-mode locate")))

(setq-default indent-tabs-mode nil)

(if (not (display-graphic-p))
	(progn (set-terminal-parameter nil 'background-mode 'light)
				 (load-theme 'tsdh-light)
				 (run-with-idle-timer 600 t 'kill-emacs)))

(custom-set-variables
	'(xterm-mouse-mode t)
	'(inhibit-startup-screen t))

(global-set-key (kbd "C-c C-v") 'agda2-compute-normalised-maybe-toplevel)
(add-hook 'agda2-mode-hook
	#'(lambda () (define-key (current-local-map) (kbd "C-u") (lookup-key (current-local-map) (kbd "C-c")))))

(defun start-thehottgame () (interactive) (find-file "~/TheHoTTGame"))
(define-key menu-bar-help-menu [sep9] '("--"))
(define-key menu-bar-help-menu [f] '(menu-item "Learn Agda with The HoTT Game" start-thehottgame))

(require 'evil)
(setq evil-default-state 'emacs)
(setq evil-want-fine-undo 't)
(evil-mode 1)
