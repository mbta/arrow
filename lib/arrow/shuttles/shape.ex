defmodule Arrow.Shuttles.Shape do
  @moduledoc "schema for shuttle shapes for the db"

  @derive {Phoenix.Param, key: :name}

  use Arrow.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :inserted_at, :updated_at]}

  @type id :: integer

  typed_schema "shapes" do
    field :name, :string
    field :bucket, :string
    field :path, :string
    field :prefix, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:name, :path, :bucket, :prefix], empty_values: ["-S" | empty_values()])
    |> validate_required([:name, :path, :bucket, :prefix])
    |> unique_constraint(:name)
    |> validate_change(:name, fn :name, name ->
      if String.ends_with?(name, "-S") do
        []
      else
        [{:name, "must end with -S"}]
      end
    end)
  end

  def validate_and_enforce_name(attrs, validate_name \\ true) do
    changeset =
      %__MODULE__{}
      |> cast(attrs, [:name])
      |> validate_required([:name])

    changeset =
      if validate_name do
        validate_format(
          changeset,
          :name,
          ~r/^[A-Z][A-Za-z0-9]*To[A-Z][A-Za-z0-9]*(?:Via[A-Z][A-Za-z0-9]*)?(?:-S)?$/,
          message:
            "should be PascalCase using only letters and numbers and include start and end location"
        )
      else
        changeset
      end

    cond do
      not changeset.valid? ->
        {:error, changeset}

      String.ends_with?(attrs.name, "-S") ->
        {:ok, attrs}

      true ->
        {:ok, Map.put(attrs, :name, "#{attrs.name}-S")}
    end
  end
end
