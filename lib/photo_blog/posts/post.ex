defmodule PhotoBlog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :photo_hash, :string
    belongs_to :user, PhotoBlog.Users.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :photo_hash, :user_id])
    |> validate_required([:body, :photo_hash, :user_id])
  end
end
