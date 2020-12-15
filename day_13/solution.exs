{:ok, input} = File.read("input")

defmodule ShuttleSearch do
  def calc_next_timestamp(bid, timestamp) do
    reminder = rem(timestamp,bid)
    if reminder == 0 do
      {bid, 0}
    else
      {bid, bid - reminder}
    end
  end

  # t = b*p + o
  # t + o1 = b1*k1
  # t + o2 = b2*k2
  #
  # b*p + (o + o1) = b1*k1
  # p = (b1*k1 + o + o1) / b
  def check_recursively(t, period, curr_bus, bus_tail) do
    {bid, offset} = curr_bus

    if rem(t + offset, bid) == 0 do
      if Enum.empty?(bus_tail) do
        t
      else
        [next_bus | new_tail] = bus_tail
        new_period = period * bid
        check_recursively(t + new_period, new_period, next_bus, new_tail)
      end
    else
      check_recursively(t + period, period, curr_bus, bus_tail)
    end
  end

  def solve(input) do
    [first_line, second_line] = String.split(input)
    timestamp = String.to_integer(first_line)
    buses = String.split(second_line, ",")

    IO.puts("Input count: #{Enum.count(buses)}")

    # Part 1
    {bid, wait_time} = buses
      |> Enum.reject(fn n -> n == "x" end)
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(&calc_next_timestamp(&1, timestamp))
      |> Enum.min_by(fn {_, t} -> t end)

    IO.puts("Result: #{bid*wait_time}")

    # Part 2
    [init_bus | other_buses] = buses
      |> Enum.with_index()
      |> Enum.reject(fn {x, _} -> x == "x" end)
      |> Enum.map(fn {x, y} -> {String.to_integer(x), y} end)
      |> Enum.sort_by(fn {b, _o} -> b end, &>=/2)

    result = check_recursively(0, 1, init_bus, other_buses)

    IO.puts("Result 2: #{result}")
  end
end

ShuttleSearch.solve(input)
