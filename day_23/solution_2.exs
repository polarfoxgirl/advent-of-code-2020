{:ok, input} = File.read("input")

defmodule CrabCups do

  @million 1000000

  defp find_insert_after_candidates(current, max_value) do
    cond do
      current > 4 -> (current-1)..(current-4)
      current > 1 ->
        Enum.concat((current - 1)..1, max_value..(max_value - 4 + current))
      current == 1 -> max_value..(max_value - 3)
    end
  end

  defp do_round(_i, acc) do
    {next_cups, current} = acc

    r1 = Map.fetch!(next_cups, current)
    r2 = Map.fetch!(next_cups, r1)
    r3 = Map.fetch!(next_cups, r2)
    new_current_next= Map.fetch!(next_cups, r3)

    insert_after = find_insert_after_candidates(current, @million)
      |> Enum.find(fn x -> x not in [r1, r2, r3] end)
    insert_before = Map.fetch!(next_cups, insert_after)

    upd_cups = next_cups
      |> Map.replace!(current, new_current_next)
      |> Map.replace!(insert_after, r1)
      |> Map.replace!(r3, insert_before)

    {upd_cups, new_current_next}
  end

  def solve(input) do
    cups = input
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    next_cups = 10..(@million - 1)
      |> Enum.map(fn x -> {x, x + 1} end)
      |> Map.new()

    [current | tail] = cups

    next_cups = cups
      |> Enum.zip(tail ++ [10])
      |> Map.new()
      |> Map.merge(next_cups)
      |> Map.put_new(@million, current)

    IO.puts("Init next cups with #{Enum.count(next_cups)}")

    {upd_cups, _} = Enum.reduce(1..(10*@million), {next_cups, current}, &do_round/2)

    cup1 = Map.fetch!(upd_cups, 1)
    cup2 = Map.fetch!(upd_cups, cup1)
    result = cup1 * cup2

    IO.puts("Result: #{cup1} * #{cup2} = #{result}")
  end
end

CrabCups.solve(input)
