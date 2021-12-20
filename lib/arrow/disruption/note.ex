defmodule Arrow.Disruption.Note do
  @moduledoc """
  Free-form text notes that can be attached to a disruption.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          body: String.t(),
          author: String.t(),
          disruption: Arrow.Disruption.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "disruption_notes" do
    field(:body, :string)
    field(:author, :string)
    belongs_to(:disruption, Arrow.Disruption)

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(String.t(), String.t(), map()) :: Ecto.Changeset.t(t())
  def changeset(disruption_id, author, params \\ %{}) when is_binary(author) do
    %__MODULE__{disruption_id: disruption_id}
    |> cast(params, [:body])
    |> put_change(:author, author)
    |> validate_required([:body, :author])
  end
end
