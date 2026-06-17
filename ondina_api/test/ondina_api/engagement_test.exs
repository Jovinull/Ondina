defmodule OndinaApi.EngagementTest do
  use OndinaApi.DataCase

  alias OndinaApi.Engagement

  describe "comments" do
    alias OndinaApi.Engagement.Comment

    import OndinaApi.EngagementFixtures

    @invalid_attrs %{author_name: nil, content: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Engagement.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Engagement.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{author_name: "some author_name", content: "some content"}

      assert {:ok, %Comment{} = comment} = Engagement.create_comment(valid_attrs)
      assert comment.author_name == "some author_name"
      assert comment.content == "some content"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engagement.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{author_name: "some updated author_name", content: "some updated content"}

      assert {:ok, %Comment{} = comment} = Engagement.update_comment(comment, update_attrs)
      assert comment.author_name == "some updated author_name"
      assert comment.content == "some updated content"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Engagement.update_comment(comment, @invalid_attrs)
      assert comment == Engagement.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Engagement.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Engagement.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Engagement.change_comment(comment)
    end
  end
end
