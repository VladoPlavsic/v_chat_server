defmodule VChatServer.Connections.PeerToPeer do
  @moduledoc false

  alias VChatServer.Connections.Authorization

  def send_message(from, message) do
    message
    |> String.split(":")
    |> do_send(from)
  end

  defp do_send([to, message], from) do
    to
    |> Authorization.user_conn()
    |> send_or_enqueue(from, message)
  end

  defp send_or_enqueue({:ok, conn}, from, message) do
    send(conn, {:push_message, from, message})
    {:ok, :send_message, :sent}
  end

  defp send_or_enqueue({:error, :not_online}, _from, _message) do
    # Over here we want to enqueue message to DB to be pushed when user comes online?
    # Or do we want to listen in background?
    # probably second, do not close connection ever, but for sure not MVP
    {:ok, :send_message, :enqueued}
  end

  def get_peer_public_key(username) do
    case VChatServer.Repo.get_by(VChatServer.Models.User, username: username) do
      %VChatServer.Models.User{pub_key: pub_key} when is_binary(pub_key) ->
        {:ok, pub_key}

      _any ->
        {:error, :not_found}
    end
  end
end
