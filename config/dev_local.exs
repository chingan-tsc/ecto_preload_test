use Mix.Config

config :preload_test, PreloadTest.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "chingan",
  password: "",
  database: "preload_test_dev",
  hostname: "localhost",
  port: 5432,
  pool_size: 10
