{:ok, input} = File.read("test_input_2")

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
  def check_recursively(period, iter_bus_offset, other_bus_offsets) do
    {bid, offset} = iter_bus_offset
    t = period * bid - offset

    if Enum.all?(other_bus_offsets, fn {b, o} -> rem(t + o, b) == 0 end) do
      t
    else
      check_recursively(period + 1, iter_bus_offset, other_bus_offsets)
    end
  end

  # 17, x, 13, 19
  # {17, 0}, {13, 2}, {19, 3}
  # 0*M0-1 + 646*M1-1 + 663*M2-1 = 3417
  #
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
    [iter_bus_offset | other_bus_offsets] = buses
      |> Enum.with_index()
      |> Enum.reject(fn {x, _} -> x == "x" end)
      |> Enum.map(fn {x, y} -> {String.to_integer(x), y} end)
      |> Enum.sort_by(fn {b, _o} -> b end, &>=/2)

    other_bus_offsets = Enum.reverse(other_bus_offsets)
    other_bus_ids = Enum.map(other_bus_offsets, fn {x, _} -> x end)
    # others_gcd = Enum.reduce(other_bus_ids, &Integer.gcd/2)
    # others_lcm = div(Enum.reduce(other_bus_ids, &*/2), others_gcd)
    # IO.puts("Got GCD #{others_gcd} and LCM #{others_lcm}")

    # cheat_init_period = div(100000000000000, elem(iter_bus_offset, 0))
    result = check_recursively(0, iter_bus_offset, other_bus_offsets)

    IO.puts("Result 2: #{result}")
  end
end

ShuttleSearch.solve(input)
