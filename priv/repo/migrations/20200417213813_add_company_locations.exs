defmodule Companies.Repo.Migrations.AddCompanyLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :street1, :string
      add :street2, :string
      add :city, :string, null: false
      add :state, :string, null: false
      add :country, :string, null: false
      add :postal_code, :string

      add :company_id, references(:companies), null: false
    end
  end
end
