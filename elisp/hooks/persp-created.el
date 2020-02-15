(require 'f)

(let* ((curr-name (persp-current-name))
       (maybe-dir (concat (f-canonical (f-join "~/Links" curr-name)) "/"))
       (proj--dir
        (cond ((equal "*" curr-name) (f-canonical "~/"))
              ((f-directory? maybe-dir) maybe-dir)
              ((s-lowercase? curr-name) default-directory)
              (t (call-interactively
                  #'(lambda (path) (interactive "Glocation: ") path))))))
  (with-current-buffer (persp-scratch-buffer)
    (message "creating perspective in %s" proj--dir)
    (setq default-directory proj--dir)
    (rwd-shell)))
