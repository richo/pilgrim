(define make-request
  (lambda (port)
    (let ((first-line (read-line port)))
      (if (equal? first-line #!eof)
        #f
        `((path . ,(parse-request-path first-line))
          (method . ,(parse-request-method first-line))
          (headers . ,(parse-request-headers port))
          (body-port . ,port))))))

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

(define parse-header
  (lambda (line)
    (let ((index (string-index line #\:)))
      `(,(string-upcase (substring line 0 index)) . ,(string-trim (substring line (+ index 1)))))))

(define parse-request-headers
  (lambda (port)
    (call/cc (lambda (return)
      (letrec ((loop (lambda (current)
        (let ((this-line (read-line port)))
          (cond
            ((equal? this-line #!eof)
             (return current))
            ((equal? this-line "")
             (return current))
            (else
             (loop (alist-update
                     (car (parse-header this-line))
                     (cdr (parse-header this-line))
                     current))))))))
        (loop '()))))))

(define make-fetcher
  (lambda (key)
    (lambda (request)
      (let ((val (assoc key request)))
        (if key
          (cdr val)
          #f)))))

(define get-request-method    (make-fetcher 'method))
(define get-request-path      (make-fetcher 'path))
(define get-request-headers   (make-fetcher 'headers))
(define get-request-body-port (make-fetcher 'body-port))
(define get-request-body      (lambda (request)
                                (let ((bytes (get-request-header request "Content-Length")))
                                  (read-string (if bytes (string->number bytes) #f) (get-request-body-port request)))))

(define get-request-header
  (lambda (request header)
    (let* ((headers (get-request-headers request))
           (val (assoc (string-upcase header) headers)))
      (if val
        (cdr val)
        #f))))
