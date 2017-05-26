defmodule Expostal do
  @moduledoc """
  Expostal is an Elixir binding for Openvenue's Libpostal, which does parsing of street addresses.
  """

  @on_load { :init, 0 }

  app = Mix.Project.config[:app]

  defp init do
    path = :filename.join(:code.priv_dir(unquote(app)), 'expostal')
    :ok = :erlang.load_nif(path, 0)
  end

  @spec parse_address_c(address :: charlist()) :: charlist()
  defp parse_address_c(address)
  defp parse_address_c(_) do
    exit(:nif_library_not_loaded)
  end

  @doc """
  Parse given address into a map of address components

  ## Examples

      iex> Expostal.parse_address("615 Rene Levesque Ouest, Montreal, QC, Canada")
      %{city: "montreal", country: "canada", house_number: "615",
        road: "rene levesque ouest", state: "qc"}

  """
  @spec parse_address(address :: String.t) :: String.t
  def parse_address(address) do
    for {k, v} <- parse_address_c(to_charlist address), into: %{}, do: {k, to_string v}
  end

end
