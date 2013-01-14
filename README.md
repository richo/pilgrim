pilgrim
==========

pilgrim is a minimal HTTP kernel written in chicken scheme.

example usage
-------------

```scheme
#!/usr/bin/env csi -ss

(require "pilgrim")

(define main
  (lambda (argv)
    (start 9001 (lambda (request response)
                      (let ((request-path (get-request-path request)))
                        (cond
                          ((equal? request-path "/")
                           (set-response-body "Hello from pilgrim!"
                                              response))
                          (else
                           (set-response-status 404
                           (set-response-body "Page not found"
                                              response)))
                        ))))))
```

```bash
curl localhost:9001
#=> Hello from pilgrim!
```
