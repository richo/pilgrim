(define get-request-method
  (lambda (line)
    (car (string-tokenize line))))

(define get-request-path
  ; Maximum ghetto. Expect a line like:
  ; GET /index.html HTTP/1.1
  (lambda (line)
    (let ((tokenized-line (string-tokenize line)))
      ; TODO strip query strings
      (cadr tokenized-line))))

