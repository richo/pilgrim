(test-begin "response")

(define resp (make-response))

(test "sets status code" 100
      (let ((new-resp (set-response-status 100 resp)))
        (get-response-status new-resp)))

(test "default status code 200" 200
      (get-response-status resp))

(test-end)
