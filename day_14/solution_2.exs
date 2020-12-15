use Bitwise, only_operators: true

{:ok, input} = File.read("input")

defmodule DockingData do
  def parse_line(line) do
    mask_regex = ~r/mask = ([X01]+)/
    mem_regex = ~r/mem\[(\d+)\] = (\d+)/

    if String.starts_with?(line, "mask") do
      [mask_str] = Regex.run(mask_regex, line, capture: :all_but_first)
      mask = mask_str
        |> String.graphemes()
        |> Enum.reverse()
        |> List.to_tuple()

      {:mask, mask}
    else
      [address_str, value_str] = Regex.run(mem_regex, line, capture: :all_but_first)
      {:mem, String.to_integer(address_str), String.to_integer(value_str)}
    end
  end

  def get_bin_str(n) do
    Integer.digits(n, 2)
    |> Enum.reverse()
    |> Enum.map(&Integer.to_string/1)
    |> Enum.reduce(&<>/2)
  end

  def apply_address_mask(address, mask) do
    process_bit = fn {b, i}, acc_list ->
      case elem(mask, i) do
        "0" -> Enum.map(acc_list, fn x -> x ++ [b] end)
        "1" -> Enum.map(acc_list, fn x -> x ++ [1] end)
        "X" ->
          acc_list
            |> Enum.map(fn x -> [x ++ [0], x ++ [1]] end)
            |> Enum.reduce(&++/2)
      end
    end

    bits = Integer.digits(address, 2)
      |> Enum.reverse()

    padded_bits = bits ++ Enum.map(0..(35 - Enum.count(bits)), fn _ -> 0 end)

    padded_bits
    |> Enum.with_index()
    |> Enum.reduce([[]], process_bit)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&Integer.undigits(&1, 2))
  end

  def process_results(cmd, acc) do
    {mask, memory_map} = acc

    case elem(cmd, 0) do
      :mask ->
        {:mask, new_mask} = cmd
        # IO.puts("Got mask: #{Enum.join(Tuple.to_list(new_mask))}")
        {new_mask, memory_map}
      :mem ->
        {:mem, address, value} = cmd
        address_range = address
          |> apply_address_mask(mask)

        # IO.puts("Got addresses for #{address}: [#{Enum.join(Enum.sort(address_range), ", ")}]")
        updated_map = Enum.reduce(address_range, memory_map, &Map.put(&2, &1, value))
        {mask, updated_map}
    end
  end

  def solve(input) do
    commands = input
      |> String.split("\n") # I'm on Linux now!
      |> Enum.map(&parse_line/1)

    IO.puts("Input count: #{Enum.count(commands)}")

    init_acc = {%{or: 0, and: 0}, %{}}
    {_mask, memory} = Enum.reduce(commands, init_acc, &process_results/2)
    IO.puts("Result: #{Enum.sum(Map.values(memory))}")
  end
end

DockingData.solve(input)
