defmodule ExpostalTest do
  use ExUnit.Case
  doctest Expostal

  test "parse address" do
    address = "615 Rene Levesque Ouest, Montreal, QC, Canada"
    parsed = Expostal.parse_address(address)

    assert parsed == %{
             country: "canada",
             city: "montreal",
             house_number: "615",
             road: "rene levesque ouest",
             state: "qc"
           }

    address = "92 rue de l'Église, QC"
    parsed = Expostal.parse_address(address)

    assert parsed == %{
             house_number: "92",
             road: "rue de l'église",
             state: "qc"
           }

    address = "天津市红桥区一号路一百号"
    parsed = Expostal.parse_address(address)

    assert parsed == %{
             city: "天津市红桥区",
             road: "一号路",
             house_number: "一百号"
           }
  end

  describe "Expand" do
    test "test address expansion" do
      assert address_in_expansion(
               "781 Franklin Ave Crown Hts Brooklyn NY",
               "781 franklin avenue crown heights brooklyn new york"
             )

      assert address_in_expansion(
               "781 Franklin Ave Crown Hts Brooklyn NY",
               "781 franklin avenue crown heights brooklyn new york"
             )

      assert address_in_expansion(
               "Friedrichstraße 128, Berlin, Germany",
               "friedrich strasse 128 berlin germany"
             )

      assert address_in_expansion("MAPLE ST.", "maple street")
      assert address_in_expansion("MAPLE ST.", "maple street")
    end
  end

  describe "Classify" do
    test "test address expansion" do
      assert Expostal.classify_language("") == {:error, :argument_error}

      assert Expostal.classify_language("781 Franklin Ave Crown Hts Brooklyn NY") ==
               {0.9999999997485425, ["en"]}

      assert Expostal.classify_language("Friedrichstraße 128,  Berlin, Germany") ==
               {0.9999970742636454, ["de"]}

      assert Expostal.classify_language("天津市红桥区一号路一百号") == {0.9241848948924529, ["ja", "zh"]}
      assert Expostal.classify_language("MAPLE ST.") == {0.9996832089814511, ["en"]}
      assert Expostal.classify_language("92 rue de l'Église, QC") == {0.9999999997818882, ["fr"]}
    end
  end

  defp address_in_expansion(original, expanded) do
    Enum.member?(Expostal.expand_address(original), expanded)
  end
end
