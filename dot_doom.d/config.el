;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-spacegrey)
(setq doom-font (font-spec :family "UDEV Gothic NF" :size 14))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(after! doom-modeline
  (setq doom-modeline-persp-name t))

(after! tramp
  ;; connection-local profilesの定義
  (connection-local-set-profile-variables
   'ssh-linux
   '(;;(tramp-direct-async-process . t) ;; lspが動かなくなる
     (dired-listing-switches . "-l --almost-all --human-readable --group-directories-first --no-group")))

  (connection-local-set-profiles '(:application tramp :protocol "ssh" :machine "nucx-arch") 'ssh-linux)
  (connection-local-set-profiles '(:application tramp :protocol "scp" :machine "nucx-arch") 'ssh-linux)

  (setq tramp-verbose 0)
  (setq tramp-chunksize 2000)
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(after! treemacs
  (setq treemacs-width 30
        treemacs-text-scale -0.5)
  (treemacs-git-mode 'deferred)
  (define-key treemacs-mode-map (kbd "C-e") #'+treemacs/toggle)
  (define-key treemacs-mode-map (kbd ".") #'treemacs-root-down)
  (define-key treemacs-mode-map (kbd "DEL") #'treemacs-root-up))

(after! dired
  (remove-hook! 'dired-mode-hook #'+dired-disable-gnu-ls-flags-maybe-h))

(after! dirvish
  (setq dirvish-mode-line-format
        '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-attributes
        '(nerd-icons file-time file-size collapse subtree-state vc-state))
  (setq dirvish-side-attributes '(vc-state file-size nerd-icons collapse))
  (setq dirvish-hide-details t)
  (setq delete-by-moving-to-trash t)
  (setq dirvish-quick-access-entries
        '(("h" "~/"                          "Home")
          ("d" "~/Downloads/"                "Downloads")
          ("n" "/ssh:nucx-arch:"             "nucx-arch")
          ("t" "~/.local/share/Trash/files/" "TrashCan"))))


(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word))
  :config
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  (add-to-list 'copilot-indentation-alist '(org-mode 2))
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(closure-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2)))

(use-package! lsp-tailwindcss :after lsp-mode)
(use-package aider
  :config
  (setq aider-args '("--env-file" "~/.env")))
(use-package xwwp)


;; custom functions
(defun +my/open-in-vterm (name cmd)
  "Open cmd in vterm and close the buffer when process ends"
  (interactive)
  (let ((buffer (get-buffer-create name)))
    (with-current-buffer buffer
      (unless (derived-mode-p 'vterm-mode)
        (vterm-mode))
      (vterm-send-string (format "f(){ %s; exit; }; f" cmd))
      (vterm-send-return))
    (switch-to-buffer buffer)))

(defun +my/open-lazygit-in-vterm ()
  "Open lazygit in vterm"
  (interactive)
  (+my/open-in-vterm "*lazygit*" "lazygit"))

(defun +my/open-lazydocker-in-vterm ()
  "Open lazydocker in vterm"
  (interactive)
  (+my/open-in-vterm "*lazydocker*" "lazydocker"))

(defun +my/dired-bookmark ()
  (interactive)
  (let* ((bookmark (bookmark-completing-read "ディレクトリを選択"))
         (filename (bookmark-get-filename bookmark)))
    (if (file-directory-p filename)
        (dirvish-dwim filename)
      (dirvish-dwim (file-name-directory filename)))))

(defun +my/dired-current-directory ()
  (interactive)
  (dirvish-dwim default-directory))

;; key-maps
(map! :n "C-e" #'+treemacs/toggle)

(map! :n "C-h" #'evil-window-left
      "C-j" #'evil-window-down
      "C-k" #'evil-window-up
      "C-l" #'evil-window-right)

(map! :n [tab] #'evil-next-buffer
      "<backtab>" #'evil-prev-buffer)
(map! :n "<f12>" #'+vterm/toggle)

(map! :leader
      :desc "Aider Transient Menu" "j" #'aider-transient-menu
      :desc "Kill current buffer" "k" #'kill-current-buffer
      :desc "Kill all buffers" "K" #'+evil:kill-all-buffers
      :desc "Toggle comment" :n "/" #'comment-line :v "/" #'comment-region
      :desc "Close window" :n "q" #'evil-window-delete

      :desc "Open lazydocker" "dd" #'+my/open-lazydocker-in-vterm

      "." nil
      (:prefix ("." . "dired")
       :desc "Open dired in current directory" "." #'+my/dired-current-directory
       :desc "Open dired in bookmark" "b" #'+my/dired-bookmark)

      :desc "Split horizontally" "-" #'evil-window-split
      :desc "Split vertically" "|" #'evil-window-vsplit

      ;; 検索関連
      "f" nil
      (:prefix ("f" . "find")
       :desc "Find file" "f" #'find-file
       :desc "Find file other window" "F" #'find-file-other-window
       :desc "Find buffer" "b" #'consult-buffer
       :desc "Find word" "c" #'evil-ex-search-word-forward
       :desc "Find project" "w" #'+default/search-project
       :desc "Find function" "h" #'find-function)

      ;; git関連
      (:prefix ("g" . "git")
       :desc "magit status" "m" #'magit-status
       :desc "lazygit" "g" #'+my/open-lazygit-in-vterm)

      ;; バッファ操作
      "b" nil
      (:prefix ("b" . "buffer")
       :desc "kill current buffer" "c" #'kill-current-buffer
       :desc "kill all buffers" "C" #'+evil:kill-all-buffers
       :desc "next buffer" "n" #'next-buffer
       :desc "previous buffer" "p" #'previous-buffer)

      ;; LSP関連
      "l" nil
      (:prefix ("l" . "lsp action")
       :desc "restart lsp server" "s" #'eglot-reconnect
       :desc "rename" "r" #'eglot-rename
       :desc "format" "f" #'eglot-format-buffer
       :desc "code action" "a" #'eglot-code-actions
       :desc "jump to declaration" "d" #'eglot-find-declaration
       :desc "jump to type definition" "D" #'eglot-find-typeDefinition)

      ;; ターミナル
      "t" nil
      (:prefix ("t" . "terminal")
       :desc "toggle terminal" "t" #'+vterm/toggle
       :desc "here terminal" "T" #'+vterm/here)
      )
