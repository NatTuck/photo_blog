# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhotoBlog.Repo.insert!(%PhotoBlog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias PhotoBlog.Repo
alias PhotoBlog.Users.User
alias PhotoBlog.Posts.Post

alice = Repo.insert!(%User{name: "alice"})
bob = Repo.insert!(%User{name: "bob"})

Repo.insert!(%Post{user_id: alice.id, body: "Alice says Hi!"})
Repo.insert!(%Post{user_id: bob.id, body: "Bob says garblarg!"})
