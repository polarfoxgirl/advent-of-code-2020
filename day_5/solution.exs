{:ok, input} = File.read("input")

defmodule BinaryBoarding do
  def map_codes(ch) do
    case ch do
      "F" -> 0
      "B" -> 1
      "L" -> 0
      "R" -> 1
    end
  end

  def transform_pow2(bits) do
    last = List.last(bits)
    head = Enum.take(bits, Enum.count(bits) - 1)
    if Enum.any?(head) do
      BinaryBoarding.transform_pow2(head) * 2 + last
    else
      last
    end
  end

  def calc_tid(ticket) do
    bits = ticket
    |>String.graphemes()
    |> Enum.map(&BinaryBoarding.map_codes/1)

    row = BinaryBoarding.transform_pow2(Enum.take(bits, 7))
    seat = BinaryBoarding.transform_pow2(Enum.take(bits, -3))
    tid = row * 8 + seat
    # IO.puts "#{tid} (row #{row}, seat #{seat})"
    tid
  end

  def solve(input) do
    tids = input
    |> String.split()
    |> Enum.map(&BinaryBoarding.calc_tid/1)

    IO.puts "Input count: #{Enum.count(tids)}"
    # result = Enum.max(tids)
    # IO.puts "Result: #{result}"

    sorted_tids = Enum.sort(tids)
    comp_fn = fn i ->
      Enum.at(sorted_tids, i) != Enum.at(sorted_tids, i-1) + 1
    end
    result_i = Enum.find(1..Enum.count(tids), comp_fn)
    result =  Enum.at(sorted_tids, result_i) - 1
    IO.puts "Result: #{result} [#{Enum.at(sorted_tids, result_i - 1)}...#{Enum.at(sorted_tids, result_i)}]"
  end
end

BinaryBoarding.solve(input)
