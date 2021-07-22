;; 環境を日本語、UTF-8にする

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives  '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)
(require 'use-package)

(set-locale-environment nil)
(set-language-environment "Japanese")
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(setq-default tab-width 4)
(delete-selection-mode t) ; リージョンを削除可能に設定
(setq show-help-function nil) ; help文を非表示


(set-fontset-font
    nil 'japanese-jisx0208
    (font-spec :family "Ricty Diminished"))
(set-face-font 'default "Ricty Diminished-12")

;; ブラウザの設定
(let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
      (cmd-args '("/c" "start")))
    (when (file-exists-p cmd-exe)
      (setq browse-url-generic-program  cmd-exe
            browse-url-generic-args     cmd-args
            browse-url-browser-function 'browse-url-generic)))

;; iflipb（バッファ切り替え）
(use-package iflipb
  :ensure t
  :config
  (setq iflipb-ignore-buffers (list "^magit" "^[*]"))
  (setq iflipb-wrap-around t)
  (bind-key "C-M-<right>" 'iflipb-next-buffer)
  (bind-key "C-M-<left>" 'iflipb-previous-buffer))

;; dired
;; diredを2つのウィンドウで開いている時に、デフォルトの移動orコピー先をもう一方のdiredで開いているディレクトリにする
(setq dired-dwim-target t)
;; ディレクトリを再帰的にコピー・削除する
(setq dired-recursive-copies 'always)
;; (setq dired-recursive-deletes 'always)

(use-package dired
  :bind
    (:map dired-mode-map
		  ("RET" . dired-open-in-accordance-with-situation)
		  ("e" . wdired-change-to-wdired-mode)
		  ("f" . dired-open-in-accordance-with-situation)
		  ("b" . dired-up-alternate-directory))
  :config
  ;; hydra-dired
  (define-key dired-mode-map
	"."
	(defhydra hydra-dired (:hint nil :color pink)
	  "
       _+_ mkdir   _v_iew         _m_ark         _z_ip     _g_ revert buffer
       _C_opy      view _o_ther   _U_nmark all   un_Z_ip   _[_ hide detail
       _D_elete    open _f_ile    _u_nmark       _s_ort    counsel-_T_ramp
       _R_ename    _b_ack dir     ch_M_od        _e_dit    _._togggle hydra
      "
	  ("[" dired-hide-details-mode)
	  ("+" dired-create-directory)
	  ("RET" dired-open-in-accordance-with-situation :exit t)
	  ("f" dired-open-in-accordance-with-situation :exit t)
	  ("b" dired-up-alternate-directory)
	  ("C" dired-do-copy)   ;; Copy all marked files
	  ("D" dired-do-delete)
	  ("M" dired-do-chmod)
	  ("m" dired-mark)
	  ("o" dired-view-file-other-window :exit t)
	  ("?" dired-summary :exit t)
	  ("R" dired-do-rename)
	  ("g" revert-buffer)
	  ("e" wdired-change-to-wdired-mode :exit t)
	  ("s" dired-sort-toggle-or-edit)
	  ("T" counsel-tramp :exit t)
	  ("t" dired-toggle-marks)
	  ("U" dired-unmark-all-marks)
	  ("u" dired-unmark)
	  ("v" dired-view-file :exit t)
	  ("z" dired-zip-files)
	  ("Z" dired-do-compress)
	  ("q" nil)
	  ("." nil :color blue)))


  ;; View-file-other-window
  ;; http://y0m0r.hateblo.jp/entry/20120219/1329657774
  (defun dired-view-file-other-window ()
	"View-file other window."
	(interactive)
	(let ((file (dired-get-file-for-visit)))
	  (if (file-directory-p file)
		  (or (and (cdr dired-subdir-alist)
				   (dired-goto-subdir file))
			  (dired file))
		(view-file-other-window file))))

  ;; File are opened in separate buffer, directories are opened in same buffer
  ;; http://nishikawasasaki.hatenablog.com/entry/20120222/1329932699
  (defun dired-open-in-accordance-with-situation ()
	"Files are opened in separate buffers, directories are opened in the same buffer."
	(interactive)
	(let ((file (dired-get-filename)))
	  (if (file-directory-p file)
		  (dired-find-alternate-file)
		(dired-find-file))))
  ;; Move to higher directory without make new buffer
  (defun dired-up-alternate-directory ()
	"Move to higher directory without make new buffer."
   (interactive)
   (let* ((dir (dired-current-directory))
          (up (file-name-directory (directory-file-name dir))))
     (or (dired-goto-file (directory-file-name dir))
         ;; Only try dired-goto-subdir if buffer has more than one dir.
         (and (cdr dired-subdir-alist)
              (dired-goto-subdir up))
         (progn
           (find-alternate-file up)
           (dired-goto-file dir)))))
  (defun dired-zip-files (zip-file)
	"Create an archive containing the marked files."
	(interactive "sEnter name of zip file: ")
	;; create the zip file
	(let ((zip-file (if (string-match ".zip$" zip-file) zip-file (concat zip-file ".zip"))))
	  (shell-command
	   (concat "zip "
			   zip-file
			   " "
			   (concat-string-list
				(mapcar
				 '(lambda (filename)
					(file-name-nondirectory filename))
				 (dired-get-marked-files)))))))
  (defun concat-string-list (list)
   "Return a string which is a concatenation of all elements of the list separated by spaces"
   (mapconcat '(lambda (obj) (format "%s" obj)) list " "))
  )

;;; バックアップファイルを作らない
(setq make-backup-files nil)

;;; mozc
(use-package mozc)                                 ; mozcの読み込み
(setq default-input-method "japanese-mozc")     ; IMEをjapanes-mozcに
(global-unset-key [zenkaku-hankaku])
(global-set-key [zenkaku-hankaku] #'toggle-input-method)
(global-unset-key "\C-\\")

;; magit-status
(global-set-key (kbd "C-c g") 'magit-status)

;;ivy
(use-package ivy
  :ensure t
  :init (ivy-mode 1)
  :diminish ivy-mode
  :bind
  ("M-x" . counsel-M-x)
  ("C-x C-f" . counsel-find-file)
  ("C-x C-r" . counsel-recentf)
  ("C-x t" . counsel-tramp)
  :bind*
  ("C-c C-r" . ivy-resume)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-wrap t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-initial-inputs-alist
      '((org-agenda-refile . "^")
        (org-capture-refile . "^")
        ;; (counsel-M-x . "^") ;; 削除．必要に応じて他のコマンドも除外する．
        (Man-completion-table . "^")
        (woman . "^")))
  (setf (alist-get 'counsel-M-x ivy-re-builders-alist) #'ivy--regex-ignore-order)
  
  ;; (defun isearch-forward-or-swiper (use-swiper)
  ;;   (interactive "p")
  ;;   ;; (interactive "P") ;; 大文字のPだと，C-u C-sてでないと効かない
  ;;   (let (current-prefix-arg)
  ;;     (call-interactively (if use-swiper 'swiper 'isearch-forward))))
  ;; Toggle migemo and fuzzy by command.
  
  ;; (define-key ivy-minibuffer-map (kbd "M-f") #'ivy-migemo-toggle-fuzzy)
  ;; (define-key ivy-minibuffer-map (kbd "M-i") #'ivy-migemo-toggle-migemo)

  ;; ;; If you want to defaultly use migemo on swiper and counsel-find-file:
  ;; (setq ivy-re-builders-alist '((t . ivy--regex-plus)
  ;; 								(swiper . ivy-migemo--regex-plus)
  ;; 								(counsel-find-file . ivy-migemo--regex-plus))
  ;; 										;(counsel-other-function . ivy-migemo--regex-plus)
  ;; 		)

  ;; (use-package swiper-migemo
  ;; 	:init
  ;; 	(add-to-list 'load-path "~/.emacs.d/elpa/swiper-migemo")
  ;; 	:config
  ;; 	(add-to-list 'swiper-migemo-enable-command 'counsel-find-file)
  ;; 	(add-to-list 'swiper-migemo-enable-command 'counsel-recentf)
  ;; 	(add-to-list 'swiper-migemo-enable-command 'counsel-rg)
  ;; 	(setq migemo-options '("--quiet" "--nonewline" "--emacs"))
  ;; 	(migemo-kill)
  ;; 	(migemo-init)
  ;; 	(global-swiper-migemo-mode +1))
  
  (defun swiper-region ()
  "If region is selected `swiper' with the keyword selected in region. If the region isn't selected `swiper'."
  (interactive)
  (if (not (use-region-p))
      (swiper)
    (deactivate-mark)
    (swiper (buffer-substring-no-properties
	     (region-beginning) (region-end)))))
  (global-set-key (kbd "C-s") 'swiper-region)
  
;; ~/から始まるように
(defun ad:counsel-recentf ()
   "Find a file on `recentf-list'."
   (interactive)
   (require 'recentf)
   (recentf-mode)
   (ivy-read "Recentf: "
			 (progn
			   (mapcar #'substring-no-properties recentf-list) ;; no need?
			   (mapcar #'abbreviate-file-name recentf-list)) ;; ~/
			 :action (lambda (f)
					   (with-ivy-window
						 (find-file f)))
			 :require-match t
			 :caller 'counsel-recentf))
(advice-add 'counsel-recentf :override #'ad:counsel-recentf)

:config
    ;; using ivy-format-fuction-arrow with counsel-yank-pop
    (advice-add
    'counsel--yank-pop-format-function
    :override
    (lambda (cand-pairs)
      (ivy--format-function-generic
       (lambda (str)
         (mapconcat
          (lambda (s)
            (ivy--add-face (concat (propertize "┃ " 'face `(:foreground "#61bfff")) s) 'ivy-current-match))
          (split-string
           (counsel--yank-pop-truncate str) "\n" t)
          "\n"))
       (lambda (str)
         (counsel--yank-pop-truncate str))
       cand-pairs
       counsel-yank-pop-separator)))

    ;; NOTE: this variable do not work if defined in :custom
    (setq ivy-format-function 'ivy-format-function-pretty)
    (setq counsel-yank-pop-separator
        (propertize "\n────────────────────────────────────────────────────────\n"
               'face `(:foreground "#6272a4")))
  )

;; ivyのプロンプトにアイコンを表示
(with-eval-after-load "ivy"
  (defun my-pre-prompt-function ()
    (if window-system
        (format "%s "
                (all-the-icons-faicon "linux")) ;; ""
      (format "%s\n" (make-string (1- (frame-width)) ?\x2D))))
  (setq ivy-pre-prompt-function #'my-pre-prompt-function))

;; prescient
(when (require 'prescient nil t)

  ;; ivy インターフェイスでコマンドを実行するたびに，キャッシュをファイル保存
  (setq prescient-aggressive-file-save t)

  ;; ファイルの保存先
  (setq prescient-save-file
        (expand-file-name "~/.emacs.d/prescient-save.el"))

  ;; アクティベート
  (prescient-persist-mode 1))

(when (require 'ivy-prescient nil t)

  ;; =ivy= の face 情報を引き継ぐ（ただし，完全ではない印象）
  (setq ivy-prescient-retain-classic-highlighting t)

  ;; コマンドを追加
  (dolist (command '(counsel-M-x)) ;; add :caller
    (add-to-list 'ivy-prescient-sort-commands command))

  ;; フィルタの影響範囲を限定する．以下の3つは順番が重要．
  (ivy-prescient-mode 1)
  (setq ivy-prescient-enable-filtering nil))

;; all-the-icons
(use-package all-the-icons)
(use-package all-the-icons-ivy
  :ensure t
  :config
  (setq all-the-icons-scale-factor 1.0)
  (defun all-the-icons-ivy-icon-for-file (s)
	"Return icon for filename S.
Return the octicon for directory if S is a directory.
Otherwise fallback to calling `all-the-icons-icon-for-file'."
	(cond
	 ((string-match-p "\\/$" s)
	  (all-the-icons-octicon "file-directory" :face 'all-the-icons-ivy-dir-face))
	 (t (all-the-icons-icon-for-file s :v-adjust 0.02))))
  (defun all-the-icons-ivy--icon-for-mode (mode)
	"Apply `all-the-icons-for-mode' on MODE but either return an icon or nil."
	(let ((icon (all-the-icons-icon-for-mode mode :v-adjust 0.02)))
	  (unless (symbolp icon)
		icon)))
  (all-the-icons-ivy-setup)

  ;; ivyのカーソル設定
  (defface my-ivy-arrow-visible
  '((((class color) (background light)) :foreground "orange")
    (((class color) (background dark)) :foreground "#EE6363"))
  "Face used by Ivy for highlighting the arrow.")

  (defface my-ivy-arrow-invisible
	'((((class color) (background light)) :foreground "#ededed")
	  (((class color) (background(defface my-ivy-arrow-invisible
								   '((((class color) (background light)) :foreground "#ededed")
									 (((class color) (background dark)) :foreground "#31343F"))
								   "Face used by Ivy for highlighting the invisible arrow.") dark)) :foreground "#31343F"))
	"Face used by Ivy for highlighting the invisible arrow.")

  (if window-system
	  (when (require 'all-the-icons nil t)
		(defun my-ivy-format-function-arrow (cands)
		  "Transform CANDS into a string for minibuffer."
		  (ivy--format-function-generic
		   (lambda (str)
			 (concat (all-the-icons-faicon
					  "hand-o-right"
					  :v-adjust -0.2 :face 'my-ivy-arrow-visible)
					 " " (ivy--add-face str 'ivy-current-match)))
		   (lambda (str)
			 (concat (all-the-icons-faicon
					  "hand-o-right" :face 'my-ivy-arrow-invisible) " " str))
		   cands
		   "\n"))
		(setq ivy-format-functions-alist
			  '((t . my-ivy-format-function-arrow))))
	(setq ivy-format-functions-alist '((t . ivy-format-function-arrow))))

  ;; ivyのマッチ部分のface
  (custom-set-faces
   '(ivy-current-match
	 ((((class color) (background light))
	   :background "#e0daab" :distant-foreground "#000000")
	  (((class color) (background dark))
	   :background "#404040" :distant-foreground "#abb2bf")))
   '(ivy-minibuffer-match-face-1
	 ((((class color) (background light)) :foreground "#666666")
	  (((class color) (background dark)) :foreground "#999999")))
   '(ivy-minibuffer-match-face-2
	 ((((class color) (background light)) :foreground "#c03333" :underline t)
	  (((class color) (background dark)) :foreground "#e04444" :underline t)))
   '(ivy-minibuffer-match-face-3
	 ((((class color) (background light)) :foreground "#8585ff" :underline t)
	  (((class color) (background dark)) :foreground "#7777ff" :underline t)))
   '(ivy-minibuffer-match-face-4
	 ((((class color) (background light)) :foreground "#439943" :underline t)
	  (((class color) (background dark)) :foreground "#33bb33" :underline t))))
  )
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)


(use-package ivy-hydra
  :ensure t
  :config
  (setq ivy-read-action-function #'ivy-hydra-read-action)
  )


;;swiperを日本語にも対応
(defun my:ivy-migemo-re-builder (str)
  "Own function for my:ivy-migemo."
  (let* ((sep " \\|\\^\\|\\.\\|\\*")
         (splitted (--map (s-join "" it)
                          (--partition-by (s-matches-p " \\|\\^\\|\\.\\|\\*" it)
                                          (s-split "" str t)))))
    (s-join "" (--map (cond ((s-equals? it " ") ".*?")
                            ((s-matches? sep it) it)
                            (t (migemo-get-pattern it)))
                      splitted))))

(setq ivy-re-builders-alist '((t . ivy--regex-plus)
                              (swiper . my:ivy-migemo-re-builder)))

;; If you want to defaultly use migemo on swiper and counsel-find-file:
;; (setq ivy-re-builders-alist '((t . ivy--regex-plus)
;;                               (swiper . ivy-migemo--regex-plus)
;;                               (counsel-find-file . ivy-migemo--regex-plus))
;;                               ;(counsel-other-function . ivy-migemo--regex-plus)
;;                               )

;;migemo
(use-package migemo
  :ensure t
  :config
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  ;; Set your installed path
  (setq migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  (load-library "migemo")
  (migemo-init)
  )

(use-package org
  :init
  (setq my-org-directory "/mnt/c/Users/fight/GoogleDrive/org/")
  :mode (("\\.org$" . org-mode))
  :bind (("C-c c" . org-capture)
		 ("C-c a" . org-agenda)
		 ("C-c l" . org-store-link)
		 ("C-c C-l" . org-insert-link))
  :config
  (setq org-capture-templates
      '(
	;; タスク（スケジュールなし）
	("t" "タスク（スケジュールなし）" entry (file+headline "/mnt/c/Users/fight/GoogleDrive/org/non_Scheduled_Tasks.org" "Tasks")
	 "** TODO %? \n")
 
	;; タスク（スケジュールあり）
	("s" "タスク（スケジュールあり）" entry (file+headline "/mnt/c/Users/fight/GoogleDrive/org/Scheduled_Tasks.org" "Tasks")
	 "** TODO %? \n   SCHEDULED: %^t \n")
	
        ("m" "Memo" checkitem (file+headline "/mnt/c/Users/fight/GoogleDrive/org/memo.org" "追記")
	 "- %? \n")
 
        ("T" "Tech" checkitem (file+headline "/mnt/c/Users/fight/GoogleDrive/org/tech/TechMemo.org" "追記")
	 "- %? \n")
		)
	  )
  (setq org-tag-alist '(("Haiku" . ?h) ("School" . ?s)))
  (setq org-todo-keywords
		'((sequence "TODO(t)" "SOMEDAY(s)" "WAITING(w)" "|" "DONE(d)")))
  (setq org-log-done 'time)
  (defun replace-dot-comma ()
  "s/。/．/g; s/、/，/g;する"
  (interactive)
  (let ((curpos (point)))
    (goto-char (point-min))
    (while (search-forward "。" nil t) (replace-match "．"))
    
    (goto-char (point-min))
    (while (search-forward "、" nil t) (replace-match "，"))
    (goto-char curpos)
    ))

  (add-hook 'org-mode-hook
			'(lambda ()
			   (add-hook 'before-save-hook 'replace-dot-comma nil 'make-it-local)
			   ))
  (setq org-agenda-files '(
             "/mnt/c/Users/fight/GoogleDrive/org/non_Scheduled_Tasks.org"
             "/mnt/c/Users/fight/GoogleDrive/org/Scheduled_Tasks.org"
			 "/mnt/c/Users/fight/GoogleDrive/org/memo.org"
			 "/mnt/c/Users/fight/GoogleDrive/org/yaritai.org"
                         )))

(use-package org-bullets
  :config (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))


;;htmlなどにエクスポートするとき
;; (use-package ox-bibtex)
(use-package open-junk-file
  :bind ("C-c j" . open-junk-file)
  :config
  (setq open-junk-file-format "/mnt/c/Users/fight/GoogleDrive/org/junk/%Y-%m%d-memo.org")
  ;; (setq open-junk-file-find-file-function 'find-file)  ;; custom経由で設定
  )

;; yasnippet
(use-package yasnippet
  :ensure t
  :init (yas-global-mode)
  :config
  (setq yas-snippet-dirs
		'("~/.emacs.d/snippets"
		  "~/.emacs.d/elpa/yasnippet-snippets-20210408.1234/snippets/")))

(use-package ivy-yasnippet
  :ensure t
  :after (yasnippet)
  :bind (("C-c y" . ivy-yasnippet)
         ("C-c C-y" . ivy-yasnippet)))
  
;; c言語関係
(use-package irony
  :defer t
  :commands irony-mode
  :init
  (add-hook 'c-mode-common-hook 'irony-mode)
  (add-hook 'c-mode-common-hook 'flycheck-mode)
  (add-hook 'c++-mode-hook 'irony-mode)
  :config
  ;; C言語用にコンパイルオプションを設定する.
  (add-hook 'c-mode-hook
            '(lambda ()
               (setq irony-additional-clang-options '("-std=c11" "-Wall" "-Wextra"))))

  ;; C++言語用にコンパイルオプションを設定する.
  (add-hook 'c++-mode-hook
            '(lambda ()
               (setq irony-additional-clang-options '("-std=c++14" "-Wall" "-Wextra"))))
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  )



;; quickrun
(defun my-quickrun ()
  ;; リージョンがアクティブならquickrun-region
  (interactive)
  (if (region-active-p)
	  (quickrun-region (region-beginning) (region-end))
	(quickrun-shell)))
(use-package quickrun
  :ensure t
  :bind* ("<f5>" . my-quickrun)
  :config
  (quickrun-add-command "python"
  '((:command . "python3"))
  :override t)
  )

;; 括弧などの補完
(electric-pair-mode 1)


;; ウィンドウを透明にする(できてない)
;; (add-to-list 'load-path "~/.emacs.d/elpa/cycle-frame-transparency/")
;; (require 'cycle-frame-transparency)
;; (setq cft--trasparent 20)
;; アクティブウィンドウ／非アクティブウィンドウ（alphaの値で透明度を指定）
;; (add-to-list 'default-frame-alist '(alpha . (0.85 0.85)))

;; メニューバーを消す
;; (menu-bar-mode -1)

;; ツールバーを消す
(tool-bar-mode -1)

;; 列数を表示する
(column-number-mode t)


;; カーソルの点滅をやめる
(blink-cursor-mode 0)

;; 起動時のウィンドウ位置
(if (boundp 'window-system)
  (setq default-frame-alist
    (append (list
      '(top . 20) ;ウィンドウの表示位置(Y座標)
      '(left . 0) ;ウィンドウの表示位置(X座標)
      '(width . 70) ;ウィンドウ幅
      '(height . 15) ;ウィンドウ高
	  '(mouse-color . "SlateBlue2") ; マウスポインタの色
	  ;; '(cursor-color . "snow") ; テキストカーソルの色
    )
    default-frame-alist)
  )
  )


;; スタートアップ画面の非表示
(setq inhibit-startup-message t)

;; カーソル行をハイライトする
(defface my-hl-line-face
  '((((class color) (background dark))
	 (:background "NavyBlue" t))
	(((class color) (background light))
	 (:background "LightSkyBlue" t))
	(t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)


;; 対応する括弧を光らせる
(show-paren-mode 1)
;; 対応する括弧を強調表示(マッチ部分)
(set-face-attribute 'show-paren-match nil :background "LightGoldenrod1" :bold t)

;; 対応する括弧を、強調表示(非マッチ部分)
(set-face-attribute 'show-paren-mismatch nil :background "magenta" :bold t)

;; ウィンドウ内に収まらないときだけ、カッコ内も光らせる
;;(setq show-paren-style 'mixed)
;;(set-face-background 'show-paren-match-face "grey")
;;(set-face-foreground 'show-paren-match-face "black")

;; recentfからGoogleDrive/org/以下のファイルを除く
(setq recentf-exclude '("/recentf" "GoogleDrive/org" "bookmarks"))

;; beep音を消す
(defun my-bell-function ()
  (unless (memq this-command
		'(isearch-abort abort-recursive-edit exit-minibuffer
				keyboard-quit mwheel-scroll down up next-line previous-line
				backward-char forward-char scroll-up-command scroll-down-command))
    (ding)))
(setq ring-bell-function 'my-bell-function)

;;full-pass表示
(setq frame-title-format "%f")

;;window切り替え
(defun other-window-or-split ()
  (interactive)
  (when (one-window-p)
	(split-window-horizontally))
  (other-window 1))

(bind-key* "C-t" 'other-window-or-split)

;; elscreen
(use-package elscreen
  :init (elscreen-start)
  :config
  (setq elscreen-prefix-key (kbd "C-z"))
  ;; [X]マーク非表示
  (setq elscreen-tab-display-kill-screen nil)
  ;; header-lineの先頭に[<->]を表示しない
  (setq elscreen-tab-display-control nil)
  ;; タブを消す
  (setq elscreen-display-tab nil)
  ;; タブ全消しをしない
  ;; (setq elscreen-tab-display-kill-screen nil)
  (elscreen-create)

  :bind* ("<f9>" . elscreen-toggle)
  )

;;company
(use-package company
  :init (global-company-mode)
  :config
  (company-quickhelp-mode t)
  (setq company-selection-wrap-around t) ; 候補の最後の次は先頭に戻る
  (defun company--insert-candidate2 (candidate)
	(when (> (length candidate) 0)
	  (setq candidate (substring-no-properties candidate))
	  (if (eq (company-call-backend 'ignore-case) 'keep-prefix)
		  (insert (company-strip-prefix candidate))
		(if (equal company-prefix candidate)
			(company-select-next)
		    (delete-region (- (point) (length company-prefix)) (point))
		  (insert candidate))
		)))

  (defun company-complete-common2 ()
	(interactive)
	(when (company-manual-begin)
	  (if (and (not (cdr company-candidates))
			   (equal company-common (car company-candidates)))
		  (company-complete-selection)
		(company--insert-candidate2 company-common))))

  (define-key company-active-map [tab] 'company-complete-common2)
  (define-key company-active-map [backtab] 'company-select-previous)
  ;; comapny-box(まだアイコンが一種類しかでない、背景がおかしい)
;;   (use-package company-box
;;     :diminish
;;     :hook (company-mode . company-box-mode)
;;     :init (setq company-box-icons-alist 'company-box-icons-all-the-icons)
;;     :config
;;     ;; (setq company-box-backends-colors nil)
;;     ;; (setq company-box-show-single-candidate t)
;;     (setq company-box-max-candidates 50)

;;     (defun company-box-icons--elisp (candidate)
;;       (when (derived-mode-p 'emacs-lisp-mode)
;;         (let ((sym (intern candidate)))
;;           (cond ((fboundp sym) 'Function)
;;                 ((featurep sym) 'Module)
;;                 ((facep sym) 'Color)
;;                 ((boundp sym) 'Variable)
;;                 ((symbolp sym) 'Text)
;;                 (t . nil)))))

;;     (with-eval-after-load 'all-the-icons
;;       (declare-function all-the-icons-faicon 'all-the-icons)
;;       (declare-function all-the-icons-fileicon 'all-the-icons)
;;       (declare-function all-the-icons-material 'all-the-icons)
;;       (declare-function all-the-icons-octicon 'all-the-icons)
;;       (setq company-box-icons-all-the-icons
;;             `((Unknown . ,(all-the-icons-material "find_in_page" :height 0.7 :v-adjust -0.15))
;;               (Text . ,(all-the-icons-faicon "book" :height 0.68 :v-adjust -0.15))
;;               (Method . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
;;               (Function . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
;;               (Constructor . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
;;               (Field . ,(all-the-icons-faicon "tags" :height 0.65 :v-adjust -0.15 :face 'font-lock-warning-face))
;;               (Variable . ,(all-the-icons-faicon "tag" :height 0.7 :v-adjust -0.05 :face 'font-lock-warning-face))
;;               (Class . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01 :face 'font-lock-constant-face))
;;               (Interface . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01))
;;               (Module . ,(all-the-icons-octicon "package" :height 0.7 :v-adjust -0.15))
;;               (Property . ,(all-the-icons-octicon "package" :height 0.7 :v-adjust -0.05 :face 'font-lock-warning-face)) ;; Golang module
;;               (Unit . ,(all-the-icons-material "settings_system_daydream" :height 0.7 :v-adjust -0.15))
;;               (Value . ,(all-the-icons-material "format_align_right" :height 0.7 :v-adjust -0.15 :face 'font-lock-constant-face))
;;               (Enum . ,(all-the-icons-material "storage" :height 0.7 :v-adjust -0.15 :face 'all-the-icons-orange))
;;               (Keyword . ,(all-the-icons-material "filter_center_focus" :height 0.7 :v-adjust -0.15))
;;               (Snippet . ,(all-the-icons-faicon "code" :height 0.7 :v-adjust 0.02 :face 'font-lock-variable-name-face))
;;               (Color . ,(all-the-icons-material "palette" :height 0.7 :v-adjust -0.15))
;;               (File . ,(all-the-icons-faicon "file-o" :height 0.7 :v-adjust -0.05))
;;               (Reference . ,(all-the-icons-material "collections_bookmark" :height 0.7 :v-adjust -0.15))
;;               (Folder . ,(all-the-icons-octicon "file-directory" :height 0.7 :v-adjust -0.05))
;;               (EnumMember . ,(all-the-icons-material "format_align_right" :height 0.7 :v-adjust -0.15 :face 'all-the-icons-blueb))
;;               (Constant . ,(all-the-icons-faicon "tag" :height 0.7 :v-adjust -0.05))
;;               (Struct . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01 :face 'font-lock-constant-face))
;;               (Event . ,(all-the-icons-faicon "bolt" :height 0.7 :v-adjust -0.05 :face 'all-the-icons-orange))
;;               (Operator . ,(all-the-icons-fileicon "typedoc" :height 0.65 :v-adjust 0.05))
;;               (TypeParameter . ,(all-the-icons-faicon "hashtag" :height 0.65 :v-adjust 0.07 :face 'font-lock-const-face))
;;               (Template . ,(all-the-icons-faicon "code" :height 0.7 :v-adjust 0.02 :face 'font-lock-variable-name-face))))))
)




;; (use-package company-box
;;   :diminish company-box-mode
;;   :after (company all-the-icons)
;;   :hook ((company-mode . company-box-mode))
;;   :custom
;;   (company-box-icons-alist 'company-box-icons-all-the-icons)
;;   (company-box-doc-enable nil))


(use-package company-irony
  :defer t
  :config
  ;; companyの補完のバックエンドにironyを使用する.
  (add-to-list 'company-backends '(company-irony-c-headers company-irony))
  )


;;elpy
(use-package elpy
  :ensure t
  :init (elpy-enable)
  :bind (:map elpy-mode-map
			  ("C-c C-n" . flycheck-next-error)
			  ("C-c C-p" . flycheck-previous-error)
			  ("C-c C-l" . flycheck-list-errors))
  :config
  (when (load "flycheck" t t)
	(setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
	(add-hook 'elpy-mode-hook 'flycheck-mode))
  (setq elpy-rpc-backend "jedi")
  (setq elpy-rpc-python-command "python3")
  (setq flycheck-flake8-maximum-line-length 200))
  

;;org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . nil)
      (C . t)))

;;latex関連
;;org-latex-classesがxelatex用の設定になっているので直す
(use-package ox-latex)
(setq org-latex-with-hyperref nil)

;; reftex
(defun org-mode-reftex-setup ()
  (load-library "reftex")
  (and (buffer-file-name)
       (file-exists-p (buffer-file-name))
       (reftex-parse-all))
  (define-key org-mode-map (kbd "C-c [") 'reftex-citation)
  )
(add-hook 'org-mode-hook 'org-mode-reftex-setup)
(setq reftex-default-bibliography '("~/texmf/pbibtex/bib/papers.bib"))

;; yatex
(use-package yatex
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.tex\\'" . yatex-mode)) ;;auto-mode-alistへの追加
  (setq tex-command "latexmk -pvc")
  (setq dvi2-command "evince")
  (setq YaTeX-on-the-fly-preview-interval nil)
  (setq bibtex-command "pbibtex")    ;; 自分の環境に合わせて""内を変えてください
  ;; \sectionの色の設定（うまくいかん）
  ;;(setq YaTeX-hilit-sectioning-face '(light時のforecolor/backcolor dark時のforecolor/backcolor))
  (setq YaTeX-hilit-sectioning-face '(darkblue/LightGray LightGray/Black))
  ;; sectionの階層が変化する時の色の変化の割合（パーセント）
  ;; (setq YaTeX-hilit-sectioning-attenuation-rate '(light時の割合/dark時の割合))
  (setq YaTeX-hilit-sectioning-attenuation-rate '(0 0))

  ;;reftex-mode
  (add-hook 'yatex-mode-hook
			#'(lambda ()
				(reftex-mode 1)))
  )
 (add-hook 'yatex-mode-hook
			'(lambda ()
			   (add-hook 'before-save-hook 'replace-dot-comma nil 'make-it-local)
			   ))
 (add-hook 'latex-mode-hook
			'(lambda ()
			   (add-hook 'before-save-hook 'replace-dot-comma nil 'make-it-local)
			   ))

(add-to-list 'org-latex-classes
			 '("koma-article"
			   "\\documentclass{scrartcl}"
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   ("\\paragraph{%s}" . "\\paragraph*{%s}")
			   ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

(add-to-list 'org-latex-classes
			 '("koma-jarticle"
			                  "\\documentclass{scrartcl}
               \\usepackage{amsmath}
               \\usepackage{amssymb}
               \\usepackage{xunicode}
               \\usepackage{fixltx2e}
               \\usepackage{zxjatype}
               \\usepackage[hiragino-dx]{zxjafont}
               \\usepackage{xltxtra}
               \\usepackage{graphicx}
               \\usepackage{longtable}
               \\usepackage{float}
               \\usepackage{wrapfig}
               \\usepackage{soul}
               \\usepackage{hyperref}"
							  ("\\section{%s}" . "\\section*{%s}")
							  ("\\subsection{%s}" . "\\subsection*{%s}")
							  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
							  ("\\paragraph{%s}" . "\\paragraph*{%s}")
							  ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

;; tufte-handout class for writing classy handouts and papers
(add-to-list 'org-latex-classes
			 '("tufte-handout"
			                  "\\documentclass[twoside,nobib]{tufte-handout}
                                 [NO-DEFAULT-PACKAGES]
                \\usepackage{zxjatype}
                \\usepackage[hiragino-dx]{zxjafont}"
							  ("\\section{%s}" . "\\section*{%s}")
							  ("\\subsection{%s}" . "\\subsection*{%s}")))
;; tufte-book class
(add-to-list 'org-latex-classes
			 '("tufte-book"
			                  "\\documentclass[twoside,nobib]{tufte-book}
                                [NO-DEFAULT-PACKAGES]
                 \\usepackage{zxjatype}
                 \\usepackage[hiragino-dx]{zxjafont}"
							  ("\\part{%s}" . "\\part*{%s}")
							  ("\\chapter{%s}" . "\\chapter*{%s}")
							  ("\\section{%s}" . "\\section*{%s}")
							  ("\\subsection{%s}" . "\\subsection*{%s}")
							  ("\\paragraph{%s}" . "\\paragraph*{%s}")))

(setq org-latex-pdf-process
	  '("latexmk %f"))

(add-to-list 'org-latex-classes
			 '("jsarticle"
			   "\\documentclass[dvipdfmx]{jsarticle}"
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   ("\\paragraph{%s}" . "\\paragraph*{%s}")
			   ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
			   )
			 )
(add-to-list 'org-latex-classes
			 '("jsreport"
			   "\\documentclass[dvipdfmx,report]{jsbook}"
			   ("\\chapter{%s}" . "\\chapter*{%s}")
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   ("\\paragraph{%s}" . "\\paragraph*{%s}")
			   )
			 )
(add-to-list 'org-latex-classes
			 '("jsbook"
			   "\\documentclass[dvipdfmx]{jsbook}"
			   ("\\part{%s}" . "\\part*{%s}")
			   ("\\chapter{%s}" . "\\chapter*{%s}")
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   )
			 )
(add-to-list 'org-latex-classes
			 '("bxjsarticle"
			   "\\documentclass[platex, jadriver=standard]{bxjsarticle}"
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   ("\\paragraph{%s}" . "\\paragraph*{%s}")
			   ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
			   )
			 )
(add-to-list 'org-latex-classes
			 '("beamer"
			   "\\documentclass[dvipdfmx,12pt]{beamer}"
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   ("\\paragraph{%s}" . "\\paragraph*{%s}")
			   ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
			   )
			 )

(add-to-list 'org-latex-classes
			 '("thesis_2020"
			   "\\documentclass{harmothesis}
                [NO-DEFAULT-PACKAGES]
                \\usepackage[dvipdfmx]{graphicx}
                \\usepackage{url}
                \\usepackage{listings}"
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   ("\\paragraph{%s}" . "\\paragraph*{%s}")
			   ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
			   )
			 )

(add-to-list 'org-latex-classes
			 '("ipjs"
			   "\\documentclass[submit]{ipsj}"
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   ("\\paragraph{%s}" . "\\paragraph*{%s}")
			   ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
			   )
			 )


(setq org-latex-default-class "bxjsarticle")

(use-package nyan-mode
  :ensure t
  :init
  (nyan-mode t)
  ;; (nyan-start-animation)
  ;; (nyan-start-music)
  )


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
	("28caf31770f88ffaac6363acfda5627019cac57ea252ceb2d41d98df6d87e240" "f3455b91943e9664af7998cc2c458cfc17e674b6443891f519266e5b3c51799d" default)))
 '(espotify-client-id "18a882a383ac4a7c9b067444cec1a5e9")
 '(espotify-client-secret "f74c6dd514a2428da821a85611d49a71")
 '(open-junk-file-find-file-function (quote find-file))
 '(package-selected-packages
   (quote
	(lsp-ui lsp-python-ms lsp-mode csv-mode yatex yasnippet-snippets ivy-migemo ivy-spotify counsel-tramp iflipb magit zone-nyan nyan-mode ivy-xref dumb-jump company-quickhelp package-utils company-box ivy-prescient all-the-icons-dired all-the-icons all-the-icons-ivy markdown-preview-mode ivy-yasnippet quickrun company-irony diminish counsel swiper ivy open-junk-file org-bullets org-plus-contrib use-package mozc migemo helm-core flycheck elscreen elpy)))
 '(show-paren-style (quote parenthesis)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ivy-current-match ((((class color) (background light)) :background "#e0daab" :distant-foreground "#000000") (((class color) (background dark)) :background "#404040" :distant-foreground "#abb2bf")))
 '(ivy-minibuffer-match-face-1 ((((class color) (background light)) :foreground "#666666") (((class color) (background dark)) :foreground "#999999")))
 '(ivy-minibuffer-match-face-2 ((((class color) (background light)) :foreground "#c03333" :underline t) (((class color) (background dark)) :foreground "#e04444" :underline t)))
 '(ivy-minibuffer-match-face-3 ((((class color) (background light)) :foreground "#8585ff" :underline t) (((class color) (background dark)) :foreground "#7777ff" :underline t)))
 '(ivy-minibuffer-match-face-4 ((((class color) (background light)) :foreground "#439943" :underline t) (((class color) (background dark)) :foreground "#33bb33" :underline t))))


(load-theme 'adwaita t)

