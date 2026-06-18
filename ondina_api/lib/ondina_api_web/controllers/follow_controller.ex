defmodule OndinaApiWeb.FollowController do
  use OndinaApiWeb, :controller
  alias OndinaApi.Accounts

  def follow(conn, %{"id" => creator_id}) do
    follower_id = conn.assigns.current_user.id
    
    case Accounts.follow_user(follower_id, creator_id) do
      {:ok, _follow} ->
        json(conn, %{message: "Inscrição realizada com sucesso"})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Não foi possível realizar a inscrição"})
    end
  end

  def unfollow(conn, %{"id" => creator_id}) do
    follower_id = conn.assigns.current_user.id
    
    case Accounts.unfollow_user(follower_id, creator_id) do
      {:ok, _follow} ->
        json(conn, %{message: "Inscrição cancelada"})
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Inscrição não encontrada"})
    end
  end

  def status(conn, %{"id" => creator_id}) do
    follower_id = get_req_header(conn, "authorization")
    
    # Validação manual simples via bearer se for rota pública, ou via assigns se auth.
    follower_id = case conn.assigns[:current_user] do
      nil -> nil
      user -> user.id
    end

    if follower_id do
      is_following = Accounts.is_following?(follower_id, creator_id)
      json(conn, %{is_following: is_following})
    else
      json(conn, %{is_following: false})
    end
  end
end
