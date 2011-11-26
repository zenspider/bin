(require 'erc)
(require 'erc-track)
(require 'erc-match)
(require 'easymenu)

;;;###autoload
(defun my-irc ()
  (interactive)
  (erc-select :server "localhost"
              :port 16667
              :nick "zenspider"
              :password (read-file-to-string "~/.erc_password")))

;;;###autoload
(defun rwd-irc-atti ()
  (interactive)
  (erc-select :server "irc.corp.atti.com" :port 6667 :nick "rdavis")
  (erc-join-channel "#appservices"))

;;;###autoload
(defun rwd-irc-direct ()
  (interactive)
  (erc-select :server "irc.freenode.net" :port 6667 :nick "zenspider"))

;; erc variables
(setq erc-kill-buffer-on-part        t
      erc-kill-queries-on-quit       t
      erc-kill-server-buffer-on-quit t
      erc-input-line-position        -1
      erc-server-auto-reconnect      nil
      erc-mode-line-format           "%t %a")

;; erc-match variables
(setq erc-keywords '("autotest\\|zentest\\|inline\\|parse_?tree")
      erc-pals     '("^drbrain$" "^evan$"))

;; erc-track variables
(setq erc-track-exclude-types         '("JOIN" "NICK" "PART" "QUIT")
      erc-track-minor-mode            t
      erc-track-mode                  t
      erc-track-position-in-mode-line 'after-modes)

(defun erc-cmd-BAN (nick)
  (let* ((chan (erc-default-target))
         (who (erc-get-server-user nick))
         (host (erc-server-user-host who))
         (user (erc-server-user-login who)))
    (erc-server-send (format "MODE %s +b *!%s@%s" chan user host))))

(defun erc-cmd-UNBAN (nick)
  (let* ((chan (erc-default-target)))
    (erc-server-send (format "MODE %s -b %s" chan nick))))

(defun erc-cmd-KICKBAN (nick &rest reason)
  (setq reason (mapconcat #'identity reason " "))
  (and (string= reason "")
       (setq reason nil))
  (erc-cmd-BAN nick)
  (erc-server-send (format "KICK %s %s %s"
                           (erc-default-target)
                           nick
                           (or reason
                               "Kicked (kickban)"))))

(defun erc-cmd-LAST (len)
  "Recall the last LEN lines from dIRCproxy for the current channel"
  (let* ((chan (erc-default-target)))
    (erc-server-send (format "dircproxy recall %s %s" chan len))))

(defun erc-cmd-PROXY (line)
  "Say shit to dircproxy."

  (erc-server-send (format "dircproxy %s" (erc-trim-string line))))
(put 'erc-cmd-PROXY 'do-not-parse-args t)

(defun erc-cmd-UNPROXY ()
  "Quit dircproxy."
  (erc-server-send "dircproxy quit"))

(provide 'rwd-irc)
