defmodule PhotoBlogWeb.PageController do
  use PhotoBlogWeb, :controller

  def index(conn, _params) do
    posts = PhotoBlog.Posts.list_posts()
    render(conn, "index.html", posts: posts)
  end
end
