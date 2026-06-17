defmodule OndinaApi.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias OndinaApi.Repo

  alias OndinaApi.Catalog.Video

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos do
    Repo.all(from v in Video, order_by: [desc: v.inserted_at])
  end

  @doc """
  Returns the list of videos for a specific user.
  """
  def list_videos_for_user(user_id) do
    Repo.all(from v in Video, where: v.user_id == ^user_id, order_by: [desc: v.inserted_at])
  end

  @doc """
  Searches for videos by title or description, returning essential preloaded data.
  """
  def search_videos(query) do
    search_term = "%#{query}%"
    
    from(v in Video,
      where: ilike(v.title, ^search_term) or ilike(v.description, ^search_term),
      order_by: [desc: v.inserted_at],
      preload: [:user]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id), do: Repo.get!(Video, id)

  @doc """
  Increments the views of a video by 1 safely.
  """
  def increment_video_views(id) do
    {1, _} =
      from(v in Video, where: v.id == ^id)
      |> Repo.update_all(inc: [views: 1])

    video = get_video!(id)
    OndinaApiWeb.Endpoint.broadcast("video:#{video.id}", "new_view", %{views: video.views})
    video
  end

  @doc """
  Atomically increments the reactions count for a video.
  reaction_type should be :like or :dislike.
  """
  def react_to_video(id, :like) do
    {1, _} =
      from(v in Video, where: v.id == ^id)
      |> Repo.update_all(inc: [likes_count: 1])

    get_video!(id)
  end

  def react_to_video(id, :dislike) do
    {1, _} =
      from(v in Video, where: v.id == ^id)
      |> Repo.update_all(inc: [dislikes_count: 1])

    get_video!(id)
  end

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(%{field: value})
      {:ok, %Video{}}

      iex> create_video(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  @doc """
  Deletes a video and its associated physical files, validating the user ownership.
  """
  def delete_video_with_files(id, user_id) do
    video = Repo.get(Video, id)

    if video && video.user_id == user_id do
      # Converter a URL web para o diretório de destino local no Linux
      video_path = String.replace(video.video_url || "", "http://localhost:4000/uploads/", "priv/static/uploads/")
      thumb_path = String.replace(video.thumbnail_url || "", "http://localhost:4000/uploads/", "priv/static/uploads/")

      # Tenta remover silenciosamente (ignora falha se arquivo não existir mais)
      if video_path != "", do: File.rm(video_path)
      if thumb_path != "", do: File.rm(thumb_path)

      Repo.delete(video)
    else
      {:error, :unauthorized_or_not_found}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{data: %Video{}}

  """
  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end
end
