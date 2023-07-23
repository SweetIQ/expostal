defmodule Expostal do
  @moduledoc """
  Address parsing and expansion module for Openvenue's Libpostal, which does parses addresses.
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  app = Mix.Project.config()[:app]

  def init do
    path = :filename.join(:code.priv_dir(unquote(app)), ~c"expostal")
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
  @spec parse_address(address :: String.t()) :: map
  def parse_address(address), do: _parse_address(address)

  def _parse_address(_) do
    case :erlang.phash2(1, 1) do
      0 -> raise "Nif not loaded"
      1 -> %{}
    end
  end

  @doc """

  Expand given address into a list of expansions

  ## Examples

    iex> Expostal.expand_address("781 Franklin Ave Crown Hts Brooklyn NY")
    ["781 franklin avenue crown heights brooklyn ny",
     "781 franklin avenue crown heights brooklyn new york"]

  """
  @spec expand_address(address :: String.t()) :: [String.t()]
  def expand_address(address), do: _expand_address(address)

  def _expand_address(address) do
    case :erlang.phash2(1, 1) do
      0 -> raise "Nif not loaded"
      1 -> [address]
    end
  end

  @doc """

  Returns a tuple with probability of the most probable language
  for a given address and a language list

  ## Examples

    iex> Expostal.classify_language("agricola pl.")
    {0.508300861587544, ["en", "fr", "es", "de"]}

  """
  @spec classify_language(address :: String.t()) :: {float, [String.t()]} | {:error, :argument_error}
  def classify_language(""), do: {:error, :argument_error}

  def classify_language(address) when is_binary(address) do
    try do
      _classify_language(address)
    rescue
      _ ->
        {:error, :argument_error}
    end
  end

  def _classify_language(address) do
    case :erlang.phash2(1, 1) do
      0 -> raise "Nif not loaded"
      1 -> {0.0, []}
    end
  end
end
