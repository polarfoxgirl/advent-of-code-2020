{:ok, input} = File.read("input")

defmodule  RambunctiousRecitation do
  def speak_num(turn, prev_num, age_map) do
    prev_turn = Map.get(age_map, prev_num)
    if prev_turn do
      (turn - 1) - prev_turn
    else
      0
    end
  end

  def do_turn(turn, prev_num, age_map) do
    spoken_num = speak_num(turn, prev_num, age_map)
    # IO.puts("Turn #{turn}: #{spoken_num}")
    if turn == 30000000 do
      spoken_num
    else
      do_turn(turn + 1, spoken_num, Map.put(age_map, prev_num, turn - 1))
    end
  end

  def solve(input) do
    init_numbers = input
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    IO.puts("Input count: #{Enum.count(init_numbers)}")

    {last_init_num, init_head} = List.pop_at(init_numbers, -1)
    init_map = init_head
      |> Enum.with_index(1)
      |> Map.new()

    result = do_turn(Enum.count(init_numbers) + 1, last_init_num, init_map)
    IO.puts("Result: #{result}")
  end
end

 RambunctiousRecitation.solve(input)
