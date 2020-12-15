use Bitwise, only_operators: true

{:ok, input} = File.read("input")

defmodule DockingData do
  def parse_line(line) do
    mask_regex = ~r/mask = ([X01]+)/
    mem_regex = ~r/mem\[(\d+)\] = (\d+)/

    if String.starts_with?(line, "mask") do
      [mask_str] = Regex.run(mask_regex, line, capture: :all_but_first)
      mask_raw = mask_str
        |> String.graphemes()
        |> Enum.reverse()
        |> Enum.with_index()

      or_mask = mask_raw
        |> Enum.filter(fn {ch, _i} -> ch == "1" end)
        |> Enum.map(fn {_ch, i} -> 1 <<< i end)
        |> Enum.sum()

      and_mask = mask_raw
        |> Enum.filter(fn {ch, _i} -> ch != "0" end)
        |> Enum.map(fn {_ch, i} -> 1 <<< i end)
        |> Enum.sum()

      {:mask, %{or: or_mask, and: and_mask}}
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

  def process_results(cmd, acc) do
    {mask_pair, memory_map} = acc

    case elem(cmd, 0) do
      :mask ->
        {:mask, new_mask_pair} = cmd
        # IO.puts("Got masks: #{get_bin_str(new_mask_pair[:or])} and #{get_bin_str(new_mask_pair[:and])}")
        {new_mask_pair, memory_map}
      :mem ->
        {:mem, address, value} = cmd
        inter_value = value ||| mask_pair[:or]
        new_value = inter_value &&& mask_pair[:and]
        # IO.puts("Mem[#{address}]: #{value} -> #{new_value}")
        {mask_pair, Map.put(memory_map, address, new_value)}
    end
  end

  def solve(input) do
    commands = input
      |> String.split("\n") # I'm on Linux now!
      |> Enum.map(&parse_line/1)

    IO.puts("Input count: #{Enum.count(commands)}")

    init_acc = {%{or: 0, and: 0}, %{}}
    {_mask_pair, memory} = Enum.reduce(commands, init_acc, &process_results/2)
    IO.puts("Result: #{Enum.sum(Map.values(memory))}")
  end
end

DockingData.solve(input)
