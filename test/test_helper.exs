Application.put_env(:segment, :sender_impl, Segment.Analytics.Batcher)
Application.put_env(:segment, :max_batch_size, 100)
Application.put_env(:segment, :batch_every_ms, 5000)
Application.put_env(:segment, :retry_attempts, 3)
Application.put_env(:segment, :retry_expiry, 10_000)
Application.put_env(:segment, :retry_start, 100)
Application.put_env(:segment, :send_to_http, true)

ExUnit.start()
