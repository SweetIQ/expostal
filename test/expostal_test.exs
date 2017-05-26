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
end
