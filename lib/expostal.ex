defmodule Expostal do
  @moduledoc """
  Documentation for Expostal.
  """

  @on_load { :init, 0 }

  app = Mix.Project.config[:app]

  def init do
    path = :filename.join(:code.priv_dir(unquote(app)), 'expostal')
    :ok = :erlang.load_nif(path, 0)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Expostal.hello
      :world

  """
  def hello do
    :world
  end

  @spec parse_address_c(address :: charlist()) :: charlist()
  def parse_address_c(address)
  def parse_address_c(_) do
    exit(:nif_library_not_loaded)
  end

  @spec parse_address(address :: String.t) :: String.t
  def parse_address(address) do
    for {k, v} <- parse_address_c(to_charlist address), into: %{}, do: {k, to_string v}
  end

end
