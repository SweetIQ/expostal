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
  end

  test "parse non-ascii address" do
    address = "92 rue de l'Église"
    parsed = Expostal.parse_address(address)
    assert parsed == %{
      house_number: "92",
      road: "rue de l'église",
    }
  end

  test "parse Chinese address" do
    address = "天津市红桥区一号路 188号"
    parsed = Expostal.parse_address(address)
    assert parsed == %{
      city: "天津市红桥区",
      road: "一号路",
      house_number: "188号",
    }
  end
end
