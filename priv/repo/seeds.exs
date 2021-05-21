alias Exgetapi.Name
alias Exgetapi.Repo

Enum.each(
  Enum.to_list(?A..?Z),
  fn alphabet ->
    Repo.insert!(%Name{
      name: << alphabet >>
    })
  end
)
