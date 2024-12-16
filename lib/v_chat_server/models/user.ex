defmodule VChatServer.Models.User do
  @moduledoc false
  require Ecto.Schema

  use Ecto.Schema

  import Ecto.Schema, only: [schema: 2, field: 2]

  @timestamps_opts type: :utc_datetime_usec

  @type t :: %__MODULE__{}

  schema "users" do
    field(:username, :string)
    field(:pub_key, :binary)
  end

  @optional ~w[pub_key]a
  @required ~w[username]a

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(user, args) do
    user
    |> Ecto.Changeset.cast(args, @required ++ @optional)
    |> Ecto.Changeset.validate_required(@required)
    |> Ecto.Changeset.unique_constraint(:username)
    |> Ecto.Changeset.unique_constraint(:pub_key)
  end
end
