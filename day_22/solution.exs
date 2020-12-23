{:ok, input} = File.read("input")

defmodule CrabCombat do
  def parse_deck(player_input) do
    [_player | card_strs] = String.split(player_input, "\n")
    Enum.map(card_strs, &String.to_integer/1)
  end

  def play_combat(deck_1, deck_2) do
    if Enum.empty?(deck_1) or Enum.empty?(deck_2) do
      {deck_1, deck_2}
    else
      [card_1 | tail_1] = deck_1
      [card_2 | tail_2] = deck_2
      cond do
        card_1 > card_2 -> play_combat(tail_1 ++ [card_1, card_2], tail_2)
        card_1 < card_2 -> play_combat(tail_1, tail_2 ++ [card_2, card_1])
      end
    end
  end

  def calc_state_sign(deck_1, deck_2) do
    deck_1_str = Enum.join(deck_1, ",")
    deck_2_str = Enum.join(deck_2, ",")
    :crypto.hash(:md5, "{[#{deck_1_str}], [#{deck_2_str}}]")
  end

  def play_recursive_combat_memo(deck_1, deck_2, memo_map) do
    state = calc_state_sign(deck_1, deck_2)
    memo_res = Map.fetch(memo_map, state)
    case memo_res do
      {:ok, result} ->
        {result, memo_map}
      :error ->
        {result, updated_memo_map} = play_recursive_combat(deck_1, deck_2, MapSet.new(), memo_map)
        {result, Map.put(updated_memo_map, state, result)}
    end
  end

  def play_recursive_combat(deck_1, deck_2, prev_states, memo_map) do
    state = calc_state_sign(deck_1, deck_2)

    cond do
      Enum.empty?(deck_1) or Enum.empty?(deck_2) ->
        {{deck_1, deck_2}, memo_map}
      MapSet.member?(prev_states, state) ->
        {{deck_1, []}, memo_map}
      true ->
        states = MapSet.put(prev_states, state)

        [card_1 | tail_1] = deck_1
        [card_2 | tail_2] = deck_2

        if card_1 <= Enum.count(tail_1) and card_2 <= Enum.count(tail_2) do
          # Missing this requirement gave me so much grief!
          sub_deck_1 = Enum.take(tail_1, card_1)
          sub_deck_2 = Enum.take(tail_2, card_2)
          {{result_1, result_2}, updated_memo_map} = play_recursive_combat_memo(sub_deck_1, sub_deck_2, memo_map)
          cond do
            Enum.empty?(result_2) -> play_recursive_combat(tail_1 ++ [card_1, card_2], tail_2, states, updated_memo_map)
            Enum.empty?(result_1) -> play_recursive_combat(tail_1, tail_2 ++ [card_2, card_1], states, updated_memo_map)
          end
        else
          cond do
            card_1 > card_2 -> play_recursive_combat(tail_1 ++ [card_1, card_2], tail_2, states, memo_map)
            card_1 < card_2 -> play_recursive_combat(tail_1, tail_2 ++ [card_2, card_1], states, memo_map)
          end
        end
    end
  end

  def calc_score(deck) do
    deck
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {card, i} -> card * i end)
    |> Enum.sum()
  end

  def solve(input) do
    [player_1_input, player_2_input] = String.split(input, "\n\n")
    deck_1 = parse_deck(player_1_input)
    deck_2 = parse_deck(player_2_input)

    IO.puts("Got #{Enum.count(deck_1)} cards for player 1, #{Enum.count(deck_2)} cards for player 2")

    # Part 1

    {result_deck_1, result_deck_2} = play_combat(deck_1, deck_2)
    if Enum.empty?(result_deck_2) do
      score = calc_score(result_deck_1)
      IO.puts("Player 1 won with #{score}")
    else
      score = calc_score(result_deck_2)
      IO.puts("Player 2 won with #{score}")
    end

    # Part 2

    {{result_deck_1, result_deck_2}, memo_map} = play_recursive_combat(deck_1, deck_2, MapSet.new(), %{})
    IO.puts("Memoized #{Enum.count(memo_map)} games")
    if Enum.empty?(result_deck_2) do
      score = calc_score(result_deck_1)
      IO.puts("Player 1 won with #{score}")
    else
      score = calc_score(result_deck_2)
      IO.puts("Player 2 won with #{score}")
    end
  end
end

CrabCombat.solve(input)
