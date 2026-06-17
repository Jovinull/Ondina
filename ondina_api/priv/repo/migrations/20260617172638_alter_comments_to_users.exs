defmodule OndinaApi.Repo.Migrations.AlterCommentsToUsers do
  use Ecto.Migration

  def up do
    execute "DELETE FROM comments"

    alter table(:comments) do
      remove :author_name
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:comments, [:user_id])
  end

  def down do
    alter table(:comments) do
      remove :user_id
      add :author_name, :string
    end
  end
end
