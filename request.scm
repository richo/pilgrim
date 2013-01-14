(define make-request
  (lambda (port)
    (let ((first-line (read-line port)))
      (if (equal? first-line #!eof)
        #f
        `((path . ,(parse-request-path first-line))
          (method . ,(parse-request-method first-line))
          (request-port . ,port))))))

(define parse-request-method
  (lambda (line)
    (car (string-tokenize line))))

(define parse-request-path
  ; Maximum ghetto. Expect a line like:
  ; GET /index.html HTTP/1.1
  (lambda (line)
    (let ((tokenized-line (string-tokenize line)))
      ; TODO strip query strings
      (cadr tokenized-line))))

(define make-fetcher
  (lambda (key)
    (lambda (request)
      (let ((val (assoc key request)))
        (if key
          (cdr val)
          #f)))))
(define get-request-method    (make-fetcher 'method))
(define get-request-path      (make-fetcher 'path))
