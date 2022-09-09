import Config

config :phoenix, :json_library, Jason

# The bare minimum endpoint config to stand up LiveView tests
config :live_event, LiveEventTest.Endpoint,
  live_view: [signing_salt: "flollop-flollop"],
  secret_key_base: "zem"
