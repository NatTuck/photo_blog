defmodule PhotoBlogWeb.PageController do
  use PhotoBlogWeb, :controller

  def index(conn, _params) do
    posts = PhotoBlog.Posts.list_posts()
    |> PhotoBlog.Posts.load_votes()
    render(conn, "index.html", posts: posts)
  end
end
