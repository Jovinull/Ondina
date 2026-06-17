defmodule OndinaApi.Engagement.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :author_name, :string
    field :content, :string
    field :video_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :author_name])
    |> validate_required([:content, :author_name])
  end
end
