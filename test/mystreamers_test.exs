defmodule MystreamersTest do
  # aync testing
  use ExUnit.Case, async: true

  doctest Mystreamers

  test "the truth" do
    assert 1 + 1 == 2
  end
  test "find index file" do
    assert Mystreamers.find_index("test/fixtures/emberjs") == "9af0270acb795f9dcafb5c51b1907628.m3u8"
  end
  test "return nil for non available index file" do
    assert Mystreamers.find_index("test/fixtures/nondir") == nil
  end
end
