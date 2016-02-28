(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))

(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))

(package-initialize)

(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
			  "[ \t\n]*$"
			  ""
			  (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))

;; Set up golang support (See guide below)
;; http://tleyden.github.io/blog/2014/05/22/configure-emacs-as-a-go-editor-from-scratch/

(setenv "GOPATH" "/Users/rodrigo.farnham/Development/gocode")

(setq exec-path (cons "/usr/local/go/bin" exec-path))
(add-to-list 'exec-path "/Users/rodrigo.farnham/Development/gocode/bin")

(defun my-go-mode-hook ()
  ;; Use goimports instead of go-fmt
  ;; Make sure to install goimports via "go get golang.org/x/tools/cmd/goimports"
  (setq gofmt-command "goimports")

  ;; Call Gofmt before saving
  (add-hook 'before-save-hook 'gofmt-before-save)

  ;; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
	   "go build -v && go test -v && go vet"))

  ;; Go oracle
  ;; Make sure to install oracle via "go get golang.org/x/tools/cmd/oracle"
  (load-file "$GOPATH/src/golang.org/x/tools/cmd/oracle/oracle.el")

  ;; Godef jump M-. key binding. Use M-* to jump back.
  ;; Make sure to install godef via "go get github.com/rogpeppe/godef"
  (local-set-key (kbd "M-.") 'godef-jump))


;; Auto complete
;; Make sure to install gocode via "go get -u github.com/nsf/gocode"
(defun auto-complete-for-go ()
  (auto-complete-mode 1))
(with-eval-after-load 'go-mode
  (require 'go-autocomplete))

;; Add hooks
(add-hook 'go-mode-hook 'my-go-mode-hook)
(add-hook 'go-mode-hook 'auto-complete-for-go)


