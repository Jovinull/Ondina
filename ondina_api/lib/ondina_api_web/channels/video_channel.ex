defmodule OndinaApiWeb.VideoChannel do
  use OndinaApiWeb, :channel

  @impl true
  def join("video:" <> _video_id, _payload, socket) do
    {:ok, socket}
  end
end
