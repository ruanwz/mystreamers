defmodule MystreamersTest do
  # aync testing
  use ExUnit.Case, async: true

  doctest Mystreamers

  @index_file "test/fixtures/emberjs/9af0270acb795f9dcafb5c51b1907628.m3u8"

  test "the truth" do
    assert 1 + 1 == 2
  end
  test "find index file" do
    assert Mystreamers.find_index("test/fixtures/emberjs") == @index_file
  end
  test "return nil for non available index file" do
    assert Mystreamers.find_index("test/fixtures/nondir") == nil
  end
  test "extract m3u8 info from index file" do
    m3u8s = Mystreamers.extract_m3u8 @index_file
    assert Enum.at(m3u8s, 0) == (Mystreamers.m3u8(program_id: ?1, bandwidth: 110000, path: "8bda35243c7c0a7fc69ebe1383c6464c.m3u8"))

  end


end
