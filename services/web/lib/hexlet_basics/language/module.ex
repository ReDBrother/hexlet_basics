defmodule HexletBasics.Language.Module do
  use Ecto.Schema
  import Ecto.Changeset
  alias HexletBasics.Language.Module

  @derive {Jason.Encoder, only: [:id, :slug]}

  schema "language_modules" do
    field(:slug, :string)
    field(:state, :string)
    field(:order, :integer)

    belongs_to(:upload, HexletBasics.Upload)
    belongs_to(:language, HexletBasics.Language)
    has_many(:descriptions, Module.Description)
    has_many(:lessons, Module.Lesson)

    timestamps()
  end

  @doc false
  def changeset(%Module{} = module, attrs) do
    module
    |> cast(attrs, [:slug, :state, :order, :language_id, :upload_id])
    |> validate_required([:slug, :order])
  end

  def get_directory(module) do
    "#{module.order}-#{module.slug}"
  end
end
