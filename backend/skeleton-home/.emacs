;;; -*- lexical-binding: t -*-

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code" t)
(add-hook 'scheme-mode-hook #'enable-paredit-mode)
(show-paren-mode t)
(add-to-list 'auto-mode-alist '("\\.s[lp]s\\'" . scheme-mode))
(package-initialize)

(load-file (let ((coding-system-for-read 'utf-8)) (shell-command-to-string "agda --emacs-mode locate")))

(setq-default indent-tabs-mode nil)

(if (not (display-graphic-p))
	(progn (set-terminal-parameter nil 'background-mode 'light)
				 (load-theme 'tsdh-light)
				 (run-with-idle-timer 600 t 'kill-emacs)))

(custom-set-variables
	'(xterm-mouse-mode t)
	'(inhibit-startup-screen t))

(global-set-key (kbd "C-c C-v") 'agda2-compute-normalised-maybe-toplevel)
(global-set-key (kbd "C-c C-p") 'agda2-give)
(add-hook 'agda2-mode-hook
	#'(lambda () (define-key (current-local-map) (kbd "C-o") (lookup-key (current-local-map) (kbd "C-c")))))

(defun start-thehottgame () (interactive) (find-file "~/TheHoTTGame"))
(define-key menu-bar-help-menu [sep9] '("--"))
(define-key menu-bar-help-menu [f] '(menu-item "Learn Agda with The HoTT Game" start-thehottgame))

(run-with-idle-timer 60 t '(lambda () (save-some-buffers t nil)))

(require 'evil)
(setq evil-default-state 'emacs)
(setq evil-want-fine-undo 't)
(evil-mode 1)

(require 'use-proxy)
(url-handler-mode 1)
(use-proxy-mode)
