defmodule OndinaApi.Catalog.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :description, :string
    field :thumbnail_url, :string
    field :title, :string
    field :video_url, :string
    field :views, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:title, :description, :thumbnail_url, :video_url, :views])
    |> validate_required([:title, :description, :thumbnail_url, :video_url, :views])
  end
end
