(cl:in-package #:sicl-boot-phase-3)

(defun boot (boot)
  (format *trace-output* "Start phase 3~%")
  (with-accessors ((e2 sicl-boot:e2) (e3 sicl-boot:e3)) boot
    (change-class e3 'environment)
    (set-up-environments boot)
    (define-make-instance boot)))