defmodule OndinaApi.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :title, :string
      add :description, :text
      add :thumbnail_url, :string
      add :video_url, :string
      add :views, :integer, default: 0

      timestamps(type: :utc_datetime)
    end
  end
end
