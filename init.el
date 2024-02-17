;; 環境を日本語、UTF-8にする

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
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
(global-auto-revert-mode 1)
(define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))
(global-set-key (kbd "M-h") 'backward-kill-word)
(global-set-key (kbd "<f5>") 'help-for-help)
(setq gc-cons-threshold 1600000)  ; lsp が重かったら2倍にする
(scroll-bar-mode -1)
(setq confirm-kill-processes nil)  ; Stop confirming the killing of processes
(set-mouse-color "SlateBlue2")
(mac-auto-ascii-mode 1)  ; C-xやM-x を打った際に英語モードに切り替える

;; scratch buffer を org mode 仕様に
(setq initial-major-mode 'org-mode)
(setq initial-scratch-message "")

; mac-auto-ascii-mode 時に日本語入力を保ってほしい関数の設定
(defvar mac-win-last-ime-status 'off) ;; {'off|'on}
(defun mac-win-save-last-ime-status ()
  (setq mac-win-last-ime-status
        (if (string-match "\\.\\(Roman\\|ABC\\)$" (mac-input-source))
            'off 'on)))
(defun mac-win-restore-ime ()
  (when (and mac-auto-ascii-mode (eq mac-win-last-ime-status 'on))
    (mac-select-input-source
     "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"))) ;; (mac-input-source) を評価して名前を調べる
(defun advice:mac-auto-ascii-setup-input-source (&optional _prompt)
  "Extension to store IME status"
  (mac-win-save-last-ime-status))
(advice-add 'mac-auto-ascii-setup-input-source :before
            #'advice:mac-auto-ascii-setup-input-source)
(defun mac-win-restore-ime-target-commands ()
  (when (and mac-auto-ascii-mode 
             (eq mac-win-last-ime-status 'on))
    (mapc (lambda (command)
            (when (string-match
                   (format "^%s" command) (format "%s" this-command))
              (mac-select-input-source
               "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"))) ;; (mac-input-source) を評価して名前を調べる
          mac-win-target-commands)))
(add-hook 'pre-command-hook 'mac-win-restore-ime-target-commands)
;; M-x でのコマンド選択でもIMEを戻せる．
;; ただし，移動先で q が効かないことがある（要改善）
(add-hook 'minibuffer-setup-hook 'mac-win-save-last-ime-status)
(add-hook 'minibuffer-exit-hook 'mac-win-restore-ime)
;; 自動で ASCII入力から日本語入力に引き戻したい関数（デフォルト設定）
(defvar mac-win-target-commands
  '(find-file save-buffer other-window delete-window split-window backward-delete-char-untabify))
;; 自動で ASCII入力から日本語入力に引き戻したい関数（追加設定）
;; 指定の関数名でマッチさせるので要注意（ my: を追加すれば，my:a, my:b らも対象になる）

;; org-mode で締め切りを設定するとき．
(add-to-list 'mac-win-target-commands 'org-deadline)
;; query-replace で変換するとき
(add-to-list 'mac-win-target-commands 'query-replace)


;; mac にしたら要調整
(set-fontset-font
    nil 'japanese-jisx0208
    (font-spec :family "Ricty Diminished"))
(set-face-font 'default "Ricty Diminished-19")
;; (add-to-list 'face-font-rescale-alist '(".*Ricty Diminished.*" . 0.85))  ;; 外部モニター用
(add-to-list 'face-font-rescale-alist '(".*Ricty Diminished.*" . 1.0))  ;; ノートPC用
;; wsl2
(set-face-attribute 'default nil
					:height 180)
;; mobaXTerm と併用するなら、モニタの解像度で条件分岐する方法がありそう
;; (set-face-attribute 'default nil
;; 					:height 150)


;; mac にしたら要調整
;; ブラウザの設定
(let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
      (cmd-args '("/c" "start")))
    (when (file-exists-p cmd-exe)
      (setq browse-url-generic-program  cmd-exe
            browse-url-generic-args     cmd-args
            browse-url-browser-function 'browse-url-generic)))


;; 括弧などの補完
(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :hook
  (emacs-lisp-mode . smartparens-mode)
  (python-mode . smartparens-mode)
  (inferior-python-mode . smartparens-mode)
  (eshell-mode . smartparens-mode)
  (org-mode . smartparens-mode)
  (js2-mode . smartparens-mode)
  (java-mode . smartparens-mode)
  )
;; 単語選択
;; (defun mark-word-at-point ()
;;   (interactive)
;;   (let ((char (char-to-string (char-after (point)))))
;;     (cond
;;      ((string= " " char) (delete-horizontal-space))
;;      ((string-match "[\t\n -@\[-`{-~]" char) (mark-word ))
;;      (t (forward-char) (backward-word) (mark-word 1)))))
;; (global-set-key "\M-@" 'mark-word-at-point)

;; 単語選択(exxpand-region)
(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-@") 'er/expand-region)
  )
;; マルチカーソル
(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C-c m e") 'mc/edit-ends-of-lines)
  (global-set-key (kbd "C-c m a") 'mc/edit-beginnings-of-lines)
  (global-set-key (kbd "C-c m n") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-c m p") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c m l") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-c m m") 'mc/mark-more-like-this-extended)
  )
;; グローバルに有効にできれば使えそう
;; (use-package region-bindings-mode
;;   :ensure t
;;   :bind
;;   (:map region-bindings-mode-map
;; 		("l" . mc/mark-all-like-this)
;; 		("n" . mc/mark-next-like-this)
;; 		("p" . mc/mark-previous-like-this)
;; 		("e" . mc/edit-ends-of-lines)
;; 		("a" . mc/edit-beginnings-of-lines)
;; 		("m" . mc/mark-more-like-this-extended)
;; 		)
;;   :config
;;   (region-bindings-mode-enable)
;;   (region-bindings-mode)
;;   )
  

;; iflipb（バッファ切り替え）
(use-package iflipb
  :ensure t
  :config
  (setq iflipb-ignore-buffers (list "^magit" "^[*]" "^vterm"))
  (setq iflipb-wrap-around t)
  (bind-key "C-M-<right>" 'iflipb-next-buffer)
  (bind-key "C-M-<left>" 'iflipb-previous-buffer))

;; 行複製
(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
)
(global-set-key (kbd "A-<down>") 'duplicate-line)

(use-package eldoc
  :diminish eldoc-mode)

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
(use-package mozc
  :config
  (add-hook 'input-method-inactivate-hook
 	    (lambda() (set-cursor-color "#00BBFF")))
   (add-hook 'input-method-activate-hook
 	    (lambda() (set-cursor-color "pink")))
  )
(setq default-input-method "japanese-mozc")     ; IMEをjapanes-mozcに
(global-unset-key [zenkaku-hankaku])
(global-set-key [zenkaku-hankaku] #'toggle-input-method)
(global-unset-key "\C-\\")

;; magit-status
(global-set-key (kbd "C-c g") 'magit-status)
(setq magit-auto-revert-mode t)
;; README プレビュー
(use-package grip-mode
  :ensure t
  :diminish grip-mode)
(use-package markdown-mode
  :bind (:map markdown-mode-command-map
			  ("g" . grip-mode)))


;; ediff
;; コントロール用のバッファを同一フレーム内に表示する
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; ediff のバッファを左右に並べる（"|"キーで上下、左右の切り替え可）
(setq ediff-split-window-function 'split-window-horizontally)

;; unkillable-scratch
(setq unkillable-buffers '("^\\*scratch*\\*$" "^\\*dashboard\\*$"))
(unkillable-scratch 1)


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
  ("C-x r b" . counsel-bookmark)
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
  ;; mac にしたら要調整
  (use-package ivy-migemo
	:init (add-to-list 'load-path "~/.emacs.d/elpa/ivy-migemo")
	:config
	(define-key ivy-minibuffer-map (kbd "M-f") #'ivy-migemo-toggle-fuzzy)
	(define-key ivy-minibuffer-map (kbd "M-i") #'ivy-migemo-toggle-migemo)

	;; If you want to defaultly use migemo on swiper and counsel-find-file:
	(setq ivy-re-builders-alist '((t . ivy--regex-plus)
								  (swiper . ivy-migemo--regex-plus)
								  (counsel-find-file . ivy-migemo--regex-plus)
								  (counsel-recentf . ivy-migemo--regex-plus)
								  (counsel-rg . ivy-migemo--regex-plus))
  										;(counsel-other-function . ivy-migemo--regex-plus)
		  )
	(setq ivy-re-builders-alist '((t . ivy--regex-fuzzy)
								  (swiper-region . ivy-migemo--regex-fuzzy)
								  (counsel-find-file . ivy-migemo--regex-fuzzy)
								  (counsel-recentf . ivy-migemo--regex-fuzzy)
								  (counsel-rg . ivy-migemo--regex-fuzzy))
  										;(counsel-other-function . ivy-migemo--regex-fuzzy)
		  )
	)

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

  ;; ivyのマッチ部分のface (Custom で設定しているからいらない？)
  ;; (custom-set-faces
  ;;  '(ivy-current-match
  ;; 	 ((((class color) (background light))
  ;; 	   :background "#e0daab" :distant-foreground "#000000")
  ;; 	  (((class color) (background dark))
  ;; 	   :background "#404040" :distant-foreground "#abb2bf")))
  ;;  '(ivy-minibuffer-match-face-1
  ;; 	 ((((class color) (background light)) :foreground "#666666")
  ;; 	  (((class color) (background dark)) :foreground "#999999")))
  ;;  '(ivy-minibuffer-match-face-2
  ;; 	 ((((class color) (background light)) :foreground "#c03333" :underline t)
  ;; 	  (((class color) (background dark)) :foreground "#e04444" :underline t)))
  ;;  '(ivy-minibuffer-match-face-3
  ;; 	 ((((class color) (background light)) :foreground "#8585ff" :underline t)
  ;; 	  (((class color) (background dark)) :foreground "#7777ff" :underline t)))
  ;;  '(ivy-minibuffer-match-face-4
  ;; 	 ((((class color) (background light)) :foreground "#439943" :underline t)
  ;; 	  (((class color) (background dark)) :foreground "#33bb33" :underline t))))
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
                              (swiper . my:ivy-migemo-re-builder)
							  (counsel-rg . my:ivy-migemo-re-builder)
							  ))

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
  (setq migemo-options '("-q" "--emacs" "--nonewline"))
  ;; Set your installed path
  (setq migemo-dictionary "/opt/homebrew/Cellar/cmigemo/HEAD-e0f6145/share/migemo/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  (load-library "migemo")
  (migemo-kill)
  (migemo-init)
  )

(use-package org
  :init
  (setq my-org-directory "~/Dropbox/org")
  :mode (("\\.org$" . org-mode))
  :bind (("C-c c" . org-capture)
		 ("C-c a" . org-agenda)
		 ("C-c l" . org-store-link)
		 ("C-c C-l" . org-insert-link)
		 (:map org-mode-map
			   ("M-h" . backward-kill-word)))
  :config
  (setq org-capture-templates
      '(
	;; タスク（スケジュールなし）
	("n" "Non scheduled Task" entry (file+headline "~/Dropbox/org/non_Scheduled_Tasks.org" "Tasks")
	 "** TODO %? \n")
	;; mac にしたら要調整
	;; タスク（スケジュールあり）
	("s" "Scheduled Task" entry (file+headline "~/Dropbox/org/Scheduled_Tasks.org" "Tasks")
	 "** TODO %? \n   SCHEDULED: %^t \n")
	
        ("m" "Memo" checkitem (file+headline "~/Dropbox/org/memo.org" "追記")
	 "- %? \n")
 
        ("t" "Tech" checkitem (file+headline "~/Dropbox/org/tech/TechMemo.org" "追記")
		 "- %? \n")
		("a" "App案" entry (file+headline "~/Dropbox/org/yaritai.org" "アプリ案")
		 "** %? \n")
	    ("y" "Yaritai" entry (file+headline "~/Dropbox/org/yaritai.org" "追記")
		 "** %? \n")
		("i" "Idea" entry (file+headline "~/Dropbox/org/idea.org" "追記")
		 "** %? \n")
		("w" "englishWord" checkitem (file+headline "~/Dropbox/org/english.org" "Word")
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
             "~/Dropbox/org/non_Scheduled_Tasks.org"
             "~/Dropbox/org/Scheduled_Tasks.org"
			 "~/Dropbox/org/memo.org"
			 "~/Dropbox/org/yaritai.org"
             ))
  (add-to-list 'mac-win-target-commands 'org-delete-backward-char)
  (use-package org-download
	:config (setq-default org-download-image-dir "~/Dropbox/org/ltximg/"))
  )

(use-package org-bullets
  :config (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

; org ファイルから qiita に投稿できる markdown を生成するパッケージ
;; コードの書き方
;;; #+name: .emacs
;;; #+begin_src emacs-lisp
;;;   (require 'ox-qmd)
;;; #+end_src
;; note 記法
;;; #+begin_note-info
;;; ノートの本文
;;; #+end_note-info
(use-package ox-qmd
  :config
  (add-to-list 'ox-qmd-language-keyword-alist '(("shell-script" . "sh")
												("python" . "py")))
  )


;;htmlなどにエクスポートするとき
;; (use-package ox-bibtex)
(use-package open-junk-file
  :bind ("C-c j" . open-junk-file)
  :config
  (setq open-junk-file-format "~/Dropbox/org/junk/%Y-%m%d-memo.org")
  ;; (setq open-junk-file-find-file-function 'find-file)  ;; custom経由で設定
  )

;; yasnippet
(use-package yasnippet
  :ensure t
  :init (yas-global-mode)
  :diminish yas-minor-mode
  :config
  (setq yas-snippet-dirs
		'("~/.emacs.d/snippets"
		  "~/.emacs.d/elpa/yasnippet-snippets-20210408.1234/snippets/")))

(use-package ivy-yasnippet
  :ensure t
  :after (yasnippet)
  :bind (("C-c y" . ivy-yasnippet)
         ("C-c C-y" . ivy-yasnippet)))

;; Python
(use-package python
  :bind (("C-c C-a" . pyvenv-activate))
  :hook (python-mode . (lambda () (setq python-indent-offset 4)))
  :config
  (setq python-indent-guess-indent-offset-verbose nil))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package poetry
  :ensure t
  :defer t
  :config
  ;; Checks for the correct virtualenv. Better strategy IMO because the default
  ;; one is quite slow.
  (setq poetry-tracking-strategy 'switch-buffer)
  :hook (python-mode . poetry-tracking-mode))

(use-package numpydoc
  :ensure t
  :bind (:map python-mode-map
              ("C-c C-n" . numpydoc-generate)))

;; c言語関係
;; (use-package irony
;;   :defer t
;;   :commands irony-mode
;;   :init
;;   (add-hook 'c-mode-common-hook 'irony-mode)
;;   (add-hook 'c-mode-common-hook 'flycheck-mode)
;;   (add-hook 'c++-mode-hook 'irony-mode)
;;   :config
;;   ;; C言語用にコンパイルオプションを設定する.
;;   (add-hook 'c-mode-hook
;;             '(lambda ()
;;                (setq irony-additional-clang-options '("-std=c11" "-Wall" "-Wextra"))))

;;   ;; C++言語用にコンパイルオプションを設定する.
;;   (add-hook 'c++-mode-hook
;;             '(lambda ()
;;                (setq irony-additional-clang-options '("-std=c++14" "-Wall" "-Wextra"))))
;;   (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
;;   )

;; web-mode(html 専用)
(use-package web-mode
  :ensure t
  :config
  ;; html を web-mode で開く
  (add-to-list 'auto-mode-alist '("\\.html?$"     . web-mode))
  ;; 要素のハイライト
  (setq web-mode-enable-current-element-highlight t)
  ;; フォントの配色
  (set-face-attribute 'web-mode-doctype-face nil :foreground "Pink3")
  (set-face-attribute 'web-mode-html-tag-face nil :foreground "Blue")
  ;; (set-face-attribute 'web-mode-html-attr-value-face nil :foreground "Black")
  ;; (set-face-attribute 'web-mode-html-attr-name-face nil :foreground "#0FF")
  (set-face-background 'web-mode-current-element-highlight-face "violet")
  ;; タグを自動で閉じる
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-auto-closing t)
  
  ;; ;; .js, .jsx を web-mode で開く
  ;; (add-to-list 'auto-mode-alist '("\\.js[x]?$" . web-mode))

  ;; ;; 拡張子 .js でもJSX編集モードに
  ;; (setq web-mode-content-types-alist
  ;; 		'(("jsx" . "\\.js[x]?\\'")))
  ;; インデント
  (add-hook 'web-mode-hook
			'(lambda ()
               (setq web-mode-attr-indent-offset nil)
               (setq web-mode-markup-indent-offset 2)
               (setq web-mode-css-indent-offset 2)
               (setq web-mode-code-indent-offset 2)
               (setq web-mode-sql-indent-offset 2)
               (setq indent-tabs-mode nil)
               (setq tab-width 2)
			   ))
  )

(use-package js2-mode
  :ensure t
  :init
    (add-to-list 'auto-mode-alist '("\.js$" . js2-mode))
  :hook
  (js2-mode . eglot-ensure))

;; java
;;(eval-after-load 'eglot-java
;;  (progn
;;    (require 'eglot-java)
;;    (setq eglot-java-prefix-key "C-c l")
;;    (setq eglot-java-default-bindings-enabled t)
;;    '(eglot-java-init)))

;; quickrun
(defun my-quickrun ()
  ;; リージョンがアクティブならquickrun-region
  (interactive)
  (if (region-active-p)
	  (quickrun-region (region-beginning) (region-end))
	(quickrun-shell)))
(use-package quickrun
  :ensure t
  :bind* ("<f1>" . my-quickrun)
  :config
  (quickrun-add-command "python"
  '((:command . "python3"))
  :override t)
  )


;; 追加設定(https://ebzzry.com/en/emacs-pairs/)
;; (defmacro def-pairs (pairs)
;;   "Define functions for pairing. PAIRS is an alist of (NAME . STRING)
;; conses, where NAME is the function name that will be created and
;; STRING is a single-character string that marks the opening character.

;;   (def-pairs ((paren . \"(\")
;;               (bracket . \"[\"))

;; defines the functions WRAP-WITH-PAREN and WRAP-WITH-BRACKET,
;; respectively."
;;   `(progn
;;      ,@(loop for (key . val) in pairs
;;              collect
;;              `(defun ,(read (concat
;;                              "wrap-with-"
;;                              (prin1-to-string key)
;;                              "s"))
;;                   (&optional arg)
;;                 (interactive "p")
;;                 (sp-wrap-with-pair ,val)))))

;; (def-pairs ((paren . "(")
;;             (bracket . "[")
;;             (brace . "{")
;;             (single-quote . "'")
;;             (double-quote . "\"")
;;             (back-quote . "`")))

;; (bind-keys
;;  :map smartparens-mode-map
;;  ("C-M-a" . sp-beginning-of-sexp)
;;  ("C-M-e" . sp-end-of-sexp)

;;  ("C-<down>" . sp-down-sexp)
;;  ("C-<up>"   . sp-up-sexp)
;;  ("M-<down>" . sp-backward-down-sexp)
;;  ("M-<up>"   . sp-backward-up-sexp)

;;  ("C-M-f" . sp-forward-sexp)
;;  ("C-M-b" . sp-backward-sexp)

;;  ("C-M-n" . sp-next-sexp)
;;  ("C-M-p" . sp-previous-sexp)

;;  ("C-S-f" . sp-forward-symbol)
;;  ("C-S-b" . sp-backward-symbol)

;;  ("C-<right>" . sp-forward-slurp-sexp)
;;  ("M-<right>" . sp-forward-barf-sexp)
;;  ("C-<left>"  . sp-backward-slurp-sexp)
;;  ("M-<left>"  . sp-backward-barf-sexp)

;;  ("C-M-t" . sp-transpose-sexp)
;;  ("C-M-k" . sp-kill-sexp)
;;  ("C-k"   . sp-kill-hybrid-sexp)
;;  ("M-k"   . sp-backward-kill-sexp)
;;  ("C-M-w" . sp-copy-sexp)
;;  ("C-M-d" . delete-sexp)

;;  ("M-<backspace>" . backward-kill-word)
;;  ("C-<backspace>" . sp-backward-kill-word)
;;  ([remap sp-backward-kill-word] . backward-kill-word)

;;  ("M-[" . sp-backward-unwrap-sexp)
;;  ("M-]" . sp-unwrap-sexp)

;;  ("C-x C-t" . sp-transpose-hybrid-sexp)

;;  ("C-c ("  . wrap-with-parens)
;;  ("C-c ["  . wrap-with-brackets)
;;  ("C-c {"  . wrap-with-braces)
;;  ("C-c '"  . wrap-with-single-quotes)
;;  ("C-c \"" . wrap-with-double-quotes)
;;  ("C-c _"  . wrap-with-underscores)
;;  ("C-c `"  . wrap-with-back-quotes))


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
;; (show-paren-mode 1)
(show-smartparens-global-mode 1)
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
  :diminish company-mode
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
  (define-key company-active-map (kbd "C-n") nil)
  (define-key company-active-map (kbd "C-p") nil)
  (define-key company-active-map (kbd "M-n") 'company-select-next)
  (define-key company-active-map (kbd "M-p") 'company-select-previous)
  (defun my-company-inhibit-idle-begin ()
	(setq-local company-begin-commands nil))
  (add-hook 'org-mode-hook #'my-company-inhibit-idle-begin)
  (add-hook 'text-mode-hook #'my-company-inhibit-idle-begin)
  )

;; comapny-box(まだアイコンが一種類しかでない、背景がおかしい)
(use-package company-box
  :diminish
  :hook (company-mode . company-box-mode)
  :init (setq company-box-icons-alist 'company-box-icons-all-the-icons)
  :config
  ;; (setq company-box-backends-colors nil)
  ;; (setq company-box-show-single-candidate t)
  (setq company-box-backends-colors '((company-capf .  (:candidate "blue" :annotation some-face :selected (:background "orange" :foreground "black")))
									  (company-semantic . (:candidate "blue" :annotation some-face :selected (:background "orange" :foreground "black")))))
  (setq company-box-max-candidates 50)

  (defun company-box-icons--elisp (candidate)
    (when (derived-mode-p 'emacs-lisp-mode)
      (let ((sym (intern candidate)))
        (cond ((fboundp sym) 'Function)
              ((featurep sym) 'Module)
              ((facep sym) 'Color)
              ((boundp sym) 'Variable)
              ((symbolp sym) 'Text)
              (t . nil)))))

  (with-eval-after-load 'all-the-icons
    (declare-function all-the-icons-faicon 'all-the-icons)
    (declare-function all-the-icons-fileicon 'all-the-icons)
    (declare-function all-the-icons-material 'all-the-icons)
    (declare-function all-the-icons-octicon 'all-the-icons)
    (setq company-box-icons-all-the-icons
          `((Unknown . ,(all-the-icons-material "find_in_page" :height 0.7 :v-adjust -0.15))
            (Text . ,(all-the-icons-faicon "book" :height 0.68 :v-adjust -0.15))
            (Method . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
            (Function . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
            (Constructor . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
            (Field . ,(all-the-icons-faicon "tags" :height 0.65 :v-adjust -0.15 :face 'font-lock-warning-face))
            (Variable . ,(all-the-icons-faicon "tag" :height 0.7 :v-adjust -0.05 :face 'font-lock-warning-face))
            (Class . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01 :face 'font-lock-constant-face))
            (Interface . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01))
            (Module . ,(all-the-icons-octicon "package" :height 0.7 :v-adjust -0.15))
            (Property . ,(all-the-icons-octicon "package" :height 0.7 :v-adjust -0.05 :face 'font-lock-warning-face)) ;; Golang module
            (Unit . ,(all-the-icons-material "settings_system_daydream" :height 0.7 :v-adjust -0.15))
            (Value . ,(all-the-icons-material "format_align_right" :height 0.7 :v-adjust -0.15 :face 'font-lock-constant-face))
            (Enum . ,(all-the-icons-material "storage" :height 0.7 :v-adjust -0.15 :face 'all-the-icons-orange))
            (Keyword . ,(all-the-icons-material "filter_center_focus" :height 0.7 :v-adjust -0.15))
            (Snippet . ,(all-the-icons-faicon "code" :height 0.7 :v-adjust 0.02 :face 'font-lock-variable-name-face))
            (Color . ,(all-the-icons-material "palette" :height 0.7 :v-adjust -0.15))
            (File . ,(all-the-icons-faicon "file-o" :height 0.7 :v-adjust -0.05))
            (Reference . ,(all-the-icons-material "collections_bookmark" :height 0.7 :v-adjust -0.15))
            (Folder . ,(all-the-icons-octicon "file-directory" :height 0.7 :v-adjust -0.05))
            (EnumMember . ,(all-the-icons-material "format_align_right" :height 0.7 :v-adjust -0.15 :face 'all-the-icons-blueb))
            (Constant . ,(all-the-icons-faicon "tag" :height 0.7 :v-adjust -0.05))
            (Struct . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01 :face 'font-lock-constant-face))
            (Event . ,(all-the-icons-faicon "bolt" :height 0.7 :v-adjust -0.05 :face 'all-the-icons-orange))
            (Operator . ,(all-the-icons-fileicon "typedoc" :height 0.65 :v-adjust 0.05))
            (TypeParameter . ,(all-the-icons-faicon "hashtag" :height 0.65 :v-adjust 0.07 :face 'font-lock-const-face))
            (Template . ,(all-the-icons-faicon "code" :height 0.7 :v-adjust 0.02 :face 'font-lock-variable-name-face))))))

;; (use-package company-posframe
;;     :ensure t
;;     :diminish company-posframe-mode
;;     :after company
;;     :config
;;     (company-posframe-mode 1))


;; (use-package company-box
;;   :diminish company-box-mode
;;   :after (company all-the-icons)
;;   :hook ((company-mode . company-box-mode))
;;   :custom
;;   (company-box-icons-alist 'company-box-icons-all-the-icons)
;;   (company-box-doc-enable nil))


;; (use-package company-irony
;;   :defer t
;;   :config
;;   ;; companyの補完のバックエンドにironyを使用する.
;;   (add-to-list 'company-backends '(company-irony-c-headers company-irony))
;;   )

(use-package company-math
  :ensure t
  :demand t
  :after (company yatex)
  :config
  (push 'company-math-symbols-latex company-backends)
  (push 'company-latex-commands company-backends))
;;elpy
;; (use-package elpy
;;   :ensure t
;;   :init (elpy-enable)
;;   :bind (:map elpy-mode-map
;; 			  ("C-c C-n" . flycheck-next-error)
;; 			  ("C-c C-p" . flycheck-previous-error)
;; 			  ("C-c C-l" . flycheck-list-errors))
;;   :config
;;   (when (load "flycheck" t t)
;; 	(setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
;; 	(add-hook 'elpy-mode-hook 'flycheck-mode))
;;   (setq elpy-rpc-backend "jedi")
;;   (setq elpy-rpc-python-command "python3")
;;   (setq flycheck-flake8-maximum-line-length 200))

;; flymake の拡張
;; mac にしたら要調整
(use-package flymake-diagnostic-at-point
  :ensure t
  :after flymake
  :config
  (add-hook 'flymake-mode-hook #'flymake-diagnostic-at-point-mode)
  (setq flymake-diagnostic-at-point-error-prefix "🧐 "))


;; ivy-xref(動いてない？)
(use-package ivy-xref
  :ensure t
  :config
  ;; xref initialization is different in Emacs 27 - there are two different
;; variables which can be set rather than just one
(when (>= emacs-major-version 27)
  (setq xref-show-definitions-function #'ivy-xref-show-defs))
;; Necessary in Emacs <27. In Emacs 27 it will affect all xref-based
;; commands other than xref-find-definitions (e.g. project-find-regexp)
;; as well
(setq xref-show-xrefs-function #'ivy-xref-show-xrefs))

;;smart jump
(use-package smart-jump
 :ensure t
 :config
 (smart-jump-setup-default-registers))

; eglot
(use-package eglot
  :ensure t
  :hook
  (python-mode . eglot-ensure)
  :bind (:map eglot-mode-map
  			  ("C-c e n" . eglot-rename))
  :config
  ;; (add-to-list 'eglot-server-programs '(python-mode . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs '(web-mode . ("/opt/homebrew/bin/typescript-language-server")))
  )

;; メモリの使用量がやばいので一旦保留
;; (use-package copilot
;;   :init (add-to-list 'load-path "~/.emacs.d/elpa/copilot.el/")
;;   :hook
;;   (prog-mode . copilot-mode)
;;   :config
;;   (with-eval-after-load 'company
;; 	;; disable inline previews
;; 	(delq 'company-preview-if-just-one-frontend company-frontends)
  
;; 	(define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
;; 	(define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))
;;   )

;; lsp-mode(なぜかこれをrequireしないとswiperのエラーが出る)(macだと出なかった)
;; (use-package lsp-python-ms
  ;; :ensure t
  ;; :init (setq lsp-python-ms-auto-install-server t)
  ;; :hook
  ;; (python-mode . (lambda ()
  ;;                         (require 'lsp-python-ms)
  ;;                         (lsp)))
  ;; (lsp-managed-mode . (lambda () (setq-local company-backends '(company-capf))))
;; )


;;org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (C . t)
   (python . t)
   (shell . t)
   (js . t)))
(setq org-babel-python-command "python3")
(setq org-edit-src-content-indentation 0)

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
  :init (setq YaTeX-inhibit-prefix-letter t)
  :config
  (add-to-list 'auto-mode-alist '("\\.tex\\'" . yatex-mode)) ;;auto-mode-alistへの追加
  (setq tex-command "latexmk -pvc")
  (setq dvi2-command "evince")
  (setq YaTeX-on-the-fly-preview-interval nil)
  (setq bibtex-command "pbibtex")    ;; 自分の環境に合わせて""内を変えてください
  ;; \sectionの色の設定（うまくいかん）
  ;;(setq YaTeX-hilit-sectioning-face '(light時のforecolor/backcolor dark時のforecolor/backcolor))
  (setq YaTeX-hilit-sectioning-face '(LightSkyBlue/LightGray LightGray/Black))
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
			   "\\documentclass[uplatex, jadriver=standard]{bxjsarticle}"
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


;; モードライン系

;; doom-modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
)

;; (use-package spaceline-all-the-icons 
;;   :after spaceline
;;   :config (spaceline-all-the-icons-theme))

;; nyan-mode
;; (use-package nyan-mode
;;   :ensure t
;;   :init
;;   (nyan-mode t)
;;   ;; (nyan-start-animation)
;;   ;; (nyan-start-music)
;;   )

;; Pokémon
;; ポケモンのリスト(https://github.com/RyanMillerC/poke-line/blob/master/docs/pokemon.md)
(use-package poke-line
  :ensure t
  :config
  (poke-line-global-mode 1)
  (setq-default poke-line-pokemon "wobbuffet")
  ;; (poke-line-set-random-pokemon)
  )

;; csv のソートを降順に
(setq csv-descending t)

;; docker
(use-package docker
  :ensure t
  :bind ("C-c d" . docker))
;; Dockerfile-mode
(use-package dockerfile-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode)))
;; docker-compose-mode
(use-package yaml-mode
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\.yml$" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\.yaml$" . yaml-mode))
  )
(use-package docker-compose-mode
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("docker-compose.yml" . docker-compose-mode))
  (add-to-list 'auto-mode-alist '("docker-compose.yaml" . docker-compose-mode))
  )

;; vterm
(use-package vterm
  :bind
  ("C-:" . vterm-toggle)
  (:map vterm-mode-map
   ("C-M-:" . my/vterm-new-buffer-in-current-window)
   ("C-<return>" . vterm-toggle-insert-cd)
   ([remap iflipb-next-buffer] . vterm-toggle-forward)
   ([remap iflipb-previous-buffer] . vterm-toggle-backward))
  :config
  (setq vterm-buffer-name-string "vterm: %s")
  )
(use-package vterm-toggle
  :ensure t
  :config
  (setq vterm-toggle-scope 'project)
  ;; Show vterm buffer in the window located at bottom
  (add-to-list 'display-buffer-alist
               '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
                 (display-buffer-reuse-window display-buffer-in-direction)
                 (direction . bottom)
                 (reusable-frames . visible)
                 (window-height . 0.2)))
  ;; Above display config affects all vterm command, not only vterm-toggle
  (defun my/vterm-new-buffer-in-current-window()
    (interactive)
    (let ((display-buffer-alist nil))
            (vterm)))
  )
;; undo-tree
(use-package undo-tree
  :ensure t
  :bind (("C-M-/" . undo-tree-redo) ("C-/" . undo-tree-undo))
  :config
  ;; Prevent undo tree files from polluting your git repo
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))))
(global-undo-tree-mode t)

;;neotree（丸パクリ：https://qiita.com/minoruGH/items/2034cad4efe8c5dee4d4）
(use-package neotree
  :ensure t
  :init
  (setq-default neo-keymap-style 'concise)
  :config
  (setq neo-smart-open t)
  (setq neo-create-file-auto-open t)
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  (bind-key [f8] 'neotree-toggle)
  (bind-key "RET" 'neotree-enter-hide neotree-mode-map)
  (bind-key "a" 'neotree-hidden-file-toggle neotree-mode-map)
  (bind-key "<left>" 'neotree-select-up-node neotree-mode-map)
  (bind-key "<right>" 'neotree-change-root neotree-mode-map))


;; Change neotree's font size
;; Tips from https://github.com/jaypei/emacs-neotree/issues/218
(defun neotree-text-scale ()
  "Text scale for neotree."
  (interactive)
  (text-scale-adjust 0)
  (text-scale-decrease 1)
  (message nil))
(add-hook 'neo-after-create-hook
      (lambda (_)
        (call-interactively 'neotree-text-scale)))

;; neotree enter hide
;; Tips from https://github.com/jaypei/emacs-neotree/issues/77
(defun neo-open-file-hide (full-path &optional arg)
  "Open file and hiding neotree.
The description of FULL-PATH & ARG is in `neotree-enter'."
  (neo-global--select-mru-window arg)
  (find-file full-path)
  (neotree-hide))

(defun neotree-enter-hide (&optional arg)
  "Neo-open-file-hide if file, Neo-open-dir if dir.
The description of ARG is in `neo-buffer--execute'."
  (interactive "P")
  (neo-buffer--execute arg 'neo-open-file-hide 'neo-open-dir))

(defun mail-address_to_clip ()
  "e-mail to clipboard"
  (interactive)
  (kill-new "hiratako.0530@gmail.com")
  (message "Copied e-mail to clipboard"))
(global-set-key (kbd "<f7>") 'mail-address_to_clip)

(defun copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))
(global-set-key (kbd "<f6>") 'copy-file-name-to-clipboard)

(random t)
(if (< (random 10) 5) (setq comd "echo-sd") (setq comd "echo-sd --center GNUEmacs"))  ;  https://fumiyas.github.io/2013/12/25/echo-sd.sh-advent-calendar.html
(defun display-startup-echo-area-message ()
  (shell-command comd))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(copilot-idle-delay 2)
 '(custom-safe-themes
   '("b4ba3e1bba2e303265eb3e9753215408e75e031f7c894786ad04cabef46ff94c" "28caf31770f88ffaac6363acfda5627019cac57ea252ceb2d41d98df6d87e240" "f3455b91943e9664af7998cc2c458cfc17e674b6443891f519266e5b3c51799d" default))
 '(eglot-java-server-install-dir "/opt/homebrew/Cellar/jdtls/1.21.0/libexec/")
 '(espotify-client-id "18a882a383ac4a7c9b067444cec1a5e9")
 '(espotify-client-secret "f74c6dd514a2428da821a85611d49a71")
 '(ivy-prescient-sort-commands
   '(counsel-M-x :not swiper swiper-isearch ivy-switch-buffer swiper-region))
 '(numpydoc-insert-examples-block nil)
 '(numpydoc-insertion-style 'yas)
 '(open-junk-file-find-file-function 'find-file)
 '(package-selected-packages
   '(nerd-icons-completion spaceline-all-the-icons nano-modeline org-download flymake-diagnostic-at-point dap-mode lsp-java eglot-java expand-region region-bindings-mode multiple-cursors editorconfig poetry numpydoc ox-qmd unkillable-scratch org-bullets docker-compose-mode yaml-mode twittering-mode js2-mode web-mode docker dockerfile-mode tramp company-math vterm dracula-theme poke-line doom-modeline grip-mode smartparens smart-jump eglot lsp-ui lsp-python-ms lsp-mode csv-mode yatex yasnippet-snippets ivy-migemo ivy-spotify counsel-tramp iflipb magit nyan-mode ivy-xref dumb-jump company-quickhelp package-utils company-box ivy-prescient all-the-icons-dired all-the-icons all-the-icons-ivy markdown-preview-mode ivy-yasnippet quickrun company-irony diminish counsel swiper ivy open-junk-file use-package mozc migemo helm-core flycheck elscreen elpy))
 '(show-paren-style 'parenthesis))
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
