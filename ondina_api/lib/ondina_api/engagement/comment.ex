defmodule OndinaApi.Engagement.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    belongs_to :user, OndinaApi.Accounts.User
    belongs_to :video, OndinaApi.Catalog.Video, define_field: false
    field :video_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :video_id, :user_id])
    |> validate_required([:content, :video_id, :user_id])
  end
end
