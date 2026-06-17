defmodule OndinaApiWeb.VideoChannel do
  use OndinaApiWeb, :channel

  alias OndinaApi.Engagement

  @impl true
  def join("video:" <> video_id, _payload, socket) do
    comments = Engagement.list_recent_comments_for_video(video_id)
    
    formatted_comments =
      Enum.map(comments, fn c ->
        %{
          id: c.id,
          author_name: (if c.user, do: c.user.username, else: "Anônimo"),
          content: c.content,
          inserted_at: c.inserted_at
        }
      end)

    socket = assign(socket, :video_id, video_id)
    {:ok, %{comments: formatted_comments}, socket}
  end

  @impl true
  def handle_in("new_comment", %{"content" => content}, socket) do
    video_id = socket.assigns.video_id
    user = socket.assigns.current_user

    case Engagement.create_comment(%{user_id: user.id, content: content, video_id: video_id}) do
      {:ok, comment} ->
        broadcast!(socket, "new_comment", %{
          id: comment.id,
          author_name: user.username,
          content: comment.content,
          inserted_at: comment.inserted_at
        })
        {:reply, :ok, socket}

      {:error, _changeset} ->
        {:reply, {:error, %{reason: "Falha ao salvar o comentário."}}, socket}
    end
  end
end
