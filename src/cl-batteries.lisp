;;;; src/cl-batteries.lisp

(in-package #:cl-batteries)

(defun slurp-line (path &key transform)
  (with-open-file (s path)
    (if transform
	(funcall transform (read-line s))
	(read-line s))))

(defun linux/list-batteries ()
  (remove-if
   (lambda (name) (> 3 (length name)))
   (mapcar
    (lambda (p)
      (car (last (pathname-directory p))))
    (cl-fad:list-directory "/sys/class/power_supply/"))))

(defun linux/key->transform (k)
  (cond
    ((member k '(:capacity-level :type :status))
     (lambda (v) (intern (string-upcase v) :keyword)))
    ((member k '(:alarm :capacity :cycle-count :energy-full :energy-full-design :energy-now :power-now :voltage-min-design :voltage-now))
     (lambda (v) (values (parse-integer v))))
    ((eq :present k)
     (lambda (v) (string= "1" v)))))

(defun linux/battery-details (battery-name)
  (let ((path (make-pathname
	       :directory (concatenate 'list
				       (pathname-directory #P"/sys/class/power_supply/")
				       (list battery-name)))))
    (when (cl-fad:directory-exists-p path)
      (mapcar
       (lambda (p)
	 (let ((key (intern (string-upcase (substitute #\- #\_ (file-namestring p))) :keyword)))
	   (cons key (slurp-line p :transform (linux/key->transform key)))))
       (remove-if
	(lambda (p)
	  (let ((name (file-namestring p)))
	    (or (zerop (length name))
		(string= "uevent" name))))
	(cl-fad:list-directory path))))))

(defun battery-info ()
  #+linux(mapcar
	  (lambda (name)
	    (let* ((deets (linux/battery-details name))
		   (info `((:name . ,name)
			   (:percentage . ,(assoc :capacity deets))
			   (:charging . ,(not (eq :discharging (assoc :status deets)))))))
	      (cons name (cons (cons :name name) info))))
	  (linux/list-batteries)))
