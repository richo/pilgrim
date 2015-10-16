(define (make-request port)
    (let ((first-line (read-line port)))
      (if (equal? first-line #!eof)
        #f
        `((path . ,(parse-request-path first-line))
          (query . ,(parse-request-query first-line))
          (method . ,(parse-request-method first-line))
          (headers . ,(parse-request-headers port))
          (body-port . ,port)))))

(define (parse-request-method line)
    (car (string-tokenize line)))

(define (extract-path line)
    (let ((tokenized-line (string-tokenize line)))
      (cadr tokenized-line)))

(define (parse-request-query line)
    (let* ((path (extract-path line))
           (idx (string-index path #\?)))
      (if idx
        (substring path (+ idx 1))
        #f)))

(define (parse-request-path line)
    (let* ((path (extract-path line))
           (idx (string-index path #\?)))
      (if idx
        (substring path 0 idx)
        path)))


(define (parse-header line)
    (let ((index (string-index line #\:)))
      `(,(string-upcase (substring line 0 index)) . ,(string-trim (substring line (+ index 1))))))

(define (parse-request-headers port)
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
        (loop '())))))

(define (make-fetcher key)
    (lambda (request)
      (let ((val (assoc key request)))
        (if key
          (cdr val)
          #f))))

(define get-request-method    (make-fetcher 'method))
(define get-request-path      (make-fetcher 'path))
(define get-request-query     (make-fetcher 'query))
(define get-request-headers   (make-fetcher 'headers))
(define get-request-body-port (make-fetcher 'body-port))
(define get-request-body      (lambda (request)
                                (let ((bytes (get-request-header request "Content-Length")))
                                  (read-string (if bytes (string->number bytes) #f) (get-request-body-port request)))))

(define (get-request-header request header)
    (let* ((headers (get-request-headers request))
           (val (assoc (string-upcase header) headers)))
      (if val
        (cdr val)
        #f)))
