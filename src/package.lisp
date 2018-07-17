;;;; src/package.lisp

(defpackage #:cl-batteries
  (:use #:cl)
  (:export #:battery-info
	   #:linux/battery-details
	   #:linux/list-batteries))
