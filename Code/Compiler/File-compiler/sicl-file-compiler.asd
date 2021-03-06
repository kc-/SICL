(cl:in-package #:asdf-user)

(defsystem #:sicl-file-compiler
  :depends-on (#:concrete-syntax-tree
               #:eclector
               #:eclector-concrete-syntax-tree
               #:cleavir-code-utilities
               #:cleavir-generate-ast
               #:sicl-simple-environment
               #:cleavir-cst-to-ast)
  :serial t
  :components
  ((:file "packages")
   (:file "client")
   (:file "customization")
   (:file "ast-from-file")
   (:file "simplify-ast")))
