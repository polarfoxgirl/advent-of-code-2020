{:ok, input} = File.read("test_input")

defmodule CrabCups do
  defp find_insert_after_candidates(current, max_value) do
    cond do
      current > 4 -> (current-1)..(current-4)
      current > 1 ->
        Enum.concat((current - 1)..1, max_value..(max_value - 4 + current))
      current == 1 -> max_value..(max_value - 3)
    end
  end

  defp do_round(cups) do
    [current, r1, r2, r3 | tail] = cups

    insert_after = find_insert_after_candidates(current, 9)
      |> Enum.find(fn x -> x not in [r1, r2, r3] end)
    insert_pos = Enum.find_index(tail, fn x -> x == insert_value end)

    {tail1, tail2} = Enum.split(tail, insert_pos + 1)
    tail1 ++ [r1, r2, r3] ++ tail2 ++ [current]
  end

  def solve(input) do
    cups = input
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    result_cups = Enum.reduce(1..100, cups, fn _, acc -> do_round(acc) end)

    i_1 = Enum.find_index(result_cups, fn x -> x == 1 end)
    {tail, [1 | head]} = Enum.split(result_cups, i_1)
    result = head ++ tail

    IO.puts("Result: #{Enum.join(result)}")
  end
end

CrabCups.solve(input)
