defmodule OndinaApi.EngagementFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OndinaApi.Engagement` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        author_name: "some author_name",
        content: "some content"
      })
      |> OndinaApi.Engagement.create_comment()

    comment
  end
end
