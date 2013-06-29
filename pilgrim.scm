(use srfi-13)
(use srfi-18)
(use tcp)
(use posix)
(use utils)

(load-relative "response.scm")
(load-relative "request.scm")

(define threaded?
  #f)

(define real-handle
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

(define handle
  (if threaded?
    (lambda (in out handler) (thread-start! (make-thread (lambda () (real-handle in out handler)))))
    real-handle))

(define start
  (lambda (port handler)
    (letrec ((sock (tcp-listen port))
      (mainloop (lambda ()
        (let-values (((s-in s-out) (tcp-accept sock)))
          (handle s-in s-out handler)
          (mainloop)))))
      (mainloop))))
