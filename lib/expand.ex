defmodule Expostal.Expand do
  @moduledoc """
  Address expansion module for Openvenue's Libpostal, which does expands addresses.
  """

  @compile { :autoload, false }
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
  @spec expand_address(address :: String.t) :: [String.t]
  def expand_address(address) do
    case :erlang.phash2(1, 1) do
      0 -> raise "Nif not loaded"
      1 -> [address]
    end
  end

end
