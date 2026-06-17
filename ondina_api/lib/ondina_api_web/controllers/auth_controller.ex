defmodule OndinaApiWeb.AuthController do
  use OndinaApiWeb, :controller

  alias OndinaApi.Accounts
  alias OndinaApi.Accounts.User
  alias OndinaApiWeb.Endpoint

  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, %User{} = user} ->
        token = Phoenix.Token.sign(Endpoint, "user auth", user.id)
        
        conn
        |> put_status(:created)
        |> json(%{
          message: "Usuário criado com sucesso",
          token: token,
          user: %{id: user.id, username: user.username, email: user.email}
        })

      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    user = Accounts.get_user_by_email(email)

    if user && Bcrypt.verify_pass(password, user.password_hash) do
      token = Phoenix.Token.sign(Endpoint, "user auth", user.id)

      json(conn, %{
        message: "Login efetuado com sucesso",
        token: token,
        user: %{id: user.id, username: user.username, email: user.email}
      })
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Credenciais inválidas"})
    end
  end

  def me(conn, _params) do
    user = conn.assigns.current_user
    json(conn, %{user: %{id: user.id, username: user.username, email: user.email}})
  end
end
