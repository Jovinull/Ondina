defmodule OndinaApiWeb.NotificationChannel do
  use OndinaApiWeb, :channel

  @impl true
  def join("user_notifications:" <> user_id, _payload, socket) do
    if to_string(socket.assigns.current_user.id) == user_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
end
