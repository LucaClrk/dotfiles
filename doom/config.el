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
(setq doom-theme 'doom-one)
;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)
;; Show 0 on the current line instead of its absolute number, like Neovim's
;; `relativenumber' without `number'.
(setq-default display-line-numbers-current-absolute nil)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Stamp CLOSED: [time] when a task is marked DONE, so agenda log mode shows
;; finished tasks next to clocked time. State-change notes go into :LOGBOOK:.
;; Hide emphasis markers (*bold*, +strike+, ...) and show only the styled text.
(after! org
  (setq org-log-done 'time
        org-log-into-drawer t
        org-hide-emphasis-markers t))

;; Show emphasis markers while in insert state so they're easy to edit, and
;; hide them again on leaving it.
(defun my/org-set-emphasis-markers-visible (visible)
  (setq-local org-hide-emphasis-markers (not visible))
  (font-lock-flush))

(add-hook! 'org-mode-hook
  (add-hook 'evil-insert-state-entry-hook
            (lambda () (my/org-set-emphasis-markers-visible t)) nil t)
  (add-hook 'evil-insert-state-exit-hook
            (lambda () (my/org-set-emphasis-markers-visible nil)) nil t))

;; Org fontifies a single level of emphasis, so the inner markers of nested
;; markup like _*text*_ are never styled or hidden. After each match, fontify
;; the emphasis contents too (recursively), then continue past it.
(defadvice! my/org-fontify-nested-emphasis-a (fn limit)
  :around #'org-do-emphasis-faces
  (when (funcall fn limit)
    (let* ((open (1- (point)))
           (end (or (next-single-property-change open 'org-emphasis) (point-max))))
      (unless (memq (char-after open) '(?~ ?=))
        (save-restriction
          (narrow-to-region (1+ open) (1- end))
          (goto-char (point-min))
          (while (org-do-emphasis-faces (point-max)))))
      (goto-char end))
    t))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
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

;; Resize frames by pixel instead of by character cell, so tiling window
;; managers (AeroSpace, Hyprland) can size the frame exactly.
(setq frame-resize-pixelwise t)

;; "jj" as escape in insert mode, same as in Neovim. Other states are excluded
;; so "jj" still moves down two lines in normal and visual mode.
(after! evil-escape
  (setq evil-escape-key-sequence "jj"
        ;; Repeating the same key is slower than alternating keys, so the
        ;; default 0.1s window often misses the second "j".
        evil-escape-delay 0.3
        evil-escape-excluded-states '(normal visual multiedit emacs motion)))
