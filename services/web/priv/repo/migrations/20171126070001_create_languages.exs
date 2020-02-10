defmodule HexletBasics.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :name, :string
      add :slug, :string
      add :extension, :string
      add :docker_image, :string
      add :exercise_filename, :string
      add :exercise_test_filename, :string
      add :state, :string
      add :upload_id, references(:uploads, on_delete: :nothing)

      timestamps()
    end

    create index(:languages, [:upload_id])
    create unique_index(:languages, [:slug])
  end
end
