defmodule OndinaApiWeb.VideoController do
  use OndinaApiWeb, :controller

  alias OndinaApi.Catalog
  alias OndinaApi.Catalog.Video

  action_fallback OndinaApiWeb.FallbackController

  def index(conn, _params) do
    videos = Catalog.list_videos() |> OndinaApi.Repo.preload(:user)
    
    videos_data = Enum.map(videos, fn v ->
      %{
        id: v.id,
        title: v.title,
        thumbnail_url: v.thumbnail_url,
        views: v.views,
        user_name: if(v.user, do: v.user.username, else: "Desconhecido")
      }
    end)
    
    json(conn, %{data: videos_data})
  end

  def search(conn, %{"q" => query}) do
    videos = Catalog.search_videos(query)
    
    videos_data = Enum.map(videos, fn v ->
      %{
        id: v.id,
        title: v.title,
        thumbnail_url: v.thumbnail_url,
        views: v.views,
        user_name: if(v.user, do: v.user.username, else: "Desconhecido")
      }
    end)

    json(conn, %{data: videos_data})
  end

  def create(conn, %{"title" => title, "description" => description, "video" => %Plug.Upload{} = video, "thumbnail" => %Plug.Upload{} = thumbnail}) do
    user = conn.assigns.current_user
    
    video_uuid = Ecto.UUID.generate()
    thumbnail_ext = Path.extname(thumbnail.filename)

    thumbnail_filename = "#{video_uuid}#{thumbnail_ext}"
    thumbnail_dest = Path.join(["priv", "static", "uploads", "thumbnails", thumbnail_filename])

    File.mkdir_p!(Path.dirname(thumbnail_dest))
    File.cp!(thumbnail.path, thumbnail_dest)

    temp_video_dest = Path.join(["priv", "static", "uploads", "temp", "#{video_uuid}.mp4"])
    File.mkdir_p!(Path.dirname(temp_video_dest))
    File.cp!(video.path, temp_video_dest)

    video_params = %{
      title: title,
      description: description,
      video_url: "",
      thumbnail_url: "http://localhost:4000/uploads/thumbnails/#{thumbnail_filename}",
      status: "processing",
      user_id: user.id
    }

    case Catalog.create_video(video_params) do
      {:ok, created_video} ->
        Task.start(fn -> process_hls_video(created_video.id, video_uuid, temp_video_dest) end)

        conn
        |> put_status(:created)
        |> json(%{message: "Video criado e em processamento!", id: created_video.id})
      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Erro ao criar video"})
    end
  end

  defp process_hls_video(video_id, video_uuid, input_path) do
    output_folder = Path.join(["priv", "static", "uploads", "videos", video_uuid])
    File.mkdir_p!(output_folder)
    
    output_m3u8 = Path.join([output_folder, "playlist.m3u8"])
    
    ffmpeg_path = System.find_executable("ffmpeg") || "/home/jovino/bin/ffmpeg"
    args = [
      "-i", input_path,
      "-codec:v", "libx264",
      "-codec:a", "aac",
      "-f", "hls",
      "-hls_time", "6",
      "-hls_playlist_type", "vod",
      output_m3u8
    ]

    case System.cmd(ffmpeg_path, args, stderr_to_stdout: true) do
      {_output, 0} ->
        video = Catalog.get_video!(video_id) |> OndinaApi.Repo.preload(:user)
        final_url = "http://localhost:4000/uploads/videos/#{video_uuid}/playlist.m3u8"
        Catalog.update_video_status(video, "ready", final_url)
        File.rm(input_path)
        
        followers = OndinaApi.Accounts.list_followers(video.user_id)
        payload = %{
          video_id: video.id,
          title: video.title,
          creator_name: video.user.username,
          thumbnail_url: video.thumbnail_url
        }
        
        Enum.each(followers, fn follower ->
          OndinaApiWeb.Endpoint.broadcast("user_notifications:#{follower.id}", "new_video_notification", payload)
        end)
        
      {error_output, _status_code} ->
        require Logger
        Logger.error("FFmpeg falhou: #{error_output}")
        video = Catalog.get_video!(video_id)
        Catalog.update_video_status(video, "error")
        File.rm(input_path)
    end
  end

  def show(conn, %{"id" => id}) do
    video = Catalog.get_video!(id) |> OndinaApi.Repo.preload(:user)
    
    video_data = %{
      id: video.id,
      title: video.title,
      description: video.description,
      thumbnail_url: video.thumbnail_url,
      video_url: video.video_url,
      views: video.views,
      likes_count: video.likes_count,
      dislikes_count: video.dislikes_count,
      user_id: video.user_id,
      status: video.status,
      user_name: if(video.user, do: video.user.username, else: "Desconhecido")
    }

    json(conn, %{data: video_data})
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
