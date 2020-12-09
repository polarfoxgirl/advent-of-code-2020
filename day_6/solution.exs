{:ok, input} = File.read("input")

defmodule CustomCustoms do
  def process_group(forms) do
    # IO.puts("Got #{Enum.count(forms)} forms")
    answers = forms
      |> Enum.map(&MapSet.new(String.graphemes(&1)))
      # |> Enum.reduce(&MapSet.union/2)
      |> Enum.reduce(&MapSet.intersection/2)

    # IO.puts("Got #{Enum.count(answers)} unique answers")
    Enum.count(answers)
  end

  def solve(input) do
    groups = input
      |> String.split("\r\n\r\n")
      |> Enum.map(&String.split/1)
      |> Enum.map(&CustomCustoms.process_group/1)

    IO.puts "Input count: #{Enum.count(groups)}"
    result = Enum.sum(groups)
    IO.puts "Result: #{result}"
  end
end

CustomCustoms.solve(input)
