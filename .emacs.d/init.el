;;; init.el --- an Emacs configuration for JavaScript programming
;; Copyright (C) 2016 Zak B. Elep, <zakame@zakame.net>

;;; Commentary:

;; This is a minimal(?  Really now...) Emacs configuration for my talk
;; on Emacs + JavaScript :) Adapted from my own personal `init.el'.

;; Usage

;; Put this file inside your `user-emacs-directory' (typically
;; `~/.emacs.d').

;; TODO (Left for the reader ;)

;; - Switch from ido to Ivy or Helm for more consistent completion
;; - Add a few more conveniences (multiple-cursors, hungry-delete)

;;; Code:

;;; General setup

;; High GC threshold for Emacs
(setq gc-cons-threshold 20000000)

;; Enable mouse wheel support
(if (fboundp 'mwheel-install) (mwheel-install))

;; Disable menu, tool, and scroll bars
(mapc (lambda (mode)
        (when (fboundp mode) (funcall mode -1)))
      '(menu-bar-mode tool-bar-mode scroll-bar-mode))

(blink-cursor-mode -1)                  ; Stop blinking the cursor/point
(setq load-prefer-newer t)              ; Always load newer elisp
(setq enable-local-eval t)              ; Tell Emacs to obey variables
                                        ; set by the files it reads
(setq visible-bell t)                   ; Blink the screen instead of
                                        ; beeping
(set-language-environment "UTF-8")      ; Set my default language
                                        ; environment
(windmove-default-keybindings)          ; Enable windmove
(winner-mode 1)                         ; Enable winner-mode
(auto-image-file-mode 1)                ; Show images as images, not as
                                        ; semi-random bits
(setq inhibit-startup-message t)        ; No splash screen (well...)
(if (fboundp 'fringe-mode) (fringe-mode 0)) ; no fringes too, please!

;; package.el
(require 'package)
(nconc package-archives
       '(("melpa" . "https://melpa.org/packages/")))
(setq package-enable-at-startup nil)
(package-initialize)

;; use-package
(unless (package-installed-p 'use-package)
  (progn
    (package-refresh-contents)
    (package-install 'use-package)))
(eval-when-compile
  (eval-after-load 'advice
    `(setq ad-redefinition-action 'accept))
  (require 'use-package))
(require 'diminish)
(require 'bind-key)
(bind-key "C-x c @" 'list-packages)

;; quelpa helper for use-package
(use-package quelpa-use-package
  :ensure t
  :config
  (setq quelpa-checkout-melpa-p nil))

;;; Editing/Programming

;; I want backups in their own directory, and even backup while in VC
(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      vc-make-backup-files t)

;; Disable backups for TRAMP files, though
(add-to-list 'backup-directory-alist
             (cons tramp-file-name-regexp nil))

(global-font-lock-mode 1)
(setq font-lock-support-mode 'jit-lock-mode) ; Just In Time font-locking
(setq font-lock-maximum-decoration t)

(line-number-mode 1)                    ; Show line number ...
(column-number-mode 1)                  ; ... and column number on
                                        ; modeline
(show-paren-mode 1)                     ; Automatically makes the
                                        ; matching parenthesis stand out
                                        ; in color
(setq show-paren-style 'expression)     ; Make the entire matched expression
                                        ; stand out
(mouse-avoidance-mode 'cat-and-mouse)   ; Move the mouse pointer out
                                        ; of my way when I type
(temp-buffer-resize-mode 1)             ; Temporary windows should not
                                        ; get into our way
(auto-compression-mode 1)               ; Load Auto-(De)Compression Mode

(setq search-whitespace-regexp ".*?")   ; match anything (non-greedy)

(setq auto-save-timeout 15              ; Auto-save after 15 sec of
                                        ; idleness
      require-final-newline t           ; Always add a newline to file's end
      search-highlight t                ; Highlight search strings
      compilation-window-height 10      ; Set a small window for
                                        ; compiles
      compilation-scroll-output
      'first-error                      ; Follow compilation scrolling
                                        ; until the first error
      compilation-ask-about-save nil)

;; Use imenu to browse use-package blocks
(defun zakame/imenu-use-package ()
  "Extract use-package lines to be used as anchors in imenu."
  (add-to-list 'imenu-generic-expression
               '(nil
                 "\\(^\\s-*(use-package +\\)\\(\\_<.+\\_>\\)" 2)))
(add-hook 'emacs-lisp-mode-hook #'zakame/imenu-use-package)

;; ido-mode
(use-package ido
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (setq ido-use-virtual-buffers t
        ido-use-filename-at-point 'guess
        ido-create-new-buffer 'always
        ido-ignore-extensions t))

;; ido-ubiquitous
(use-package ido-ubiquitous
  :ensure t
  :config
  (ido-ubiquitous-mode 1))

;; flx-ido
(use-package flx-ido
  :ensure t
  :config
  (flx-ido-mode 1)
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil))

;; ido-vertical-mode
(use-package ido-vertical-mode
  :ensure t
  :config
  (ido-vertical-mode 1)
  (setq ido-vertical-define-keys 'C-n-C-p-up-down-left-right
        ido-vertical-show-count t))

;; idomenu
(use-package idomenu
  :ensure t
  :bind (("C-x c i" . idomenu)))

;; ido-other-window
(use-package ido-other-window
  :quelpa (ido-other-window :fetcher github :repo "zakame/ido-other-window"))

;; smex
(use-package smex
  :ensure t
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands))
  :config
  (smex-initialize))

;; Save point position between editing sessions
(use-package saveplace
  :config
  (unless (version< emacs-version "25")
    (save-place-mode 1))
  (setq-default save-place t
                save-place-file (expand-file-name ".places"
                                                  user-emacs-directory)))

;; Enable tail mode for logs
(use-package autorevert
  :diminish auto-revert-mode
  :mode (("\\.log\\'" . auto-revert-tail-mode)))

;; Ace Jump mode
(use-package ace-jump-mode
  :ensure t
  :bind (("C-c SPC" . ace-jump-mode)
         ("C-c C-0" . ace-jump-mode)))

;; expand-region
(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)))

;; Auto refresh buffers and dired, and be quiet about it
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

;; dired-x
(add-hook 'dired-load-hook
          '(lambda ()
             (load "dired-x")))

;; set human-readable sizes in dired
(setq dired-listing-switches "-alh")

;; recentf tweaks
(use-package recentf
  :bind (("C-c f" . zakame/ido-recentf-open))
  :config
  (defun zakame/ido-recentf-open ()
    "Use `ido-completing-read' to find a recent file."
    (interactive)
    (find-file (ido-completing-read "Find recent file: " recentf-list nil t)))
  (recentf-mode)
  (setq recentf-exclude '("TAGS" ".*-autoloads\\.el\\'")))

;; Ansi-Term tweaks
(use-package term
  :bind (("C-c t" . ansi-term))
  :config
  (defadvice term-sentinel (around ansi-term-kill-buffer (proc msg))
    (if (memq (process-status proc) '(signal exit))
        (let ((buffer (process-buffer proc)))
          ad-do-it
          (kill-buffer buffer))
      ad-do-it))
  (ad-activate 'term-sentinel)
  (defadvice ansi-term (before ansi-term-force-shell)
    (interactive (list (getenv "SHELL"))))
  (ad-activate 'ansi-term)
  (add-hook 'term-mode-hook 'goto-address-mode)
  (add-hook 'term-exec-hook
            '(lambda ()
               (set-buffer-process-coding-system 'utf-8-unix 'utf-8-unix))))

;; Eshell tweaks
(use-package eshell
  :bind (("C-c e" . eshell))
  :config
  (defun zakame/eshell-rename-buffer-before-command ()
    (let* ((last-input
            (buffer-substring eshell-last-input-start eshell-last-input-end)))
      (rename-buffer
       (format "*eshell[%s]$ %s...*" default-directory last-input) t)))
  (defun zakame/eshell-rename-buffer-after-command ()
    (rename-buffer
     (format "*eshell[%s]$ %s*" default-directory
             (eshell-previous-input-string 0)) t))
  (add-hook 'eshell-pre-command-hook
            'zakame/eshell-rename-buffer-before-command)
  (add-hook 'eshell-post-command-hook
            'zakame/eshell-rename-buffer-after-command)
  (use-package em-smart)
  (setq eshell-where-to-jump 'begin
        eshell-review-quick-commands nil
        eshell-smart-space-goes-to-end t)
  (add-hook 'eshell-mode-hook
            '(lambda ()
               (eshell-smart-initialize))))

;; make window splits much smarter especially when on widescreen
(defun zakame/split-window-prefer-side-by-side (window)
  "Split WINDOW, preferably side by side."
  (let ((split-height-threshold (and (< (window-width window)
                                        split-width-threshold)
                                     split-height-threshold)))
    (split-window-sensibly window)))
(setq split-window-preferred-function
      #'zakame/split-window-prefer-side-by-side)

;; undo-tree
(use-package undo-tree
  :diminish undo-tree-mode
  :ensure t
  :config
  (global-undo-tree-mode 1))

;; hippie-exp
(use-package hippie-exp
  :config
  (global-set-key (kbd "M-/") 'hippie-expand)
  (setq hippie-expand-try-functions-list
        '(
          try-expand-dabbrev
          try-expand-dabbrev-all-buffers
          try-complete-file-name-partially
          try-complete-file-name
          try-expand-all-abbrevs
          try-expand-list
          try-expand-line
          try-complete-lisp-symbol-partially
          try-complete-lisp-symbol)))

;; diff-hl
(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode)
  (setq diff-hl-side 'left)
  (diff-hl-margin-mode)
  (unless (version<= emacs-version "24.4")
    (diff-hl-flydiff-mode))
  (eval-after-load "magit"
    '(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)))

;; aggressive indent
(use-package aggressive-indent
  :diminish aggressive-indent-mode
  :ensure t
  :config
  (mapc
   (lambda (mode)
     (add-to-list 'aggressive-indent-excluded-modes mode))
   '(jade-mode web-mode html-mode))
  (global-aggressive-indent-mode 1))

;; which-key-mode
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

;; adaptive wrap for long lines
(use-package adaptive-wrap
  :diminish visual-line-mode
  :ensure t
  :config
  (add-hook 'text-mode-hook #'visual-line-mode)
  (add-hook 'text-mode-hook #'adaptive-wrap-prefix-mode))

;; pos-tip
(use-package pos-tip
  :ensure t)

;; use the_silver_searcher when available
(use-package ag
  :ensure t
  :if (executable-find "ag"))

;; Enable ElDoc for automatic documentation of elisp functions
(dolist (hook
         '(emacs-lisp-mode-hook lisp-interaction-mode-hook ielm-mode-hook))
  (add-hook hook #'eldoc-mode))

;; Don't mention ElDoc mode in modeline
(eval-after-load "eldoc"
  '(diminish 'eldoc-mode))

;; Always indent using spaces, no tabs
(setq-default indent-tabs-mode nil)

;; htmlize
(use-package htmlize
  :defer t
  :ensure t)

;; swiper
(use-package swiper
  :ensure t
  :bind ("C-s" . swiper))


;;; JavaScript and other modes for this talk is all in the slides!

(with-temp-buffer
  (insert-file-contents "~/README.org")
  (goto-char (point-min))
  (while (not (eobp))
    (forward-line 1)
    (cond
     ;; Report headers
     ((looking-at
       (format "\\*\\{2,%s\\} +.*$" 2))
      (message "%s" (match-string 0)))
     ;; Evaluate elisp configuration src blocks
     ((looking-at "^#\\+BEGIN_SRC +emacs-lisp *$")
      (let ((l (match-end 0)))
        (search-forward "\n#+END_SRC")
        (eval-region l (match-beginning 0)))))))


;;; Misc

;; Zenburn theme (for cool coding for the eyes)
(use-package zenburn-theme
  :ensure t
  :config
  (add-hook 'after-make-frame-functions
            '(lambda (frame)
               (with-selected-frame frame
                 (load-theme 'zenburn t)))))

;; Emojis! :+1:
(use-package emojify
  :ensure t
  :config
  (unless (file-exists-p emojify-image-dir)
    (emojify-download-emoji emojify-emoji-set))
  (add-hook 'after-init-hook #'global-emojify-mode))

;; Nyan-mode :3
(use-package nyan-mode
  :ensure t
  :config
  (setq nyan-bar-length 16)
  (nyan-mode 1))

;; zone out with Nyan cat when idle after 2 minutes :3
(use-package zone-nyan
  :ensure t
  :preface
  (use-package zone)
  :config
  (setq zone-programs [zone-nyan])
  (zone-when-idle 120))

;; Set up a cozy fireplace
(use-package fireplace
  :ensure t
  :config
  (add-hook 'after-init-hook
            '(lambda ()
               (unless (daemonp)
                 (delete-other-windows)
                 (fireplace t)))))


(provide 'init)

;;; init.el ends here
