{:ok, input} = File.read("input")

defmodule TobogganTrajectory do
  def map_char(ch) do
    case ch do
      "#" -> true
      "." -> false
    end
  end

  def process_row(row, position, right_shift) do
      new_position = rem(position + right_shift, Enum.count(row))
      row_tree_count = if Enum.at(row, position), do: 1, else: 0
      %{position: new_position, counter: row_tree_count}
  end

  def accumulate(row, acc, right_shift) do
    %{position: position, counter: counter} = acc
    %{position: new_position, counter: row_counter} =
      TobogganTrajectory.process_row(row, position, right_shift)
    %{position: new_position, counter: row_counter + counter}
  end

  def count_trees(terrain, right_shift \\ 3) do
    terrain
    |> Enum.reduce(%{position: 0, counter: 0}, &(TobogganTrajectory.accumulate(&1, &2, right_shift)))
  end

  def solve(input) do
    terrain = input
    |> String.split()
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn chars -> Enum.map(chars, &TobogganTrajectory.map_char/1) end)

    IO.puts "Row count: #{Enum.count(terrain)}"
    # 1, 1
    %{position: _position, counter: counter1} = TobogganTrajectory.count_trees(terrain, 1)
    IO.puts "Result1: #{counter1}"

    # 3, 1
    %{position: _position, counter: counter2} = TobogganTrajectory.count_trees(terrain, 3)
    IO.puts "Result2: #{counter2}"

    # 5, 1
    %{position: _position, counter: counter3} = TobogganTrajectory.count_trees(terrain, 5)
    IO.puts "Result3: #{counter3}"

    # 7, 1
    %{position: _position, counter: counter4} = TobogganTrajectory.count_trees(terrain, 7)
    IO.puts "Result4: #{counter4}"

    # 1, 2
    fast_terrain = Enum.take_every(terrain, 2)
    %{position: _position, counter: counter5} = TobogganTrajectory.count_trees(fast_terrain, 1)
    IO.puts "Result5: #{counter5}"

    IO.puts "Total: #{counter1*counter2*counter3*counter4*counter5}"
  end
end

TobogganTrajectory.solve(input)
