defmodule PhotoBlog.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :votes, :integer
    belongs_to :post, PhotoBlog.Posts.Post
    belongs_to :user, PhotoBlog.Users.User

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:votes, :user_id, :post_id])
    |> validate_required([:votes, :user_id, :post_id])
  end
end
