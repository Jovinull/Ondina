defmodule OndinaApiWeb.Plugs.Auth do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias OndinaApiWeb.Endpoint
  alias OndinaApi.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Phoenix.Token.verify(Endpoint, "user auth", token, max_age: 86400 * 7),
         user when not is_nil(user) <- Accounts.get_user!(user_id) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Não autorizado"})
        |> halt()
    end
  end
end
