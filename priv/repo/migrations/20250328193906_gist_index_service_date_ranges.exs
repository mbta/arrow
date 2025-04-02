defmodule Arrow.Repo.Migrations.GistIndexServiceDateRanges do
  use Ecto.Migration

  def change do
    create index(:hastus_service_dates, ["(daterange(start_date, end_date))"], using: :gist)
  end
end
