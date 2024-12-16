defmodule VChatServer.Connections.Authorization.Implementation do
  @moduledoc false
  alias VChatServer.Connections.Authorization.Server.State

  alias VChatServer.Security

  alias VChatServer.Models.User
  alias VChatServer.Workflow.User, as: UserWorkflow

  def init_authorization_flow({:error, :user_exists}, username, %State{} = state) do
    username
    |> UserWorkflow.get_user()
    |> init_authorization_flow(username, state)
  end

  def init_authorization_flow({:ok, %User{pub_key: nil} = _}, username, %State{user_states: user_states} = state) do
    {
      :reply,
      {:ok, :awaiting_public_key},
      %{state | user_states: Map.put(user_states, username, :awaiting_public_key)}
    }
  end

  def init_authorization_flow({:ok, %User{} = _} = user, _username, %State{} = state) do
    generate_secret_and_await_confirmation(user, state)
  end

  def generate_secret_and_await_confirmation({:ok, %User{username: username}}, %State{user_states: user_states} = state) do
    secret =
      50
      |> :crypto.strong_rand_bytes()
      |> :crypto.bytes_to_integer()
      |> Integer.to_string()

    encrypted_secret =
      secret
      |> Security.encrypt(username)
      |> Kernel.<>("@" <> (Security.FileReader.get_public_key!() |> Security.FileReader.strip_rsa_public_key()))

    {
      :reply,
      {:ok, :awaiting_confirmation, {encrypted_secret, byte_size(encrypted_secret)}},
      %{state | user_states: Map.put(user_states, username, {:awaiting_confirmation, secret})}
    }
  end

  def generate_secret_and_await_confirmation({{:error, :forbidden}, state}) do
    {:reply, {:error, :update_public_key}, :forbidden, state}
  end

  def update_public_key(true = _pass?, username, public_key), do: UserWorkflow.update(username, public_key)
  def update_public_key(false = _pass?, _username, _public_key), do: {:error, :forbidden}

  def pass?(:update_public_key, :awaiting_public_key), do: true
  def pass?(_operation, _user_state), do: false

  def pass?(:authorize, {:awaiting_confirmation, secret}, encrypted_secret) do
    case Security.decrypt(encrypted_secret) do
      ^secret -> true
      _ -> false
    end
  end

  def pass?(_operation, _user_state, _data), do: false
end
