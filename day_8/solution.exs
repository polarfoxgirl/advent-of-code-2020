{:ok, input} = File.read("input")

defmodule HandheldHalting do
  def parse_line(line) do
    regex = ~r/(\w{3}) \+?(\-?\d+)/
    [cmd, val] = Regex.run(regex, line, capture: :all_but_first)
    %{cmd: String.to_atom(cmd), arg: String.to_integer(val)}
  end

  def execute(instructions, visited, index, accumulator) do
    cond do
      index >= Enum.count(instructions) -> {:ok, accumulator}
      index < 0 -> :out_of_bounds_error
      MapSet.member?(visited, index) -> {:loop_error, visited}
      true ->
        instruction = Map.fetch!(instructions, index)
        new_visited = MapSet.put(visited, index)
        case instruction[:cmd] do
          :acc -> execute(instructions, new_visited, index + 1, accumulator + instruction[:arg])
          :jmp -> execute(instructions, new_visited, index + instruction[:arg], accumulator)
          :nop -> execute(instructions, new_visited, index + 1, accumulator)
        end
    end
  end

  def patch(instructions, visited) do
    index = visited
    |> Enum.find(fn i -> match?({:ok, _}, execute(instructions, visited, i + 1, 0)) end)

    Map.put(instructions, index, %{cmd: :nop, arg: 0})
  end

  def solve(input) do
    instructions = input
      |> String.split("\r\n")
      |> Enum.map(&HandheldHalting.parse_line/1)
      |> Enum.with_index()
      |> Map.new(fn {k, v} -> {v, k} end)

    IO.puts("Input count: #{Enum.count(instructions)}")

    {:loop_error, visited} = HandheldHalting.execute(instructions, MapSet.new(), 0, 0)
    new_instructions = HandheldHalting.patch(instructions, visited)

    {:ok, accumulator} = HandheldHalting.execute(new_instructions, MapSet.new(), 0, 0)
    IO.puts "Result: #{accumulator}"
  end
end

HandheldHalting.solve(input)
