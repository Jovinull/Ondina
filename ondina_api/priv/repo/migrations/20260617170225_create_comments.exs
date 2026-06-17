defmodule OndinaApi.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :author_name, :string
      add :video_id, references(:videos, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:video_id])
  end
end
