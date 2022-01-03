defmodule Arrow.Disruption.Note do
  @moduledoc """
  Free-form text notes that can be attached to a disruption.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruption

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

  @doc """
  Produces a changeset to insert a new note. Expects a disruption_id which it
  belongs to, as well as the author, both generated internally. User-supplied
  data comes as params, with the field %{"body" => ...} supported.
  """
  @spec changeset(Arrow.Disruption.id(), String.t(), map()) :: Ecto.Changeset.t(t())
  def changeset(disruption_id, author, params) when byte_size(author) > 0 do
    %Disruption{id: disruption_id}
    |> Ecto.build_assoc(:notes)
    |> cast(params, [:body])
    |> put_change(:author, author)
    |> validate_required([:body, :author])
  end
end
