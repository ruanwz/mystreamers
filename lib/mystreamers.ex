defmodule Mystreamers do
  @doc """
  find streaming file in given directory  

  ## examples
    iex> Mystreamers.find_index "dont_exists"
    nil
  """
  def find_index(dir) do
    files = Path.join(dir,"*.m3u8")
    if file = Enum.find Path.wildcard(files), &is_index?(&1) do
       Path.basename file
    end
  end

  defp is_index?(file) do
    # don't use exception for control, so File.read returns {:ok, "content"}
    # File.open! create a new process to manage the file, so return a pid
    File.open! file, [:read], fn(pid)->
      # send msg to process to read file content
      # that is why IO not block in Erlang, because it is concurrently
      IO.read(pid, 25) == "#EXTM3U\n#EXT-X-STREAM-INF"
    end

  end

end
    # everything in elixir like a keyword, need to use do block
    # if is a macro, not a keyword
    # if some do: xxx else: yyy is the same as :
    # if some do
    #   xxx
    # else
    #   yyy
    # end
