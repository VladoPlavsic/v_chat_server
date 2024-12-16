defmodule VChatServer.Connection do
  @behaviour :cowboy_websocket

  alias VChatServer.Connections.Authorization
  alias VChatServer.Connections.PeerToPeer

  def init(request, state) do
    username = :cowboy_req.binding(:username, request)

    case Authorization.init(username, request.pid) do
      :ok ->
        {:cowboy_websocket, request, state}

      :error ->
        {:ok, 403, state}
    end
  end

  # Handle WebSocket connection establishment
  def websocket_init(state) do
    self()
    |> Authorization.init_authorization()
    |> push_next_state(state)
  end

  # Handle incoming WebSocket messages
  def websocket_handle({:text, <<"send_public_key:", public_key::binary>>}, state) do
    self()
    |> Authorization.update_public_key(public_key)
    |> push_next_state(state)
  end

  def websocket_handle({:text, <<"authorize:", secret::binary>>}, state) do
    self()
    |> Authorization.authorize(secret)
    |> push_next_state(state)
  end

  def websocket_handle({:text, <<"get_peer_public_key:", username::binary>>}, state) do
    username
    |> PeerToPeer.get_peer_public_key()
    |> maybe_send_peer_public_key(state, username)
  end

  def websocket_handle({:text, <<"send:", message::binary>>}, state) do
    self()
    |> Authorization.authorized_user()
    |> maybe_send_p2p(message)
    |> push_next_state(state)
  end

  def websocket_handle({:text, msg}, state) do
    {:reply, {:text, "error:Unknown command: " <> msg}, state}
  end

  def websocket_info({:push_message, _from, msg}, state) do
    {:reply, {:text, "push_message:#{msg}"}, state}
  end

  defp maybe_send_p2p({:ok, username}, message), do: PeerToPeer.send_message(username, message)
  defp maybe_send_p2p(error, _message), do: error

  defp maybe_send_peer_public_key({:ok, pub_key}, state, _username) do
    push_next_state({:ok, :send_peer_pub_key, pub_key}, state)
  end

  defp maybe_send_peer_public_key({:error, :not_found}, state, username) do
    push_next_state({:ok, :notify_no_peer, username}, state)
  end

  defp push_next_state({:ok, :send_peer_pub_key, pub_key}, state),
    do: {:reply, {:text, "peer_public_key:#{pub_key}"}, state}

  defp push_next_state({:ok, :notify_no_peer, username}, state),
    do: {:reply, {:text, "no_peer:#{username}"}, state}

  defp push_next_state({:ok, :awaiting_confirmation, {secret, _size}}, state),
    do: {:reply, {:text, "authorize:#{secret}"}, state}

  defp push_next_state({:ok, :awaiting_public_key}, state) do
    {:reply, {:text, "send_public_key:"}, state}
  end

  defp push_next_state({:ok, :authorize, username}, state) do
    {:reply, {:text, "authorized:#{username}"}, state}
  end

  defp push_next_state({:ok, :send_message, :sent}, state) do
    # TODO: Maybe add some unique ID for message to be identified
    {:reply, {:text, "notify:sent"}, state}
  end

  defp push_next_state({:ok, :send_message, :enqueued}, state) do
    {:reply, {:text, "notify:enqueued"}, state}
  end

  defp push_next_state({:error, :update_public_key, :forbidden}, state) do
    {:stop, 403, state}
  end

  defp push_next_state({:error, :authorize, :bad_secret}, state) do
    {:stop, 403, state}
  end

  defp push_next_state({:error, :unknown_user}, state) do
    {:stop, 403, state}
  end

  # Handle closing of the WebSocket
  def websocket_terminate(_reason, _state), do: :ok
end
