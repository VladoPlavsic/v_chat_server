defmodule VChatServer.Connections.Authorization.API do
  @moduledoc false

  alias VChatServer.Connections.Authorization.Server

  def init(username, conn) do
    GenServer.call(Server, {:init, username, conn})
  end

  def init_authorization(conn) do
    GenServer.call(Server, {:init_authorization, conn})
  end

  def update_public_key(conn, public_key) do
    GenServer.call(Server, {:update_public_key, conn, public_key})
  end

  def authorize(conn, secret) do
    GenServer.call(Server, {:authorize, conn, secret})
  end

  def authorized_user(conn) do
    GenServer.call(Server, {:authorized_user, conn})
  end

  def user_conn(username) do
    GenServer.call(Server, {:user_conn, username})
  end
end
