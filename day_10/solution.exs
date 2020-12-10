{:ok, input} = File.read("input")

defmodule AdapterArray do
  def process_adapter(adapters, i, dyno_map) do
    i_val = elem(adapters, i)

    sum = 1..3
      |> Enum.map(fn k -> i - k end)
      |> Enum.reject(fn j -> j < 0 end)
      |> Enum.filter(fn j -> i_val - elem(adapters, j) <= 3 end)
      |> Enum.map(&Map.fetch!(dyno_map, &1))
      |> Enum.sum()

    Map.put_new(dyno_map, i, sum)
  end

  def solve(input) do
    adapters = input
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()

    IO.puts("Input count: #{Enum.count(adapters)}")

    # Part 1
    charging_outlet = 0
    builtin_adapter = List.last(adapters) + 3
    # IO.puts("Built-in adapter: #{builtin_adapter}")

    adapters_from = List.insert_at(adapters, 0, charging_outlet)
    adapters_to = List.insert_at(adapters, -1, builtin_adapter)

    diff_map = Enum.zip(adapters_from, adapters_to)
      |> Enum.map(fn {x, y} -> y-x end)
      |> Enum.group_by(fn x -> x end)

    count_1 = Enum.count(Map.get(diff_map, 1, []))
    count_3 = Enum.count(Map.get(diff_map, 3, []))
    IO.puts("Result: #{count_1} * #{count_3} = #{count_1*count_3}")

    # Part 2 (Dynamic Programming!)
    all_adapters = adapters_from
      |> List.insert_at(-1, builtin_adapter)
      |> List.to_tuple()
    dyno_map = 1..(tuple_size(all_adapters) - 1)
      |> Enum.reduce(%{0 => 1}, &process_adapter(all_adapters, &1, &2))
    IO.puts("Dyno result: #{Map.fetch!(dyno_map, Enum.count(adapters_from))}")
  end
end

AdapterArray.solve(input)
