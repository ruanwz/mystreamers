defmodule Mystreamers do
  def find_index(dir) do
    files = Path.join(dir,"*.m3u8")
    (Enum.find Path.wildcard(files), &is_index?(&1)) |> Path.basename
  end

  def is_index?(file) do
    # don't use exception for control, so File.read returns {:ok, "content"}
    # File.open! create a new process to manage the file, so return a pid
    File.open! file, [:read], fn(pid)->
      IO.read(pid, 25) == "#EXTM3U\n#EXT-X-STREAM-INF"
    end

  end

end
