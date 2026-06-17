defmodule OndinaApiWeb.VideoController do
  use OndinaApiWeb, :controller

  alias OndinaApi.Catalog
  alias OndinaApi.Catalog.Video

  action_fallback OndinaApiWeb.FallbackController

  def index(conn, _params) do
    videos = Catalog.list_videos()
    render(conn, :index, videos: videos)
  end

  def create(conn, %{"video" => video_params}) do
    with {:ok, %Video{} = video} <- Catalog.create_video(video_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/videos/#{video}")
      |> render(:show, video: video)
    end
  end

  def show(conn, %{"id" => id}) do
    video = Catalog.get_video!(id)
    render(conn, :show, video: video)
  end

  def update(conn, %{"id" => id, "video" => video_params}) do
    video = Catalog.get_video!(id)

    with {:ok, %Video{} = video} <- Catalog.update_video(video, video_params) do
      render(conn, :show, video: video)
    end
  end

  def delete(conn, %{"id" => id}) do
    video = Catalog.get_video!(id)

    with {:ok, %Video{}} <- Catalog.delete_video(video) do
      send_resp(conn, :no_content, "")
    end
  end
end
