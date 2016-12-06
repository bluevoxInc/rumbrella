# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rumbl.Repo.insert!(%Rumbl.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

#alias Rumbl.User
alias Rumbl.Repo
alias Rumbl.Category

#Repo.insert(%User{name: "Jose", username: "josevalim", password_hash: "<3<elixir"})
#Repo.insert(%User{name: "Bruce", username: "redrapids", password_hash: "7langs"})
#Repo.insert(%User{name: "Chris", username: "cmccord", password_hash: "phoenix"})

#for u <- Repo.all(User) do 
#Repo.update!(User.registration_changeset(u, %{password: u.password_hash || "temppass"}))
#end

for category <- ~w(Action Drama Romance Comedy Sci-fi) do
  Repo.get_by(Category, name: category) || Repo.insert!(%Category{name: category})
end
