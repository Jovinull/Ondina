defmodule OndinaApiWeb.VideoJSON do
  alias OndinaApi.Catalog.Video

  @doc """
  Renders a list of videos.
  """
  def index(%{videos: videos}) do
    %{data: for(video <- videos, do: data(video))}
  end

  @doc """
  Renders a single video.
  """
  def show(%{video: video}) do
    %{data: data(video)}
  end

  defp data(%Video{} = video) do
    %{
      id: video.id,
      title: video.title,
      description: video.description,
      thumbnail_url: video.thumbnail_url,
      video_url: video.video_url,
      views: video.views
    }
  end
end
