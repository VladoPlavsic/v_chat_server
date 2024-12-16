defmodule VChatServer.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string, null: false)
      add(:pub_key, :binary, null: true)
    end

    create(unique_index(:users, [:username]))
    create(unique_index(:users, [:pub_key]))
  end
end
