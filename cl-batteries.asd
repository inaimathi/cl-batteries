;;;; cl-battery.asd

(asdf:defsystem #:cl-batteries
  :description "Basic, multi-battery info"
  :author "inaimathi <leo.zovic@gmail.com>"
  :license "MIT Expat"
  :version "0.0.1"
  :serial t
  :depends-on (#:cl-fad)
  :components ((:module
		src :components
		((:file "package")
		 (:file "cl-batteries")))))

(asdf:defsystem #:cl-batteries-test
  :description "Test suite for :cl-batteries"
  :author "inaimathi <leo.zovic@gmail.com>"
  :license "MIT Expat"
  :serial t
  :depends-on (#:cl-batteries #:test-utils)
  :defsystem-depends-on (#:prove-asdf)
  :components ((:module
                test :components
                ((:file "package")
                 (:test-file "cl-batteries"))))
  :perform (test-op
	    :after (op c)
	    (funcall (intern #.(string :run) :prove) c)))
