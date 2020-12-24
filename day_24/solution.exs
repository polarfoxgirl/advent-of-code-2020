{:ok, input} = File.read("input")

defmodule LobbyLayout do
  defp parse_ch(ch, acc) do
    {path, mod} = acc
    if mod == nil do
      case ch do
        "n" -> {path, "n"}
        "s" -> {path, "s"}
        "e" -> {path ++ [:east], nil}
        "w" -> {path ++ [:west], nil}
      end
    else
      cond do
        ch == "e" and mod == "n" -> {path ++ [:ne], nil}
        ch == "e" and mod == "s" -> {path ++ [:se], nil}
        ch == "w" and mod == "n" -> {path ++ [:nw], nil}
        ch == "w" and mod == "s" -> {path ++ [:sw], nil}
      end
    end
  end

  defp parse_path(line) do
    {path, nil} = line
      |> String.graphemes()
      |> Enum.reduce({[], nil}, &parse_ch/2)

    path
  end

  defp do_tile_step(cmd, tile) do
    {x, y} = tile
    case cmd do
      :east -> {x + 2, y}
      :west -> {x - 2, y}
      :se -> {x + 1, y + 1}
      :sw -> {x - 1, y + 1}
      :ne -> {x + 1, y - 1}
      :nw -> {x - 1, y - 1}
    end
  end

  defp identify_tile(path) do
    Enum.reduce(path, {0, 0}, &do_tile_step/2)
  end

  defp gen_nbrs(tile) do
    [:east, :west, :se, :sw, :ne, :nw]
    |> Enum.map(&do_tile_step(&1, tile))
    |> MapSet.new()
  end

  defp is_now_black(tile, tiles) do
    nbr_cnt = gen_nbrs(tile)
      |> Enum.filter(fn n -> n in tiles end)
      |> Enum.count()

    if tile in tiles do
      (nbr_cnt > 0) and (nbr_cnt <= 2)
    else
      nbr_cnt == 2
    end
  end

  defp apply_day_changes(_day, tiles) do
    all_nbrs = tiles
      |> Enum.map(&gen_nbrs/1)
      |> Enum.reduce(&MapSet.union/2)
      |> MapSet.union(tiles)

    all_nbrs
    |> Enum.filter(&is_now_black(&1, tiles))
    |> MapSet.new()
  end

  def solve(input) do
    paths = input
      |> String.split()
      |> Enum.map(&parse_path/1)

    IO.puts("Input: got #{Enum.count(paths)} paths")

    # Part 1

    day_0_tiles = paths
      |> Enum.map(&identify_tile/1)
      |> Enum.frequencies()
      |> Enum.filter(fn {_tile, count} -> rem(count, 2) == 1 end)
      |> Enum.map(fn {k, _v} -> k end)
      |> MapSet.new()

    result = Enum.count(day_0_tiles)
    IO.puts("Result: #{result} tiles")

    # Part 2

    final_tiles = Enum.reduce(1..100, day_0_tiles, &apply_day_changes/2)
    IO.puts("Day 1 tiles: #{Enum.count(final_tiles)}")
  end
end

LobbyLayout.solve(input)
