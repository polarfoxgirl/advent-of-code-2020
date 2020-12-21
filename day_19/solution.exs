{:ok, input} = File.read("input")

defmodule MonsterMessages do
  def parse_rule(line) do
    num_regex = ~r/(\d+)\: (.*)/
    [n, rule] = Regex.run(num_regex, line, capture: :all_but_first)
    n = String.to_integer(n)
    rule = String.trim(rule)

    split_and_int = fn s ->
      String.split(s)
      |> Enum.map(&String.to_integer/1)
    end

    rule_regex = ~r/"(\w)"|([\d ]+)(\|([\d ]+))?/
    captures = Regex.run(rule_regex, rule, capture: :all_but_first)
    if Enum.count(captures) == 1 do
      [base_part] = captures
      {n, {:base, base_part}}
    else
      ["" | tail] = captures
      case tail do
        [main_part] -> {n, {:single, split_and_int.(main_part)}}
        [main_part, _, or_part] ->
          {n, {:double, split_and_int.(main_part), split_and_int.(or_part)}}
      end
    end
  end

  def match_subrule(message, pos_list, rules, subrule_num) do
    new_pos_list = pos_list
      |> Enum.map(&match_rule(message, &1, rules, subrule_num))
      |> Enum.reject(fn x -> elem(x, 0) == :no_match end)
      |> Enum.map(fn {:ok, p_list} -> p_list end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.reject(fn x -> x > tuple_size(message) end)

    if Enum.empty?(new_pos_list) do
      {:halt, []}
    else
      {:cont, new_pos_list}
    end
  end

  def match_base_rule(message, pos, rule) do
    {:base, ch} = rule
    if pos < tuple_size(message) and elem(message, pos) == ch do
      {:ok, [pos + 1]}
    else
      {:no_match}
    end
  end

  def match_single_rule(message, pos, rules, rule) do
    {:single, subrules} = rule

    new_pos_list = Enum.reduce_while(subrules, [pos], &match_subrule(message, &2, rules, &1))
    if Enum.empty?(new_pos_list) do
      {:no_match}
    else
      {:ok, new_pos_list}
    end
  end

  def match_double_rule(message, pos, rules, rule) do
    {:double, subrules_1, subrules_2} = rule

    new_pos_list_1 = Enum.reduce_while(subrules_1, [pos], &match_subrule(message, &2, rules, &1))
    new_pos_list_2 = Enum.reduce_while(subrules_2, [pos], &match_subrule(message, &2, rules, &1))
    new_pos_list = (new_pos_list_1 ++ new_pos_list_2)
      |> Enum.uniq()

    if Enum.empty?(new_pos_list) do
      {:no_match}
    else
      {:ok, new_pos_list}
    end
  end

  def match_rule(message, pos, rules, rule_num) do
    rule = Map.fetch!(rules, rule_num)
    case elem(rule, 0) do
      :base -> match_base_rule(message, pos, rule)
      :single -> match_single_rule(message, pos, rules, rule)
      :double -> match_double_rule(message, pos, rules, rule)
    end
  end

  def check_message(message, rules) do
    msg_tup = message
      |> String.graphemes()
      |> List.to_tuple()

    result = match_rule(msg_tup, 0, rules, 0)
    case result do
      {:no_match} -> false
      {:ok, positions} -> Enum.member?(positions, tuple_size(msg_tup))
    end
  end

  def solve(input) do
    [rules_input, messages_input] = String.split(input, "\n\n")
    rules = rules_input
      |> String.split("\n")
      |> Enum.map(&parse_rule/1)
      |> Map.new()

    messages = String.split(messages_input)

    IO.puts("Input counts: #{Enum.count(rules)} rules, #{Enum.count(messages)} messages")

    # result = check_message(Enum.at(messages, 2), rules)
    # IO.puts("Result: #{result}")

    results = messages
      |> Enum.filter(&check_message(&1, rules))
      |> Enum.count()
      # |> Enum.join(", ")
    IO.puts("Result: #{results}")
  end
end

MonsterMessages.solve(input)
