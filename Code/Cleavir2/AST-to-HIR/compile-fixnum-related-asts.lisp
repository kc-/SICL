(cl:in-package #:cleavir-ast-to-hir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FIXNUM-ADD-AST.

(defmethod compile-ast ((ast cleavir-ast:fixnum-add-ast) context)
  (assert-context ast context 0 2)
  (let ((temp1 (make-temp))
        (temp2 (make-temp))
        (result (find-or-create-location (cleavir-ast:variable-ast ast))))
    (compile-ast
     (cleavir-ast:arg1-ast ast)
     (clone-context
      context
      :result temp1
      :successor
      (compile-ast
       (cleavir-ast:arg2-ast ast)
       (clone-context
        context
        :result temp2
        :successor
        (make-instance 'cleavir-ir:fixnum-add-instruction
          :inputs (list temp1 temp2)
          :output result
          :successors (successors context))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FIXNUM-SUB-AST.

(defmethod compile-ast ((ast cleavir-ast:fixnum-sub-ast) context)
  (assert-context ast context 0 2)
  (let ((temp1 (make-temp))
        (temp2 (make-temp))
        (result (find-or-create-location (cleavir-ast:variable-ast ast))))
    (compile-ast
     (cleavir-ast:arg1-ast ast)
     (clone-context
      context
      :result  temp1
      :successor (compile-ast
                  (cleavir-ast:arg2-ast ast)
                  (clone-context
                   context
                   :result temp2
                   :successor (make-instance 'cleavir-ir:fixnum-sub-instruction
                                :inputs (list temp1 temp2)
                                :output result
                                :successors (successors context))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FIXNUM-LESS-AST.

(defmethod compile-ast ((ast cleavir-ast:fixnum-less-ast) context)
  (assert-context ast context 0 2)
  (let ((temp1 (make-temp))
        (temp2 (make-temp)))
    (compile-ast
     (cleavir-ast:arg1-ast ast)
     (clone-context
      context
      :result temp1
      :successor (compile-ast
                  (cleavir-ast:arg2-ast ast)
                  (clone-context
                   context
                   :result temp2
                   :successor (make-instance 'cleavir-ir:fixnum-less-instruction
                                :inputs (list temp1 temp2)
                                :successors (successors context))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FIXNUM-NOT-GREATER-AST.

(defmethod compile-ast ((ast cleavir-ast:fixnum-not-greater-ast) context)
  (assert-context ast context 0 2)
  (let ((temp1 (make-temp))
        (temp2 (make-temp)))
    (compile-ast
     (cleavir-ast:arg1-ast ast)
     (clone-context
      context
      :result temp1
      :successor (compile-ast
                  (cleavir-ast:arg2-ast ast)
                  (clone-context
                   context
                   :result temp2
                   :successor (make-instance 'cleavir-ir:fixnum-not-greater-instruction
                                :inputs (list temp1 temp2)
                                :successors (successors context))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FIXNUM-GREATER-AST.

(defmethod compile-ast ((ast cleavir-ast:fixnum-greater-ast) context)
  (assert-context ast context 0 2)
  (let ((temp1 (make-temp))
        (temp2 (make-temp)))
    (compile-ast
     (cleavir-ast:arg1-ast ast)
     (clone-context
      context
      :result temp1
      :successor (compile-ast
                  (cleavir-ast:arg2-ast ast)
                  (clone-context
                   context
                   :result temp2
                   :successor (make-instance 'cleavir-ir:fixnum-less-instruction
                                :inputs (list temp2 temp1)
                                :successors (successors context))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FIXNUM-NOT-LESS-AST.

(defmethod compile-ast ((ast cleavir-ast:fixnum-not-less-ast) context)
  (assert-context ast context 0 2)
  (let ((temp1 (make-temp))
        (temp2 (make-temp)))
    (compile-ast
     (cleavir-ast:arg1-ast ast)
     (clone-context
      context
      :result temp1
      :successor (compile-ast
                  (cleavir-ast:arg2-ast ast)
                  (clone-context
                   context
                   :result temp2
                   :successor (make-instance 'cleavir-ir:fixnum-not-greater-instruction
                                :inputs (list temp2 temp1)
                                :successors (successors context))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FIXNUM-EQUAL-AST.

(defmethod compile-ast ((ast cleavir-ast:fixnum-equal-ast) context)
  (assert-context ast context 0 2)
  (let ((temp1 (make-temp))
        (temp2 (make-temp)))
    (compile-ast
     (cleavir-ast:arg1-ast ast)
     (clone-context
      context
      :result temp1
      :successor  (compile-ast
                   (cleavir-ast:arg2-ast ast)
                   (clone-context
                    context
                    :result temp2
                    :successor (make-instance 'cleavir-ir:fixnum-equal-instruction
                                 :inputs (list temp2 temp1)
                                 :successors (successors context))))))))
