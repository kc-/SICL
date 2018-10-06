(cl:in-package #:sicl-new-boot-phase-0)

;;; This class will be the metaclass of all the MOP classes defined in
;;; E1.  We define it as a subclass of the host
;;; FUNCALLABLE-STANDARD-CLASS so that instances of it can be used as
;;; functions, and so that we avoid any problems with incompatible
;;; superclasses and metaclasses.
;;;
;;; Furthermore, this class will be the specializer of the :AROUND
;;; method on SHARED-INITIALIZE that handles the class-initialization
;;; protocol.  Recall that this :AROUND method handles the definitions
;;; of slot readers and slot writers defined in class slots.
;;; Therefore, that aspect of the host class-initialization protocol
;;; will not be invoked.
(defclass funcallable-standard-class
    (closer-mop:funcallable-standard-class)
  ())

;;; This method is apparently necessary so that we are allowed to
;;; make instances of our new class.
(defmethod closer-mop:validate-superclass
    ((class funcallable-standard-class)
     (superclass closer-mop:funcallable-standard-class))
  t)

(defun import-mop-function (name environment)
  (let ((host-name (find-symbol (string name) (find-package '#:closer-mop)))
        (sicl-name (find-symbol (string name) (find-package '#:sicl-clos))))
    (setf (sicl-genv:fdefinition sicl-name environment)
          (fdefinition host-name))))

(defun import-mop-functions (names environment)
  (loop for name in names
        do (import-mop-function name environment)))

(defun import-from-host (boot)
  (with-accessors ((e0 sicl-new-boot:e0)) boot
    (import-package-from-host 'sicl-clos e0)
    (import-functions-from-host
     '(sicl-genv:find-class
       sicl-genv:typep
       sicl-genv:fboundp
       sicl-genv:fdefinition
       cleavir-code-utilities:proper-list-p
       cleavir-code-utilities:separate-function-body
       cleavir-code-utilities:required
       cleavir-code-utilities:parse-specialized-lambda-list
       error format
       make-instance
       add-method
       mapcar subseq 1+ elt position-if copy-list)
     e0)
    (setf (sicl-genv:special-variable '*trace-output* e0 t) *trace-output*)
    (import-mop-functions
     '(#:add-direct-subclass
       #:generic-function-method-class
       #:class-prototype
       #:method-function
       #:validate-superclass
       #:direct-slot-definition-class)
     e0)
    (setf (sicl-genv:fdefinition 'sicl-clos:make-method-lambda e0)
          #'sicl-clos::make-method-lambda-default)
    ;; Import class T so that it can be found when we need to create
    ;; the class T as a specializer for unspecialized method parameters.
    (setf (sicl-genv:find-class 't e0)
          (find-class 't))
    ;; Create classes in E0 that are potential metaclasses for the
    ;; classes we will create in phase 1.  It doesn't matter much how
    ;; these metaclasses are related by inheritance, so we just make
    ;; them all the same class, i.e. our special metaclass defined
    ;; above.
    (setf (sicl-genv:find-class 'standard-class e0)
          (find-class 'funcallable-standard-class))
    (setf (sicl-genv:find-class 'sicl-clos:funcallable-standard-class e0)
          (find-class 'funcallable-standard-class))
    (setf (sicl-genv:find-class 'sicl-clos:built-in-class e0)
          (find-class 'funcallable-standard-class))
    ;; We need to create methods on host generic functions such as
    ;; SHARED-INITIALIZE, so we need to instantiate the host class
    ;; STANDARD-METHOD.  For that reason, we import it from the host.
    (setf (sicl-genv:find-class 'standard-method e0)
          (find-class 'standard-method))
    ;; Import the class STANDARD-GENERIC-FUNCTION so that we can
    ;; create instance of it.
    (setf (sicl-genv:find-class 'standard-generic-function e0)
          (find-class 'standard-generic-function))
    ;; When we create class metaobjects, we need to instantiate the
    ;; class STANDARD-DIRECT-SLOT-DEFINITION, so we import it here.
    (setf (sicl-genv:find-class 'sicl-clos:standard-direct-slot-definition e0)
          (find-class 'closer-mop:standard-direct-slot-definition))))

(defun enable-defmethod (boot)
  (with-accessors ((e0 sicl-new-boot:e0)) boot
    (load-file "CLOS/make-specializer.lisp" e0)
    (load-file "CLOS/make-method-for-generic-function.lisp" e0)
    (load-file "CLOS/ensure-method.lisp" e0)
    (load-file "CLOS/defmethod-support.lisp" e0)
    (load-file "CLOS/defmethod-defmacro.lisp" e0)))

(defun add-readers (environment function-names class slot-name slot-definition)
  (let ((function (compile nil `(lambda (args next-methods)
                                  (declare (ignore next-methods))
                                  (slot-value (car args) ',slot-name)))))
    (loop for function-name in function-names
          for gf = (sicl-genv:fdefinition function-name environment)
          for method = (make-instance 'closer-mop:standard-reader-method
                         :lambda-list '(object)
                         :qualifiers '()
                         :specializers (list class)
                         :function function
                         :slot-definition slot-definition)
          do (add-method gf method))))

(defun add-writers (environment function-names class slot-name slot-definition)
  (let ((function (compile nil `(lambda (args next-methods)
                                  (declare (ignore next-methods))
                                  (setf (slot-value (cadr args) ',slot-name)
                                        (car arguments))))))
    (loop for function-name in function-names
          for gf = (sicl-genv:fdefinition function-name environment)
          for method = (make-instance 'closer-mop:standard-writer-method
                         :lambda-list '(new-value object)
                         :qualifiers '()
                         :specializers (list (find-class t) class)
                         :function function
                         :slot-definition slot-definition)
          do (add-method gf method))))

(defun enable-class-initialization (boot)
  (with-accessors ((e0 sicl-new-boot:e0) (e2 sicl-new-boot:e2)) boot
    (defmethod initialize-instance ((class funcallable-standard-class)
                                    &rest arguments
                                    &key
                                      direct-default-initargs
                                      direct-superclasses
                                      direct-slots
                                    &allow-other-keys)
      (let ((new-direct-slots
              (loop for slot-spec in direct-slots
                    for spec = (copy-list slot-spec)
                    do (remf spec :readers)
                       (remf spec :writers)
                    collect spec)))
        (apply #'call-next-method
               class
               :direct-superclasses direct-superclasses
               :direct-default-initargs direct-default-initargs
               :direct-slots new-direct-slots
               arguments)
        (loop for slot-spec in direct-slots
              for slot = (apply #'make-instance
                                'closer-mop:standard-direct-slot-definition
                                slot-spec)
              for slot-name = (getf slot-spec :name)
              for readers = (getf slot-spec :readers)
              for writers = (getf slot-spec :writers)
              do (add-readers e2 readers class slot-name slot)
                 (add-readers e2 writers class slot-name slot))))))

(defun boot-phase-0 (boot)
  (format *trace-output* "Start of phase 0~%")
  (import-from-host boot)
  (with-accessors ((e0 sicl-new-boot:e0) (e1 sicl-new-boot:e1)) boot
    (enable-defmethod boot)))
