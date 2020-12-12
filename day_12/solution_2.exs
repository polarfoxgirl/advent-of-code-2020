{:ok, input} = File.read("input")

defmodule RainRisk do
  def parse_line(line) do
    regex = ~r/([NESWLRF])(\d+)/
    [cmd, value] = Regex.run(regex, line, capture: :all_but_first)
    %{cmd: cmd, val: String.to_integer(value)}
  end

  def turn(turn_fn, value, direction) do
    times = div(value, 90)
    1..times
    |> Enum.reduce(direction, fn _i, acc -> turn_fn.(acc) end)
  end

  def move(instruction, acc) do
    {{x, y}, {wp_x, wp_y}} = acc
    %{cmd: cmd, val: value} = instruction

    turn_right= fn {i, j} -> {j, -i} end
    turn_left= fn {i, j} -> {-j, i} end

    case cmd do
      "N" -> {{x, y}, {wp_x, wp_y + value}}
      "E" -> {{x, y}, {wp_x + value, wp_y}}
      "S" -> {{x, y}, {wp_x, wp_y - value}}
      "W" -> {{x, y}, {wp_x - value, wp_y}}
      "L" -> {{x, y}, turn(turn_left, value, {wp_x, wp_y})}
      "R" -> {{x, y}, turn(turn_right, value, {wp_x, wp_y})}
      "F" -> {{x + wp_x * value, y + wp_y * value}, {wp_x, wp_y}}
    end
  end

  def solve(input) do
    instructions = input
      |> String.split()
      |> Enum.map(&parse_line/1)

    IO.puts("Input count: #{Enum.count(instructions)}")

    init_acc = {{0, 0}, {10, 1}}
    {{x, y}, _wp} = Enum.reduce(instructions, init_acc, &move/2)
    IO.puts("Result: abs(#{x}) + abs(#{y}) = #{abs(x) + abs(y)}")
  end
end

RainRisk.solve(input)
