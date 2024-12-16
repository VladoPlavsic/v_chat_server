import Config

config :v_chat_server, ecto_repos: [VChatServer.Repo]

config :v_chat_server, VChatServer.Repo, migration_timestamps: [type: :utc_datetime_usec]

config :v_chat_server, VChatServer.Repo,
  username: "postgres",
  password: "postgres",
  database: "v_chat",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
