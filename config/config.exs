import Config

config :segment,
  sender_impl: Segment.Analytics.Batcher,
  max_batch_size: 100,
  batch_every_ms: 5000

config :segment,
  retry_attempts: 3,
  retry_expiry: 10_000,
  retry_start: 100

env_config = "#{Mix.env()}.exs"
File.exists?("config/#{env_config}") && import_config(env_config)
