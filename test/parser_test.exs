defmodule ExpostalTest.Parser do
  use ExUnit.Case
  doctest Expostal.Parser
  test "parse address" do
    address = "615 Rene Levesque Ouest, Montreal, QC, Canada"
    parsed = Expostal.Parser.parse_address(address)
    assert parsed == %{
      country: "canada",
      city: "montreal",
      house_number: "615",
      road: "rene levesque ouest",
      state: "qc"
    }

    address = "92 rue de l'Église, QC"
    parsed = Expostal.Parser.parse_address(address)
    assert parsed == %{
      house_number: "92",
      road: "rue de l'église",
      state: "qc"
    }

    address = "天津市红桥区一号路一百号"
    parsed = Expostal.Parser.parse_address(address)
    assert parsed == %{
      city: "天津市红桥区",
      road: "一号路",
      house_number: "一百号",
    }
  end
end
