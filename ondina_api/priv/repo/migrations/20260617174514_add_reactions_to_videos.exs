defmodule OndinaApi.Repo.Migrations.AddReactionsToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :likes_count, :integer, default: 0
      add :dislikes_count, :integer, default: 0
    end
  end
end
