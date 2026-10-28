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
;; Sent, so no SMTP setup is needed. New mail is sent from the first account;
;; replies from the address they were sent to.
;; Only accounts whose repository exists on this laptop are used, so the
;; personal laptop, which has no robaws repository, syncs and sends just gmail.
(defvar my/mail-accounts
  (seq-filter (lambda (account) (file-directory-p (cdr account)))
              '(("luca@robaws.be" . "~/.mail/robaws")
                ("lucadeclerck@gmail.com" . "~/.mail/gmail")))
  "Address and lieer repository of each Gmail account on this laptop.")

(setq +notmuch-sync-backend
      (concat (mapconcat (lambda (account) (concat "gmi sync -C " (cdr account)))
                         my/mail-accounts " && ")
              " && notmuch new"))

;; Doom syncs only on `+notmuch/update', so also sync in the background shortly
;; after startup and then every 5 minutes, refreshing open mail buffers. A sync
;; still running is left alone; its output is in the " *mail sync*" buffer.
(defvar my/mail-sync-process nil)

(defun my/mail-auto-sync ()
  (unless (process-live-p my/mail-sync-process)
    (setq my/mail-sync-process
          (start-process-shell-command "mail-sync" " *mail sync*"
                                       +notmuch-sync-backend))
    (set-process-sentinel
     my/mail-sync-process
     (lambda (process _event)
       (unless (process-live-p process)
         (cond ((/= (process-exit-status process) 0)
                (message "Mail sync failed, see the \" *mail sync*\" buffer"))
               ((featurep 'notmuch)
                (notmuch-refresh-all-buffers))))))))

(run-with-idle-timer 10 nil #'my/mail-auto-sync)
(run-with-timer (* 5 60) (* 5 60) #'my/mail-auto-sync)

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

  ;; notmuch starts new mail and forwards from user.primary_email (robaws),
  ;; which the personal laptop doesn't have, so start them from the first
  ;; account on this laptop instead. Replies already come with a From.
  (defadvice! my/mail-default-from-a (args)
    :filter-args #'notmuch-mua-mail
    (let ((headers (nth 2 args)))
      (if (or (null my/mail-accounts) (assoc-string "from" headers t))
          args
        `(,(nth 0 args) ,(nth 1 args)
          ((From . ,(message-make-from (notmuch-user-name) (caar my/mail-accounts)))
           ,@headers)
          ,@(nthcdr 3 args)))))

  ;; Spam and trash are hidden from every other search by notmuch's
  ;; search.exclude_tags; a query that names them shows them.
  (setq notmuch-saved-searches
        '((:name "unread"   :query "tag:inbox tag:unread path:robaws/**" :key "u")
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
  ;; `d' toggles this tag. Its default, "deleted", would only become a new
  ;; Gmail label; lieer maps "trash" to Gmail's Trash.
  (setq evil-collection-notmuch-delete-tag "trash")

  (dolist (search notmuch-saved-searches)
    (let ((query (plist-get search :query)))
      (map! :map notmuch-hello-mode-map
            :n (plist-get search :key) (cmd! (notmuch-search query)))))

  ;; Use the whole window for the home screen, mail lists and threads, like
  ;; Gmail, instead of Doom's sidebar and split popups. `q' goes back.
  (set-popup-rule! "^\\*notmuch" :ignore t)
  (set-popup-rule! "^\\*subject:" :ignore t))

;; Google Calendar through org-gcal: `M-x org-gcal-sync' syncs the calendar
;; both ways with ~/org/calendar.org, so its events show in the agenda and in
;; `=calendar' (SPC o c). New events are posted with `org-gcal-post-at-point'.
;; The OAuth token is kept in oauth2-auto's GPG-encrypted plstore.
;;
;; org-gcal takes a single OAuth client, and the robaws.be one is an Internal
;; Workspace app that only signs in robaws.be accounts, so each laptop syncs the
;; calendar of one account: the one whose Google Cloud "Desktop app" client JSON
;; is saved, outside this repository, as ~/.config/org-gcal/ACCOUNT.json (e.g.
;; luca@robaws.be.json on the work laptop, lucadeclerck@gmail.com.json on the
;; personal one).
(defvar my/gcal-client-dir "~/.config/org-gcal/"
  "Directory with this laptop's Google OAuth client, named ACCOUNT.json.")

