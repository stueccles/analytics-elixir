import Config

config :segment, :sender_impl, Segment.Analytics.Sender
config :segment, :max_batch_size, 100
config :segment, :batch_every_ms, 5_000

config :segment, :retry_attempts, 3
config :segment, :retry_expiry, 10_000
config :segment, :retry_start, 100

env_config = "#{Mix.env()}.exs"
File.exists?("config/#{env_config}") && import_config(env_config)
