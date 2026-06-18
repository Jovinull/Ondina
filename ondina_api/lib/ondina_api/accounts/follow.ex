defmodule OndinaApi.Accounts.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follows" do
    belongs_to :follower, OndinaApi.Accounts.User
    belongs_to :creator, OndinaApi.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:follower_id, :creator_id])
    |> validate_required([:follower_id, :creator_id])
    |> unique_constraint([:follower_id, :creator_id], name: :follows_follower_id_creator_id_index, message: "Você já está inscrito neste criador")
  end
end
