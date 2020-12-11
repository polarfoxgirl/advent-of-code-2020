{:ok, input} = File.read("input")

defmodule SeatingSystem do
  def parse_line(line_pair) do
    {line, i} = line_pair

    parse_char = fn ch ->
      case ch do
        "." -> :floor
        "L" -> :empty
      end
    end

    line
    |> String.graphemes()
    |> Enum.map(parse_char)
    |> Enum.with_index()
    |> Enum.map(fn {v, j} -> {{i, j}, v} end)
  end

  def get_neighbors(seat, seat_map, height, width) do
    {x, y} = seat

    Enum.map(-1..1, fn i -> Enum.map(-1..1, fn j -> {i, j} end) end)
    |> List.flatten()
    |> Enum.reject(fn pair -> pair == {0, 0} end)
    |> Enum.map(fn {i, j} -> {x + i, y + j} end)
    |> Enum.reject(fn {x1, y1} -> (x1 < 0) or (x1 >= height) or (y1 < 0) or (y1 >= width) end)
    |> Enum.map(&Map.fetch!(seat_map, &1))
    |> Enum.filter(fn v -> v == :taken end)
    |> Enum.count()
  end

  #   0 1 2 3 4
  # 0 _ * _ ! _
  # 1 _ * ! _ _
  # 2 _ # * * *
  #
  # (3 by 5)
  #
  # {x, y} = {2, 1}
  # For {i, j} = {-1, 0}: limit_x = 2 (x), limit_y = 0
  # For {i, j} = {0, 1}: limit_x = 0, limit_y = 3 (5 - y - 1)
  def find_in_los(seat, direction, seat_map, height, width) do
    {x, y} = seat
    {i, j} = direction

    get_los_len_1d = fn step, current, max ->
      case step do
        -1 -> current
        1 -> max - current - 1
        0 -> nil
      end
    end

    los_len_x = get_los_len_1d.(i, x, height)
    los_len_y = get_los_len_1d.(j, y, width)

    get_los_len_2d = fn len_x, len_y ->
      cond do
        len_x == nil -> len_y
        len_y == nil -> len_x
        true -> min(len_x, len_y)
      end
    end
    los_len = get_los_len_2d.(los_len_x, los_len_y)

    check_los_seat = fn step ->
      value = Map.fetch!(seat_map, {x + i*step, y + j*step})
      case value do
        :floor -> nil
        _ -> value
      end
    end

    if los_len > 0 do
      Enum.find_value(1..los_len, :floor, check_los_seat)
    else
      :floor
    end
  end

  def get_los_neighbors(seat, seat_map, height, width) do
    Enum.map(-1..1, fn i -> Enum.map(-1..1, fn j -> {i, j} end) end)
    |> List.flatten()
    |> Enum.reject(fn pair -> pair == {0, 0} end)
    |> Enum.map(&find_in_los(seat, &1, seat_map, height, width))
    |> Enum.filter(fn v -> v == :taken end)
    |> Enum.count()
  end

  def process_seat(seat, acc_pair, seat_map, height, width) do
    {new_seat_map, change_count} = acc_pair
    seat_status = Map.fetch!(seat_map, seat)

    if seat_status == :floor do
      {new_seat_map, change_count}
    else
      nbr_count = get_los_neighbors(seat, seat_map, height, width)

      cond do
        seat_status == :taken and nbr_count >= 5 -> # Use 4 for Part 1
          # IO.puts("Removing seat: (#{elem(seat, 0)}, #{elem(seat, 1)})")
          {Map.replace!(new_seat_map, seat, :empty), change_count + 1}
        seat_status == :empty and nbr_count == 0 ->
          # IO.puts("Adding seat: (#{elem(seat, 0)}, #{elem(seat, 1)})")
          {Map.replace!(new_seat_map, seat, :taken), change_count + 1}
        true ->
          {new_seat_map, change_count}
      end
    end
  end

  def do_step(seat_map, height, width, step_count) do
    seats = Map.keys(seat_map)

    {new_seat_map, change_count} = seats
      |> Enum.reduce({seat_map, 0}, &process_seat(&1, &2, seat_map, height, width))

    if change_count > 0 do
      do_step(new_seat_map, height, width, step_count + 1)
    else
      {new_seat_map, step_count}
    end
  end

  def solve(input) do
    seat_rows = input
      |> String.split()
      |> Enum.with_index()
      |> Enum.map(&parse_line/1)

    height = Enum.count(seat_rows)
    width = Enum.count(List.first(seat_rows))

    seat_map = Map.new(List.flatten(seat_rows))
    IO.puts("Input count: #{Enum.count(seat_map)} (#{height} by #{width})")

    {final_map, step_count} = do_step(seat_map, height, width, 0)
    IO.puts("Simulation step count: #{step_count}")

    result = final_map
      |> Map.values()
      |> Enum.count(fn v -> v == :taken end)
    IO.puts("Result: #{result}")
  end
end

SeatingSystem.solve(input)
