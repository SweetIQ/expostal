defmodule Expostal.Expand do
  @moduledoc """
  Address expansion module for Openvenue's Libpostal, which does expands addresses.
  """

  @on_load { :init, 0 }

  app = Mix.Project.config[:app]

  defp init do
    path = :filename.join(:code.priv_dir(unquote(app)), 'expand')
    :ok = :erlang.load_nif(path, 0)
  end

  @doc """
  Expand given address into a list of expansions

  ## Examples
    iex> Expostal.Expand.expand_address("781 Franklin Ave Crown Hts Brooklyn NY")
    ["781 franklin avenue crown heights brooklyn new york",
     "781 franklin avenue crown heights brooklyn ny"]

  """
  @spec expand_address(address :: String.t) :: list(String.t)
  def expand_address(address)
  def expand_address(_) do
    exit(:nif_library_not_loaded)
  end

end
