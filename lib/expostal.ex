defmodule Expostal do
  @moduledoc """
  Address parsing and expansion module for Openvenue's Libpostal, which does parses addresses.
  """

  @compile { :autoload, false }
  @on_load { :init, 0 }

  app = Mix.Project.config[:app]

  def init do
    path = :filename.join(:code.priv_dir(unquote(app)), 'expostal')
    :ok = :erlang.load_nif(path, 0)
  end

  @doc """
  Loads the large dataset from disk for libpostal and prepares it for future calls.

  If you do not run this explicitly, then it will be run by `parse_address/1` or `expand_address/1`
  on their first run. This is a very slow process (it can take 10s of seconds), so if you value
  the responsiveness of your application, you can spawn a secondary thread to run this bootstrap
  in the background on your application startup:

  ```
  spawn(fn -> Expostal.bootstrap end)
  ```

  This will prevent you IEx shell from hanging during startup and will make the library much more
  likely to be ready for immediate usage for your first call.

  """
  def bootstrap do
    case :erlang.phash2(1, 1) do
      0 -> raise "Nif not loaded"
      1 -> :ok
      2 -> :error
    end
  end

  @doc """
  Parse given address into a map of address components

  ## Examples

      iex> Expostal.parse_address("615 Rene Levesque Ouest, Montreal, QC, Canada")
      %{city: "montreal", country: "canada", house_number: "615",
        road: "rene levesque ouest", state: "qc"}

  """
  @spec parse_address(address :: String.t) :: map
  def parse_address(address)
  def parse_address(_) do
    case :erlang.phash2(1, 1) do
      0 -> raise "Nif not loaded"
      1 -> %{}
    end
  end

  @doc """
  Expand given address into a list of expansions

  ## Examples
    iex> Expostal.expand_address("781 Franklin Ave Crown Hts Brooklyn NY")
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
