defmodule OndinaApi.CatalogTest do
  use OndinaApi.DataCase

  alias OndinaApi.Catalog

  describe "videos" do
    alias OndinaApi.Catalog.Video

    import OndinaApi.CatalogFixtures

    @invalid_attrs %{description: nil, thumbnail_url: nil, title: nil, video_url: nil, views: nil}

    test "list_videos/0 returns all videos" do
      video = video_fixture()
      assert Catalog.list_videos() == [video]
    end

    test "get_video!/1 returns the video with given id" do
      video = video_fixture()
      assert Catalog.get_video!(video.id) == video
    end

    test "create_video/1 with valid data creates a video" do
      valid_attrs = %{description: "some description", thumbnail_url: "some thumbnail_url", title: "some title", video_url: "some video_url", views: 42}

      assert {:ok, %Video{} = video} = Catalog.create_video(valid_attrs)
      assert video.description == "some description"
      assert video.thumbnail_url == "some thumbnail_url"
      assert video.title == "some title"
      assert video.video_url == "some video_url"
      assert video.views == 42
    end

    test "create_video/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_video(@invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      video = video_fixture()
      update_attrs = %{description: "some updated description", thumbnail_url: "some updated thumbnail_url", title: "some updated title", video_url: "some updated video_url", views: 43}

      assert {:ok, %Video{} = video} = Catalog.update_video(video, update_attrs)
      assert video.description == "some updated description"
      assert video.thumbnail_url == "some updated thumbnail_url"
      assert video.title == "some updated title"
      assert video.video_url == "some updated video_url"
      assert video.views == 43
    end

    test "update_video/2 with invalid data returns error changeset" do
      video = video_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_video(video, @invalid_attrs)
      assert video == Catalog.get_video!(video.id)
    end

    test "delete_video/1 deletes the video" do
      video = video_fixture()
      assert {:ok, %Video{}} = Catalog.delete_video(video)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_video!(video.id) end
    end

    test "change_video/1 returns a video changeset" do
      video = video_fixture()
      assert %Ecto.Changeset{} = Catalog.change_video(video)
    end
  end
end
