;;; Add my elisp directory to pathing
(pushnew (expand-file-name "~/Bin/elisp/")
	 load-path :test 'string=)

(byte-recompile-directory (expand-file-name "~/Bin/elisp") 0)

(require 'vc-hooks)
;(require 'project)

;;; Load My Stuff
(load "setup-aliases")
(load "setup-keys")
(load "setup-mail-and-news")
(load "setup-misc")
(load "setup-modes")
(load "bs")

(custom-set-variables
 '(gutter-buffers-tab-visible-p nil)
 '(backup-by-copying-when-linked t)
 '(paren-mode (quote paren) nil (paren))
 '(gutter-visible-p nil)
 '(lazy-shot-mode t nil (lazy-shot))
 '(c-echo-syntactic-information-p t)
 '(browse-url-browser-function (quote browse-url-w3))
 '(inhibit-startup-message t t)
 '(cperl-help t)
 '(bar-cursor (quote (quote other)))
 '(jde-jdk-doc-url "file:///usr/share/doclib/java/index.html")
 '(eldoc-mode t)
 '(shell-multiple-shells t)
 '(toolbar-visible-p nil)
 '(jde-build-use-make t)
 '(time-stamp-format "%02y-%02m-%02d %02H:%02M:%02S %u" t)
 '(line-number-mode t)
 '(calendar-time-display-form (quote (24-hours ":" minutes (if time-zone " (") time-zone (if time-zone ")"))))
 '(cperl-hairy t)
 '(user-mail-address "ryand@amazon.com" t)
 '(query-user-mail-address nil))
(custom-set-faces
 '(default ((t (:foreground "black" :background "white"))) t)
 '(dired-face-symlink ((((class color)) (:italic t)))))
