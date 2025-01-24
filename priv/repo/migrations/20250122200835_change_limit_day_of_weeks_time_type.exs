defmodule Arrow.Repo.Migrations.ChangeLimitDayOfWeeksTimeType do
  use Ecto.Migration

  def change do
    alter table(:limit_day_of_weeks) do
      modify :start_time, :text, from: :time
      modify :end_time, :text, from: :time
    end
  end
end
