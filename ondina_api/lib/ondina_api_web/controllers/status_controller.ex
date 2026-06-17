defmodule OndinaApiWeb.StatusController do
  use OndinaApiWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok", message: "Ondina API is running"})
  end
end
