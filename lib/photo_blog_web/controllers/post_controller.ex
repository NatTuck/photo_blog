defmodule PhotoBlogWeb.PostController do
  use PhotoBlogWeb, :controller

  alias PhotoBlog.Posts
  alias PhotoBlog.Posts.Post
  alias PhotoBlog.Photos

  alias PhotoBlog.Comments

  alias PhotoBlogWeb.Plugs
  plug Plugs.RequireUser when action in [:new, :edit, :create, :update]

  plug :fetch_post when action in [:show, :photo, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]

  def fetch_post(conn, _args) do
    id = conn.params["id"]
    post = Posts.get_post!(id)
    assign(conn, :post, post)
  end

  def require_owner(conn, _args) do
    user = conn.assigns[:current_user]
    post = conn.assigns[:post]

    if user.id == post.user_id do
      conn
    else
      conn
      |> put_flash(:error, "That isn't yours.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    up = post_params["photo"]
    {:ok, hash} = Photos.save_photo(up.filename, up.path)
    post_params = post_params
    |> Map.put("user_id", conn.assigns[:current_user].id)
    |> Map.put("photo_hash", hash)

    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    post = Posts.load_comments(conn.assigns[:post])
    comm = %Comments.Comment{
      post_id: post.id,
      user_id: current_user_id(conn),
      vote: 0,
    }
    new_comment = Comments.change_comment(comm)
    render(conn, "show.html", post: post, new_comment: new_comment)
  end

  def photo(conn, %{"id" => _id}) do
    post = conn.assigns[:post]
    {:ok, _name, data} = Photos.load_photo(post.photo_hash)
    conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, data)
  end

  def edit(conn, %{"id" => _id}) do
    post = conn.assigns[:post]
    changeset = Posts.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "post" => post_params}) do
    post = conn.assigns[:post]
    up = post_params["photo"]

    post_params = if up do
      # FIXME: Remove old image
      {:ok, hash} = Photos.save_photo(up.filename, up.path)
      Map.put(post_params, "photo_hash", hash)
    else
      post_params
    end

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    post = conn.assigns[:post]
    # FIXME: Remove old image
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end
end
