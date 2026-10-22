;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Luca De Clerck"
      user-mail-address "luca@robaws.be")

;; Gmail through notmuch + lieer: each account is a lieer repository that
;; `gmi sync' keeps in sync with Gmail (labels become notmuch tags), and
;; `gmi send' sends through the Gmail API, which also files the message under
;; Sent, so no SMTP setup is needed. New mail is sent from the primary address
;; (notmuch's user.primary_email); replies from the address they were sent to.
(defvar my/mail-accounts
  '(("luca@robaws.be" . "~/.mail/robaws")
    ("lucadeclerck@gmail.com" . "~/.mail/gmail"))
  "Address and lieer repository of each Gmail account.")

(setq +notmuch-sync-backend
      (concat (mapconcat (lambda (account) (concat "gmi sync -C " (cdr account)))
                         my/mail-accounts " && ")
              " && notmuch new"))

;; Gmail sends as the signed-in account, so send through the repository of the
;; account in the From header.
(defun my/mail-use-sender-account-h ()
  (let* ((from (cadr (mail-extract-address-components (message-fetch-field "from"))))
         (repo (or (cdr (assoc-string from my/mail-accounts t))
                   (user-error "No Gmail account for sender %s" from))))
    (setq-local message-sendmail-extra-arguments
                `("send" "--quiet" "-t" "-C" ,(expand-file-name repo)))))

(after! notmuch
  (setq sendmail-program "gmi")
  (add-hook 'message-send-mail-hook #'my/mail-use-sender-account-h)

  ;; Spam and trash are hidden from every other search by notmuch's
  ;; search.exclude_tags; a query that names them shows them.
  (setq notmuch-saved-searches
        '((:name "unread"   :query "tag:inbox tag:unread"     :key "u")
          (:name "inbox"    :query "tag:inbox"                :key "i")
          (:name "work"     :query "tag:inbox path:robaws/**" :key "w")
          (:name "personal" :query "tag:inbox path:gmail/**"  :key "p")
          (:name "flagged"  :query "tag:flagged"              :key "f")
          (:name "sent"     :query "tag:sent"                 :key "s")
          (:name "drafts"   :query "tag:draft"                :key "d")
          (:name "spam"     :query "tag:spam"                 :key "S")
          (:name "trash"    :query "tag:trash"                :key "t"))
        ;; List every search, also while it has no mail.
        notmuch-show-empty-saved-searches t
        ;; The logo image has its own keymap, which steals keys like `i' below
        ;; while the cursor is on it.
        notmuch-show-logo nil)

  ;; On the home screen a search's key opens it directly; elsewhere it's `J'
  ;; and then the key. The home screen is read-only, so the evil editing keys
  ;; these shadow (i, d, p, ...) aren't missed.
  (dolist (search notmuch-saved-searches)
    (let ((query (plist-get search :query)))
      (map! :map notmuch-hello-mode-map
            :n (plist-get search :key) (cmd! (notmuch-search query)))))

  ;; Use the whole window for the home screen, mail lists and threads, like
  ;; Gmail, instead of Doom's sidebar and split popups. `q' goes back.
  (set-popup-rule! "^\\*notmuch" :ignore t)
  (set-popup-rule! "^\\*subject:" :ignore t))

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

;; Keep a running clock across Emacs restarts. Quitting no longer offers to
;; clock out; it saves the running clock, and the next start resumes its open
;; CLOCK: line, so the time Emacs was closed still counts. Doom only persists
;; the clock history.
(after! org-clock
  (setq org-clock-persist t
        org-clock-persist-query-resume nil)
  (setopt org-clock-ask-before-exiting nil)
  ;; The open CLOCK: line on disk is what gets resumed, so save it right away.
  (add-hook! 'org-clock-in-hook
    (with-current-buffer (marker-buffer org-clock-marker)
      (save-buffer))))

;; org-clock loads lazily, so resume a saved clock once Emacs is idle.
(run-with-idle-timer 1 nil (lambda () (require 'org-clock) (org-clock-load)))

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
      (unless (or (memq (char-after open) '(?~ ?=)) (org-at-comment-p))
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
