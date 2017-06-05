defmodule Expostal.Parser do
  @moduledoc """
  Address parsing module for Openvenue's Libpostal, which does parses addresses.
  """

  @on_load { :init, 0 }

  app = Mix.Project.config[:app]

  defp init do
    path = :filename.join(:code.priv_dir(unquote(app)), 'parser')
    :ok = :erlang.load_nif(path, 0)
  end

  @doc """
  Parse given address into a map of address components

  ## Examples

      iex> Expostal.Parser.parse_address("615 Rene Levesque Ouest, Montreal, QC, Canada")
      %{city: "montreal", country: "canada", house_number: "615",
        road: "rene levesque ouest", state: "qc"}

  """
  @spec parse_address(address :: String.t) :: String.t
  def parse_address(address)
  def parse_address(_) do
    exit(:nif_library_not_loaded)
  end

end
