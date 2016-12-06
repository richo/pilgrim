(module pilgrim
    (export *)
  (import scheme)
  (import chicken)
  (import extras)
  (import data-structures)
  (use srfi-13)
  (use srfi-18)
  (use tcp6)
  (use posix)
  (use utils)

  (include "response")
  (include "request")

  (define (handle in out handler)
    (let ((request (make-request in))
          (response (make-response)))
      (if request
	  (write-response
	   (handler request response)
	   out))
      (close-input-port in)
      (close-output-port out)))

  (define (handle-in-thread in out handler)
    (thread-start! (make-thread (lambda () (handle in out handler)))))

  (define (start port threaded? handler)
    (letrec ((sock (tcp-listen port))
	     (mainloop (lambda ()
			 (let-values (((s-in s-out) (tcp-accept sock)))
			   ((if threaded? handle-in-thread handle) s-in s-out handler)
			   (mainloop)))))
      (mainloop))))
