defmodule Query do
  import Ecto.Query
  alias PreloadTest.Comment
  alias PreloadTest.Tag
  alias PreloadTest.Post

  alias PreloadTest.Repo

  def list_posts_a() do
    preload_query = from(t in Tag, join: c in assoc(t, :comment), preload: [comment: c])

    from(p in Post, preload: [tags: ^preload_query])
    |> PreloadTest.Repo.all()
  end

  def list_posts_b() do
    preload_query = from(t in Tag, join: c in assoc(t, :comment), preload: [comment: []])

    from(p in Post, preload: [tags: ^preload_query])
    |> PreloadTest.Repo.all()
  end
end
