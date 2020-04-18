defmodule Companies.Schemas.Location do
  use Ecto.Schema

  import Ecto.Changeset

  schema "locations" do
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :country, :string
    field :postal_code, :string
    field :state, :string

    field :geom, Geo.PostGIS.Geometry

    field :latitude, :float, virtual: true
    field :longitude, :float, virtual: true

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:address1, :address2, :city, :country, :latitude, :longitude, :postal_code, :state])
    |> validate_required([:address1, :city, :postal_code, :state])
    |> put_geom()
  end

  defp put_geom(%{changes: %{latitude: latitude, longitude: longitude}} = changeset),
    do: put_change(changeset, :geom, %Geo.Point{coordinates: {longitude, latitude}, srid: 4326})

  defp put_geom(changeset), do: changeset
end
