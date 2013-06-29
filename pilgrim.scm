(use srfi-13)
(use srfi-18)
(use tcp)
(use posix)
(use utils)

(load-relative "response.scm")
(load-relative "request.scm")

(define handle
  (lambda (in out handler)
    ; We're lazy- we can find out everything about the request that we care
    ; about from it's first line
    (let ((request (make-request in))
          (response (make-response)))
      (if request
        (write-response
          (handler request response)
          out))
      (close-input-port in)
      (close-output-port out))))

(define handle-in-thread
  (lambda (in out handler)
    (thread-start! (make-thread (lambda () (real-handle in out handler))))))

(define start
  (lambda (port threaded? handler)
    (letrec ((sock (tcp-listen port))
      (mainloop (lambda ()
        (let-values (((s-in s-out) (tcp-accept sock)))
          ((if threaded? handle-in-thread handle) s-in s-out handler)
          (mainloop)))))
      (mainloop))))
