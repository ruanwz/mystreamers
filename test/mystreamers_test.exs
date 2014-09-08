defmodule MystreamersTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end
  test "find index file" do
    assert Mystreamers.find_index("fixtures") == "9af0270acb795f9dcafb5c51b1907628"
  end
end
