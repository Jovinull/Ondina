defmodule OndinaApiWeb.VideoController do
  use OndinaApiWeb, :controller

  alias OndinaApi.Catalog
  alias OndinaApi.Catalog.Video

  action_fallback OndinaApiWeb.FallbackController

  def index(conn, _params) do
    videos = Catalog.list_videos()
    json(conn, %{data: videos})
  end

  def create(conn, %{"title" => title, "description" => description, "video" => %Plug.Upload{} = video, "thumbnail" => %Plug.Upload{} = thumbnail}) do
    user = conn.assigns.current_user
    
    video_uuid = Ecto.UUID.generate()
    video_ext = Path.extname(video.filename)
    thumbnail_ext = Path.extname(thumbnail.filename)

    video_filename = "#{video_uuid}#{video_ext}"
    thumbnail_filename = "#{video_uuid}#{thumbnail_ext}"

    video_dest = Path.join(["priv", "static", "uploads", "videos", video_filename])
    thumbnail_dest = Path.join(["priv", "static", "uploads", "thumbnails", thumbnail_filename])

    File.mkdir_p!(Path.dirname(video_dest))
    File.mkdir_p!(Path.dirname(thumbnail_dest))

    File.cp!(video.path, video_dest)
    File.cp!(thumbnail.path, thumbnail_dest)

    video_params = %{
      title: title,
      description: description,
      video_url: "http://localhost:4000/uploads/videos/#{video_filename}",
      thumbnail_url: "http://localhost:4000/uploads/thumbnails/#{thumbnail_filename}",
      user_id: user.id
    }

    case Catalog.create_video(video_params) do
      {:ok, video} ->
        conn
        |> put_status(:created)
        |> json(%{message: "Video criado com sucesso!", id: video.id})
      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Erro ao criar video"})
    end
  end

  def show(conn, %{"id" => id}) do
    video = Catalog.get_video!(id)
    render(conn, :show, video: video)
  end

  def view(conn, %{"id" => id}) do
    video = Catalog.increment_video_views(id)
    render(conn, :show, video: video)
  end

  def my_videos(conn, _params) do
    user_id = conn.assigns.current_user.id
    videos = Catalog.list_videos_for_user(user_id)
    json(conn, %{data: videos})
  end

  def delete(conn, %{"id" => id}) do
    user_id = conn.assigns.current_user.id

    case Catalog.delete_video_with_files(id, user_id) do
      {:ok, _video} ->
        send_resp(conn, :no_content, "")
      {:error, :unauthorized_or_not_found} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Você não tem permissão para excluir este vídeo."})
    end
  end
end
