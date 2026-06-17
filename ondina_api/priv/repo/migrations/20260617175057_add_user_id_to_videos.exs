defmodule OndinaApi.Repo.Migrations.AddUserIdToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :user_id, references(:users, on_delete: :nilify_all)
    end
    create index(:videos, [:user_id])
  end
end
