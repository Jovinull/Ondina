defmodule OndinaApi.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OndinaApi.Catalog` context.
  """

  @doc """
  Generate a video.
  """
  def video_fixture(attrs \\ %{}) do
    {:ok, video} =
      attrs
      |> Enum.into(%{
        description: "some description",
        thumbnail_url: "some thumbnail_url",
        title: "some title",
        video_url: "some video_url",
        views: 42
      })
      |> OndinaApi.Catalog.create_video()

    video
  end
end
