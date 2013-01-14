(define nl "\r\n")
(define write-response
  (lambda (resp port)
    (let* ((status-code (number->string (get-response-status resp)))
          (status-name (cdr (lookup-status-code (cdr (assoc 'status resp)))))
          (body        (cdr (assoc 'body resp)))
          (response    (set-response-header "Content-Length" (number->string (string-length body)) resp)))
    (display (string-append "HTTP/1.0 " status-code " " status-name nl) port)
    (for-each (lambda (el)
                (cond ((string? (car el))
                         (let ((header (car el)) (value (cdr el)))
                           (display (string-append header ": " value nl) port)))))
              response)
    (display nl port)
    (display body port))))

(define make-response
  (lambda ()
    ; Note to self. This object is immutable. Subseqent calls to set-foo return a mutated but new object.
    '((status . 200)
      (body . ""))))

(define get-response-status
  (lambda (response)
    (cdr (assoc 'status response))))

(define set-response-status
  (lambda (status response)
    (alist-update 'status status response)))

(define set-response-body
  (lambda (body response)
    (alist-update 'body body response)))

(define set-response-header
  (lambda (header value response)
    ; TODO Potentially stringify headers here?
    (alist-update header value response)))

(define lookup-status-code ; TODO Rename saner
  (lambda (code)
  (assoc code
'((100 . "Continue")
  (101 . "Switching Protocols")
  (200 . "OK")
  (201 . "Created")
  (202 . "Accepted")
  (203 . "Non-Authoritative Information")
  (204 . "No Content")
  (205 . "Reset Content")
  (206 . "Partial Content")
  (300 . "Multiple Choices")
  (301 . "Moved Permanently")
  (302 . "Found")
  (303 . "See Other")
  (304 . "Not Modified")
  (305 . "Use Proxy")
  (307 . "Temporary Redirect")
  (400 . "Bad Request")
  (401 . "Unauthorized")
  (402 . "Payment Required")
  (403 . "Forbidden")
  (404 . "Not Found")
  (405 . "Method Not Allowed")
  (406 . "Not Acceptable")
  (407 . "Proxy Authentication Required")
  (408 . "Request Time-out")
  (409 . "Conflict")
  (410 . "Gone")
  (411 . "Length Required")
  (412 . "Precondition Failed")
  (413 . "Request Entity Too Large")
  (414 . "Request-URI Too Large")
  (415 . "Unsupported Media Type")
  (416 . "Requested range not satisfiable")
  (417 . "Expectation Failed")
  (500 . "Internal Server Error")
  (501 . "Not Implemented")
  (502 . "Bad Gateway")
  (503 . "Service Unavailable")
  (504 . "Gateway Time-out")
  (505 . "HTTP Version not supported")))))
