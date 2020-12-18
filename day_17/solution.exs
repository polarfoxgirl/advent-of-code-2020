{:ok, input} = File.read("input")

defmodule  ConwayCubes do
  def parse_line(line_y) do
    {line, y} = line_y
    String.graphemes(line)
    |> Enum.with_index()
    |> Enum.filter(fn {v, _x} -> v == "#" end)
    |> Enum.map(fn {_v, x} -> {x, y} end)
  end

  def gen_offsets() do
    Enum.map(-1..1, fn i ->
      Enum.map(-1..1, fn j ->
        Enum.map(-1..1, fn k -> {i, j, k} end)
      end)
    end)
    |> List.flatten()
    |> Enum.reject(fn {i, j, k} -> {i, j, k} == {0, 0, 0} end)
  end

  def gen_neighbors(cube) do
    {x, y, z} = cube
    gen_offsets()
    |> Enum.map(fn {i, j, k} -> {x + i, y + j, z + k} end)
  end

  def check_state(cube, active_cubes) do
    nbr_count = gen_neighbors(cube)
      |> Enum.filter(&MapSet.member?(active_cubes, &1))
      |> Enum.count()

    if (MapSet.member?(active_cubes, cube)) do
      nbr_count == 2 or nbr_count == 3
    else
      nbr_count == 3
    end
  end

  def do_step(active_cubes, turn, max_turn) do
    if turn == max_turn do
      active_cubes
    else
      new_active_cubes = active_cubes
        |> Enum.map(&gen_neighbors/1)
        |> Enum.map(&MapSet.new/1)
        |> Enum.reduce(&MapSet.union/2)
        |> Enum.filter(&check_state(&1, active_cubes))
        |> MapSet.new()

      do_step(new_active_cubes, turn + 1, max_turn)
    end
  end

  def solve(input) do
    init_cubes = input
      |> String.split()
      |> Enum.with_index()
      |> Enum.map(&parse_line/1)
      |> List.flatten()
      |> Enum.map(fn {x, y} -> {x, y, 0} end)
      |> MapSet.new()

    IO.puts("Input counts: #{Enum.count(init_cubes)}")

    result_cubes = do_step(init_cubes, 0, 6)
    IO.puts("Result: #{Enum.count(result_cubes)}")
  end
end

 ConwayCubes.solve(input)
