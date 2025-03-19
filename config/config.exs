# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

IO.inspect(System.get_env("GUARDIAN_SECRET_KEY"), label: "GUARDIAN_SECRET_KEY")
config :mtg_pula,
  ecto_repos: [MtgPula.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]
host = System.get_env("PHX_HOST") || "localhost"
# Configures the endpoint
config :mtg_pula, MtgPulaWeb.Endpoint,
  url: [host: host],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MtgPulaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MtgPula.PubSub,
  live_view: [signing_salt: "TGw9xRNY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

if config_env() in [:dev, :test] do
  import_config ".env.exs"
end
import_config "#{config_env()}.exs"


config :mtg_pula, MtgPulaWeb.Auth.Guardian,
issuer: "mtg_pula",
secret_key: "G5UZdqYZTTRJ2GqMwUoeai+XjBG9ZgKn6GCcu9Omf5p0Y+2N68KP5twU6YCxDcrl"

config :guardian, Guardian.DB,
    repo: MtgPula.Repo,
    schema_name: "guardian_tokens",
    sweep_interval: 60
