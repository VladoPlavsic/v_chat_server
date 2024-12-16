defmodule VChatServer.Connections.Authorization do
  @moduledoc false

  defdelegate start_link(opts), to: __MODULE__.Server
  defdelegate child_spec(opts), to: __MODULE__.Server

  defdelegate init(username, conn), to: __MODULE__.API
  defdelegate init_authorization(conn), to: __MODULE__.API
  defdelegate update_public_key(conn, pub_key), to: __MODULE__.API
  defdelegate authorize(conn, password), to: __MODULE__.API
  defdelegate authorized_user(conn), to: __MODULE__.API
  defdelegate user_conn(username), to: __MODULE__.API
end
