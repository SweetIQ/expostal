defmodule ExpostalTest.Expand do
  use ExUnit.Case
  doctest Expostal.Expand

  describe "Expand" do
    test "test address expansion" do
      assert address_in_expansion(
        "781 Franklin Ave Crown Hts Brooklyn NY",
        "781 franklin avenue crown heights brooklyn new york"
      )
      assert address_in_expansion("781 Franklin Ave Crown Hts Brooklyn NY", "781 franklin avenue crown heights brooklyn new york")

      assert address_in_expansion("Friedrichstraße 128, Berlin, Germany", "friedrich straße 128 berlin germany")

      assert address_in_expansion("MAPLE ST.", "maple street")
      assert address_in_expansion("MAPLE ST.", "maple street")

    end
  end

  defp address_in_expansion(original, expanded) do
    Enum.member?(Expostal.Expand.expand_address(original), expanded)
  end
end