;; org-gcal reads the client when it loads, so set it beforehand.
(when-let* ((file (car (file-expand-wildcards
                        (concat my/gcal-client-dir "*@*.json")))))
  (let ((client (with-temp-buffer
                  (insert-file-contents file)
                  (gethash "installed" (json-parse-buffer)))))
    (setq org-gcal-client-id (gethash "client_id" client)
          org-gcal-client-secret (gethash "client_secret" client)
          org-gcal-fetch-file-alist
          `((,(file-name-base file) . "~/org/calendar.org")))))

;; Encrypt the plstore to this laptop's passphrase-less "emacs-plstore" GPG key,
;; so syncing never asks for a passphrase. Create it once per laptop with
;;   gpg --batch --passphrase '' --quick-gen-key emacs-plstore default default never
;; Without that key plstore falls back to a passphrase, asked once per session.
(setq plstore-encrypt-to "emacs-plstore"
      plstore-cache-passphrase-for-symmetric-encryption t
      ;; Ask for it in the minibuffer. Doom sets this only once epa loads, and
      ;; plstore uses epg without it, so gpg fell back to its terminal pinentry,
      ;; which can't run in GUI Emacs, and the token was never saved.
      epg-pinentry-mode 'loopback)

(map! :leader :desc "Calendar" "o c" #'=calendar)

;; Sync shortly after Emacs starts (which asks for the plstore passphrase) and
;; then every 15 minutes, silently. It starts only once a first manual
;; `org-gcal-sync' has logged in, so a timer never opens the browser login.
(defun my/gcal-auto-sync ()
  (when (bound-and-true-p org-gcal-client-id)
    (require 'org-gcal)
    (when (and (file-exists-p oauth2-auto-plstore)
               (not org-gcal--sync-lock))
      (org-gcal-sync nil t))))

(run-with-idle-timer 5 nil #'my/gcal-auto-sync)
(run-with-timer (* 15 60) (* 15 60) #'my/gcal-auto-sync)

;; org-gcal edits the calendar files but leaves them unsaved, so save them once
;; a sync has stopped updating events for a moment.
(defvar my/gcal-unsaved-buffers nil)
(defvar my/gcal-save-timer nil)

(defun my/gcal-save-buffers ()
  (dolist (buffer my/gcal-unsaved-buffers)
    (when (buffer-live-p buffer)
      (with-current-buffer buffer (save-buffer))))
  (setq my/gcal-unsaved-buffers nil))

(defun my/gcal-save-soon-h (&rest _)
  (cl-pushnew (current-buffer) my/gcal-unsaved-buffers)
  (when (timerp my/gcal-save-timer) (cancel-timer my/gcal-save-timer))
  (setq my/gcal-save-timer (run-with-timer 2 nil #'my/gcal-save-buffers)))

(add-hook 'org-gcal-after-update-entry-functions #'my/gcal-save-soon-h)

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

;; Markdown export borrows HTML's smart quotes and special strings, so quotes,
;; "--" and "..." became &ldquo;, &#x2013; and &#x2026;, which only HTML-aware
;; viewers show as characters. Write the UTF-8 characters instead, as the
;; ASCII exporter does with its utf-8 charset.
(defadvice! my/org-md-plain-text-utf-8-a (fn text info)
  :around #'org-md-plain-text
  (when (plist-get info :with-smart-quotes)
    (setq text (org-export-activate-smart-quotes text :utf-8 info)))
  (when (plist-get info :with-special-strings)
    (setq text (replace-regexp-in-string "\\\\-" "" text)
          text (replace-regexp-in-string "---" "—" text)
          text (replace-regexp-in-string "--" "–" text)
          text (replace-regexp-in-string "\\.\\.\\." "…" text)))
  (funcall fn text (org-combine-plists
                    info '(:with-smart-quotes nil :with-special-strings nil))))


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

;; LaTeXML in the LaTeX compile menu (C-c C-c): writes FILE.html with
;; LaTeXML.css and a class stylesheet (ltx-article.css, ...) next to the .tex
;; file, with math as MathML.
(after! tex
  (add-to-list 'TeX-command-list
               '("LaTeXML" "latexmlc --dest=%s.html %t" TeX-run-command nil
                 (latex-mode LaTeX-mode) :help "Convert to HTML and CSS with LaTeXML")))

;; Every git repository in these folders shows up in `SPC p p', found the first
;; time it runs in a session. (DIR . 0) is a project itself. A folder missing
;; on a laptop is skipped, so this lists both laptops' folders: ~/Projects on
;; the personal one, ~/Documents/Projects and ~/IdeaProjects on the work one.
(setq projectile-project-search-path
      '("~/Projects/" "~/Documents/Projects/" "~/IdeaProjects/"
        ("~/dotfiles/" . 0)))

;; Astro: .astro files in web-mode, with the Astro language server through
;; Eglot. It needs a TypeScript install, so it uses the global one from
;; `npm i -g @astrojs/language-server typescript'.
(define-derived-mode astro-mode web-mode "Astro")
(add-to-list 'auto-mode-alist '("\\.astro\\'" . astro-mode))
(after! web-mode
  (add-to-list 'web-mode-engines-alist '("astro" . "\\.astro\\'")))
(add-hook 'astro-mode-hook #'eglot-ensure)
(after! eglot
  (add-to-list 'eglot-server-programs
               `(astro-mode "astro-ls" "--stdio"
                 :initializationOptions
                 (:typescript
                  (:tsdk ,(expand-file-name
                           "typescript/lib"
                           (string-trim (shell-command-to-string "npm root -g"))))))))
