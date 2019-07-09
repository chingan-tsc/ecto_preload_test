defmodule PreloadTest.MainTest do
  use PreloadTest.DataCase

  describe "posts" do
    @post_attrs %{name: "some name"}
    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@post_attrs)
        |> (fn attr -> PreloadTest.Post.changeset(%PreloadTest.Post{}, attr) end).()
        |> PreloadTest.Repo.insert()

      post
    end

    @comment_attrs %{name: "comment"}
    def comment_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@comment_attrs)
        |> (fn attr -> PreloadTest.Comment.changeset(%PreloadTest.Comment{}, attr) end).()
        |> PreloadTest.Repo.insert()

      tag
    end

    @tag_attrs %{tag: "tag"}
    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@tag_attrs)
        |> (fn attr -> PreloadTest.Tag.changeset(%PreloadTest.Tag{}, attr) end).()
        |> PreloadTest.Repo.insert()

      tag
    end

    def post_tag_fixture(attrs \\ %{}) do
      {:ok, post_tag} =
        PreloadTest.PostTag.changeset(%PreloadTest.PostTag{}, attrs)
        |> PreloadTest.Repo.insert()

      post_tag
    end

    test "preload many_to_many through preload query" do
      post1 = post_fixture()
      post2 = post_fixture()

      comment1 = comment_fixture()
      comment2 = comment_fixture()

      tag1 = tag_fixture(%{comment_id: comment1.id})
      tag2 = tag_fixture(%{comment_id: comment2.id})

      post_tag_fixture(%{post_id: post1.id, tag_id: tag1.id})
      post_tag_fixture(%{post_id: post2.id, tag_id: tag1.id})
      post_tag_fixture(%{post_id: post1.id, tag_id: tag2.id})

      # IO.inspect(Query.list_posts_a())
      # IO.inspect(Query.list_posts_b())

      assert Query.list_posts_a() == Query.list_posts_b()
    end

    test "preload many_to_many through preload query with non overlapping tags" do
      post1 = post_fixture()
      post2 = post_fixture()

      comment1 = comment_fixture()
      comment2 = comment_fixture()

      tag1 = tag_fixture(%{comment_id: comment1.id})
      tag2 = tag_fixture(%{comment_id: comment2.id})

      post_tag_fixture(%{post_id: post1.id, tag_id: tag1.id})
      post_tag_fixture(%{post_id: post2.id, tag_id: tag2.id})

      # IO.inspect(Query.list_posts_a())
      # IO.inspect(Query.list_posts_b())

      assert Query.list_posts_a() == Query.list_posts_b()
    end

    test "prepare_changeset failure test a" do
      p1 = post_fixture()

      # IO.inspect(p1)

      c1 =
        Ecto.build_assoc(p1, :comments)
        |> Ecto.Changeset.cast(%{name: "some text"}, [:name, :post_id])
        |> PreloadTest.Repo.insert!()

      # IO.inspect(c1)

      assert c1.post_id == p1.id

      c2 = PreloadTest.Repo.get(PreloadTest.Comment, c1.id)

      assert c2.post_id == p1.id
    end

    test "prepare_changeset failure test b" do
      p1 = post_fixture()

      # IO.inspect(p1)

      c1 =
        Ecto.build_assoc(p1, :comments)
        |> IO.inspect()
        |> Ecto.Changeset.cast(%{name: "some text"}, [:name, :post_id])
        |> track_changes()
        |> PreloadTest.Repo.insert!()

      # IO.inspect(c1)

      assert c1.post_id == p1.id

      c2 = PreloadTest.Repo.get(PreloadTest.Comment, c1.id)

      assert c2.post_id == p1.id
    end
  end

  defp track_changes(changeset) do
    Ecto.Changeset.prepare_changes(changeset, fn
      _ -> dummy(changeset)
    end)
  end

  defp dummy(changeset), do: changeset
end
