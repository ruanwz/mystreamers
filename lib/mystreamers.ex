defmodule Mystreamers do
  require Record
  Record.defrecord :m3u8, program_id: nil, path: nil, bandwidth: nil, ts_files: []
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
  @doc """
  extract m3u8 records from index file
  """

  def extract_m3u8(index_file) do
    # dont read all content into memory, open file in a process
    File.open! index_file, [:read], fn(pid)->
      IO.read(pid,:line)
      # use accumulator
      do_extract_m3u8(pid, Path.dirname(index_file), [])
    end

  end
  defp do_extract_m3u8(pid, dir, acc) do
    case IO.read(pid, :line) do
      :eof ->Enum.reverse acc
      stream_inf ->
        path = IO.read(pid, :line)
        do_extract_m3u8(pid, dir, stream_inf, path, acc)
    end
  end
  defp do_extract_m3u8(pid, dir, stream_inf, path, acc) do
    # string in elixir is binary
    # <<"jos",x::utf8>> = "jos中"
    "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=110000"
    << "#EXT-X-STREAM-INF:PROGRAM-ID=",program_id,",BANDWIDTH=",bandwidth::binary >> = stream_inf

    path = Path.join(dir, String.strip(path))
    record = m3u8(program_id: program_id - ?0, path: String.strip(path), bandwidth: (bandwidth |> String.strip |> String.to_integer))
    acc = [record|acc]
    do_extract_m3u8(pid, dir, acc)

  end
  @doc """
  process m3u8 records to get ts_files
  """
  def process_m3u8(m3u8s) do
    Enum.map m3u8s, &do_process_m3u8(&1, self)

  end

  # do pattern matching in params
  defp do_process_m3u8(m3u8(path: path)=m3u8_rec, parent_pid) do
    #   #EXTM3U
    #   #EXT-X-TARGETDURATION:11
    #   #EXTINF:10,
    #   265c58c98c2d8b04f21ea9d7b73ee4af-00001.ts
    File.open! path, [:read], fn(pid)->
      #skip line1
      IO.read(pid,:line)
      #skip line2
      IO.read(pid,:line)
      ts_files = do_process_m3u8(pid,[])
      m3u8(m3u8, path: path, ts_files: ts_files)
    end
  end
  defp do_process_m3u8(pid, acc) do
    #skip
    case IO.read(pid, :line) do
      "#EXT-X-ENDLIST\n" ->Enum.reverse acc
      _ext_info -> # skip first line
        file = IO.read(pid, :line) |> String.strip
        do_process_m3u8(pid,[file|acc])


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
