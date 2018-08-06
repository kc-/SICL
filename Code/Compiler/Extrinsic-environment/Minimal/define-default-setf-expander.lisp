(cl:in-package #:sicl-minimal-extrinsic-environment)

(defun define-default-setf-expander (environment)
  (setf (sicl-genv:default-setf-expander environment)
	(lambda (form environment)
          (declare (ignore environment))
	  (if (symbolp form)
	      (let ((new (gensym)))
		(values '()
			'()
			`(,new)
			`(setq ,form ,new)
			form))
	      (let ((temps (loop for arg in (rest form) collect (gensym)))
		    (new (gensym)))
		(values temps
			(rest form)
			`(,new)
			`(funcall #'(setf ,(first form)) ,new ,@temps)
			`(,(first form) ,@temps)))))))