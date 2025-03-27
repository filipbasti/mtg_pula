import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

hostname = System.get_env("DB_HOST") || "192.168.0.4"

config :mtg_pula, MtgPula.Repo,
  username: "postgres",
  password: "javolimkrafnu123",
  hostname: hostname,
  database: "mtg_pula_test#{System.get_env("MIX_TEST_PARTITION") || ""}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mtg_pula, MtgPulaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "4PjXLIkz1I1hP++U3ekK4PDVRfqaZ395zvRfC/5Eq1nrh0rVmzxXgKC7cMJToF5Y",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
