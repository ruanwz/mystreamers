defmodule MystreamersTest do
  # aync testing
  use ExUnit.Case, async: true

  doctest Mystreamers

  @index_file "test/fixtures/emberjs/9af0270acb795f9dcafb5c51b1907628.m3u8"
  @sample_file "test/fixtures/emberjs/8bda35243c7c0a7fc69ebe1383c6464c.m3u8"

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
    assert Enum.at(m3u8s, 0) == (Mystreamers.m3u8(program_id: 1, bandwidth: 110000, path: @sample_file))

  end

  test "process m3u8" do
    m3u8s = @index_file |> Mystreamers.extract_m3u8 |> Mystreamers.process_m3u8
    sample = Enum.find(m3u8s, fn(m3u8) -> Mystreamers.m3u8(m3u8,:path) == @sample_file end)
    assert length(Mystreamers.m3u8(sample, :ts_files)) == 510
  end

end
