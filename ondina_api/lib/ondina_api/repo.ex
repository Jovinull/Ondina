defmodule OndinaApi.Repo do
  use Ecto.Repo,
    otp_app: :ondina_api,
    adapter: Ecto.Adapters.Postgres
end
