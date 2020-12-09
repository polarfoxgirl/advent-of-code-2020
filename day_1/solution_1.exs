{:ok, input} = File.read("input")
entries = String.split(input) |> Enum.map(&String.to_integer/1)

defmodule ReportRepair do
  def find_match(entries) do
    negatives = for x <- entries, into: MapSet.new(), do: 2020 - x
    res = Enum.find(entries, fn x -> Enum.member?(negatives, x) end)
    res*(2020 - res)
  end

  def find_custom_match(entries, base) do
    negatives = for x <- entries, x != base, into: MapSet.new(), do: 2020 - base - x
    case Enum.find(entries, :no_such_element, fn x -> Enum.member?(negatives, x) end) do
      :no_such_element -> :no_such_element
      res -> {:ok, res*(2020 - base - res)*base}
    end
  end

  def find_triple_match(entries) do
    {:ok, result} = entries
      |> Enum.map(fn x -> find_custom_match(entries, x) end)
      |> Enum.find(fn x -> x != :no_such_element end)
    result
  end
end


IO.puts "Result: #{ReportRepair.find_triple_match(entries)}"
