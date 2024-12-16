defmodule VChatServer.Connections.Authorization.Server do
  use GenServer

  alias VChatServer.Connections.Authorization.Implementation
  alias VChatServer.Workflow.User, as: UserWorkflow

  defmodule State do
    defstruct user_conns: %{}, conn_users: %{}, user_states: %{}

    @type status :: :pending | {:awaiting_confirmation, secret :: binary()} | :authorized

    @type t :: %__MODULE__{
            user_conns: %{},
            conn_users: %{},
            user_states: %{}
          }
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  def handle_call({:init_authorization, conn}, _from, %State{conn_users: conn_users} = state) do
    case conn_users[conn] do
      nil ->
        {:reply, {:error, :no_user}, state}

      username ->
        username
        |> UserWorkflow.create()
        |> Implementation.init_authorization_flow(username, state)
    end
  end

  @impl GenServer
  def handle_call({:authorized_user, conn}, _from, %State{conn_users: conn_users} = state) do
    case conn_users[conn] do
      nil ->
        {:reply, {:error, :unknown_user}, state}

      username ->
        {:reply, {:ok, username}, state}
    end
  end

  def handle_call({:user_conn, username}, _from, %State{user_conns: user_conns} = state) do
    case user_conns[username] do
      nil ->
        {:reply, {:error, :not_online}, state}

      conn ->
        {:reply, {:ok, conn}, state}
    end
  end

  def handle_call(
        {:init, username, conn},
        _from,
        %State{user_conns: user_conns, conn_users: conn_users, user_states: user_states} = state
      ) do
    unless user_conns[username] && Process.alive?(user_conns[username]) do
      user_conns = Map.put(user_conns, username, conn)
      conn_users = Map.put(conn_users, conn, username)
      user_states = Map.put(user_states, username, :pending)

      {:reply, :ok, %{state | user_conns: user_conns, user_states: user_states, conn_users: conn_users}}
    else
      {:reply, :error, state}
    end
  end

  def handle_call(
        {:update_public_key, conn, public_key},
        _from,
        %State{conn_users: conn_users, user_states: user_states} = state
      ) do
    case conn_users[conn] do
      nil ->
        {:reply, {:error, :no_user}, state}

      username ->
        :update_public_key
        |> Implementation.pass?(user_states[username])
        |> Implementation.update_public_key(username, public_key)
        |> Implementation.generate_secret_and_await_confirmation(state)
    end
  end

  def handle_call(
        {:authorize, conn, secret},
        _from,
        %State{conn_users: conn_users, user_states: user_states} = state
      ) do
    case conn_users[conn] do
      nil ->
        {:reply, {:error, :no_user}, state}

      username ->
        VChatServer.Repo.get_by(VChatServer.Models.User, username: username)

        case Implementation.pass?(:authorize, user_states[username], secret) do
          true ->
            {:reply, {:ok, :authorize, username}, %{state | user_states: Map.put(user_states, username, :authorized)}}

          false ->
            {:reply, {:error, :authorize, :bad_secret}, state}
        end
    end
  end
end
