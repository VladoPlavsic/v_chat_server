defmodule VChatServer.Workflow.User do
  @moduledoc false

  alias VChatServer.Repo

  alias VChatServer.Models.User

  @spec create(username :: binary()) :: {:ok, User.t()} | {:error, :user_exists}
  def create(username) do
    %User{}
    |> User.changeset(%{username: username})
    |> Repo.insert()
    |> wrap_changeset_error()
  end

  @spec update(username :: binary(), pub_key :: binary()) :: {:ok, User.t()} | {:error, atom()}
  def update(username, pub_key) do
    case get_user(username) do
      {:ok, user} ->
        user
        |> User.changeset(%{pub_key: pub_key})
        |> Repo.update()
        |> wrap_changeset_error()

      any ->
        any
    end
  end

  defp wrap_changeset_error({:error, %Ecto.Changeset{errors: [username: {"has already been taken", _}]} = changeset}) do
    {:error, :user_exists}
  end

  defp wrap_changeset_error({:ok, _} = user), do: user

  def get_user(username) do
    case Repo.get_by(User, username: username) do
      nil -> {:error, :not_found}
      %User{} = user -> {:ok, user}
    end
  end
end
