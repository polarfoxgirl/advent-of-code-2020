{:ok, input} = File.read("input")

defmodule EncodingError do
  def is_valid(prev_numbers, value) do
    # TODO: reuse this data
    prev_numbers
    |> Enum.map(&Enum.map(List.delete(prev_numbers, &1), fn x -> x + &1 end))
    |> List.flatten()
    |> Enum.any?(fn x -> x == value end)
  end

  def process_value(length, value, prev_numbers) do
    cond do
      Enum.count(prev_numbers) < length ->
        {:cont, List.insert_at(prev_numbers, -1, value)}
      is_valid(prev_numbers, value) ->
        updated_numbers = prev_numbers
          |> List.delete_at(0)
          |> List.insert_at(-1, value)
        {:cont, updated_numbers}
      true ->
        {:halt, value}
    end
  end

  def find_sum(code_tup, target, sum, i1, i2) do
    if i2 >= tuple_size(code_tup) do
      {:out_of_bounds_error}
    else
      e1 = elem(code_tup, i1)
      e2 = elem(code_tup, i2)
      new_sum = e2 + sum
      cond do
        new_sum == target ->
          {:ok, i1, i2}
        (new_sum > target) and (i2 - i1 > 2) ->
          find_sum(code_tup, target, sum - e1, i1 + 1, i2)
        true ->
          find_sum(code_tup, target, new_sum, i1, i2 + 1)
      end
    end
  end

  def solve(input) do
    code = input
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    preamble_len = 25

    IO.puts("Input count: #{Enum.count(code)}")
    result = Enum.reduce_while(code, [], &EncodingError.process_value(preamble_len, &1, &2))
    IO.puts "Result: #{result}"

    # Part 2
    code_tup = List.to_tuple(code)
    init_sum = elem(code_tup, 0) + elem(code_tup, 1)
    {:ok, i1, i2} = find_sum(code_tup, result, init_sum, 0, 2)
    value_range = Enum.map(i1..i2, &Kernel.elem(code_tup, &1))
    result2 = Enum.min(value_range) + Enum.max(value_range)
    IO.puts "Result 2: #{result2}"
  end
end

EncodingError.solve(input)
