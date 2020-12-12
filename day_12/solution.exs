{:ok, input} = File.read("input")

defmodule RainRisk do
  def parse_line(line) do
    regex = ~r/([NESWLRF])(\d+)/
    [cmd, value] = Regex.run(regex, line, capture: :all_but_first)
    %{cmd: cmd, val: String.to_integer(value)}
  end

  def turn_ship(turn_fn, value, direction) do
    times = div(value, 90)
    1..times
    |> Enum.reduce(direction, fn _i, acc -> turn_fn.(acc) end)
  end

  def move_ship(instruction, acc) do
    {x, y, {dir_x, dir_y}} = acc
    %{cmd: cmd, val: value} = instruction

    turn_right= fn {i, j} -> {j, -i} end
    turn_left= fn {i, j} -> {-j, i} end

    case cmd do
      "N" -> {x, y + value, {dir_x, dir_y}}
      "E" -> {x + value, y, {dir_x, dir_y}}
      "S" -> {x, y - value, {dir_x, dir_y}}
      "W" -> {x - value, y, {dir_x, dir_y}}
      "L" -> {x, y, turn_ship(turn_left, value, {dir_x, dir_y})}
      "R" -> {x, y, turn_ship(turn_right, value, {dir_x, dir_y})}
      "F" -> {x + dir_x * value, y + dir_y * value, {dir_x, dir_y}}
    end
  end

  def solve(input) do
    instructions = input
      |> String.split()
      |> Enum.map(&parse_line/1)

    IO.puts("Input count: #{Enum.count(instructions)}")

    init_acc = {0, 0, {1, 0}}
    {x, y, _dir} = Enum.reduce(instructions, init_acc, &move_ship/2)
    IO.puts("Result: abs(#{x}) + abs(#{y}) = #{abs(x) + abs(y)}")
  end
end

RainRisk.solve(input)
