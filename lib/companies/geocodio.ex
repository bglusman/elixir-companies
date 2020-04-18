defmodule Companies.Geocodio do
  def geocode(street, city, state, postal_code, country) do
    headers = [
      {"content-type", "application/json"}
    ]

    params = %{
      api_key: api_key(),
      country: country,
      city: city,
      limit: 1,
      postal_code: postal_code,
      state: state,
      street: street
    }

    complete_path = "/v1.4/geocode?#{URI.encode_query(params)}"

    with {:ok, conn} <- Mint.HTTP.connect(:https, "api.geocod.io", 443),
         {:ok, conn, request_ref} <-
           Mint.HTTP.request(conn, "GET", complete_path, headers, ""),
         {:ok, body} <- receive_stream(conn, request_ref) do
      {:ok, Jason.decode!(body)}
    end
  end

  defp api_key, do: Application.get_env(:taxi, :geocodio_api_key)

  defp handle_responses(conn, request_ref, responses, acc) do
    results =
      Enum.reduce_while(responses, acc, fn
        {:data, ^request_ref, data}, acc -> {:cont, acc <> data}
        {:done, ^request_ref}, acc -> {:halt, {:ok, acc}}
        {:error, reason, _}, _acc -> {:halt, {:error, reason}}
        _chunk, acc -> {:cont, acc}
      end)

    with body when is_binary(body) <- results do
      receive_stream(conn, request_ref, body)
    end
  end

  defp receive_stream(conn, request_ref, acc \\ "") do
    receive do
      message ->
        {:ok, conn, responses} = Mint.HTTP.stream(conn, message)
        handle_responses(conn, request_ref, responses, acc)
    end
  end
end
