(test-begin "request")

(test "should_parse_method"
      "GET"
      (let* ((port (open-input-string "GET /foo HTTP/1.1"))
             (request (make-request port)))
        (get-request-method request)))

(test "should_parse_path"
      "/butts"
      (let* ((port (open-input-string "GET /butts HTTP/1.1"))
             (request (make-request port)))
        (get-request-path request)))

(test "should_parse_path_with_query"
      "/butts"
      (let* ((port (open-input-string "GET /butts?hi=there HTTP/1.1"))
             (request (make-request port)))
        (get-request-path request)))

(test "should_parse_query"
      "hi=there"
      (let* ((port (open-input-string "GET /?hi=there HTTP/1.1"))
             (request (make-request port)))
        (get-request-query request)))

(test "should_parse_query_with_path"
      "hi=there"
      (let* ((port (open-input-string "GET /butts?hi=there HTTP/1.1"))
             (request (make-request port)))
        (get-request-query request)))

(test-group "should_parse_headers"
      (let* ((port (open-input-string "GET /butts HTTP/1.1\r\nX-Foo: lulz\r\nX-Rawr: lols\r\nX-Spaces: lolol        lolol\r\n"))
             (request (make-request port)))
        (test-assert "Headers in order"
                     (equal? "lols" (get-request-header request "X-Rawr")))
        (test-assert "Headers in different case"
                     (equal? "lulz" (get-request-header request "X-FOO")))
        (test-assert "Spaces in value"
                     (equal? "lolol        lolol" (get-request-header request "X-spaces")))
        ))

(test "should be able to read body"
      "things are lols\r\nalso test string\r\n"
      (let* ((port (open-input-string "GET /butts HTTP/1.1\r\nX-Foo: lulz\r\nX-Rawr: lols\r\nX-Spaces: lolol        lolol\r\n\r\nthings are lols\r\nalso test string\r\n"))
             (request (make-request port)))
        (get-request-body request)))

(test-end)
