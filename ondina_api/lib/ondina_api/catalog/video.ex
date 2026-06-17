defmodule OndinaApi.Catalog.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :description, :string
    field :thumbnail_url, :string
    field :title, :string
    field :video_url, :string
    field :views, :integer, default: 0
    field :likes_count, :integer, default: 0
    field :dislikes_count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:title, :description, :thumbnail_url, :video_url, :views, :likes_count, :dislikes_count])
    |> validate_required([:title, :description, :thumbnail_url, :video_url, :views])
  end
end
