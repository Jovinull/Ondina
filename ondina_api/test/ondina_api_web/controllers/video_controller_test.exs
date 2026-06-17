defmodule OndinaApiWeb.VideoControllerTest do
  use OndinaApiWeb.ConnCase

  import OndinaApi.CatalogFixtures

  alias OndinaApi.Catalog.Video

  @create_attrs %{
    description: "some description",
    thumbnail_url: "some thumbnail_url",
    title: "some title",
    video_url: "some video_url",
    views: 42
  }
  @update_attrs %{
    description: "some updated description",
    thumbnail_url: "some updated thumbnail_url",
    title: "some updated title",
    video_url: "some updated video_url",
    views: 43
  }
  @invalid_attrs %{description: nil, thumbnail_url: nil, title: nil, video_url: nil, views: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all videos", %{conn: conn} do
      conn = get(conn, ~p"/api/videos")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create video" do
    test "renders video when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/videos", video: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/videos/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "thumbnail_url" => "some thumbnail_url",
               "title" => "some title",
               "video_url" => "some video_url",
               "views" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/videos", video: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update video" do
    setup [:create_video]

    test "renders video when data is valid", %{conn: conn, video: %Video{id: id} = video} do
      conn = put(conn, ~p"/api/videos/#{video}", video: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/videos/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "thumbnail_url" => "some updated thumbnail_url",
               "title" => "some updated title",
               "video_url" => "some updated video_url",
               "views" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, video: video} do
      conn = put(conn, ~p"/api/videos/#{video}", video: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete video" do
    setup [:create_video]

    test "deletes chosen video", %{conn: conn, video: video} do
      conn = delete(conn, ~p"/api/videos/#{video}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/videos/#{video}")
      end
    end
  end

  defp create_video(_) do
    video = video_fixture()
    %{video: video}
  end
end
