defmodule Mystreamers do
  require Record
  Record.defrecord :m3u8, program_id: nil, path: nil, bandwidth: nil
  @doc """
  find streaming file in given directory  

  ## examples
    iex> Mystreamers.find_index "dont_exists"
    nil
  """
  def find_index(dir) do
    files = Path.join(dir,"*.m3u8")
    if file = Enum.find Path.wildcard(files), &is_index?(&1) do
       file
    end
  end

  def extract_m3u8(index_file) do
    # dont read all content into memory, open file in a process
    File.open! index_file, [:read], fn(pid)->
      IO.read(pid,:line)
      # use accumulator
      do_extract_m3u8(pid, [])
    end

  end
  defp do_extract_m3u8(pid, acc) do
    case IO.read(pid, :line) do
      :eof ->Enum.reverse acc
      stream_inf ->
        path = IO.read(pid, :line)
        do_extract_m3u8(pid, stream_inf, path, acc)
    end
  end
  defp do_extract_m3u8(pid, stream_inf, path, acc) do
    # string in elixir is binary
    # <<"jos",x::utf8>> = "jos中"
    "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=110000"
    << "#EXT-X-STREAM-INF:PROGRAM-ID=",program_id,",BANDWIDTH=",bandwidth::binary >> = stream_inf

    record = m3u8(program_id: program_id - ?0, path: String.strip(path), bandwidth: (bandwidth |> String.strip |> String.to_integer))
    acc = [record|acc]
    do_extract_m3u8(pid, acc)

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
