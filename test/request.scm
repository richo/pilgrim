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

(test-end)
