defmodule OndinaApi.Repo.Migrations.AddStatusToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :status, :string, default: "processing"
    end
  end
end
