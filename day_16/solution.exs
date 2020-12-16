{:ok, input} = File.read("input")

defmodule  TicketTranslation do
  def parse_rule(line) do
    rule_regex = ~r/([\s\w]+)\: (\d+)\-(\d+) or (\d+)\-(\d+)/
    [name | values] = Regex.run(rule_regex, line, capture: :all_but_first)
    [n1, n2, n3, n4] = Enum.map(values, &String.to_integer/1)
    {name, MapSet.new(Enum.concat(n1..n2, n3..n4))}
  end

  def process_ticket(ticket, rule_matches, rules) do
    Enum.map(rule_matches, fn {rule_name, col_set} ->
      valid_values = Map.fetch!(rules, rule_name)

      new_col_set = ticket
        |> Enum.with_index()
        |> Enum.filter(fn {_v, i} -> MapSet.member?(col_set, i) end)
        |> Enum.filter(fn {v, _i} -> MapSet.member?(valid_values, v) end)
        |> Enum.map(fn {_v, i} -> i end)
        |> MapSet.new()

      {rule_name, new_col_set}
    end)
  end

  def simplify_matches(rule_matches, resolved_cols, resolved_rules) do
    find_result = rule_matches
      |> Enum.find(fn {_r, s} -> Enum.count(s) == 1 and MapSet.disjoint?(resolved_cols, s) end)
    if find_result do
      {rule, set} = find_result
      [column] = MapSet.to_list(set)

      new_rule_matches = rule_matches
        |> Enum.reject(fn {r, _s} -> r == rule end)
        |> Enum.map(fn {r, s} -> {r, MapSet.delete(s, column)} end)

      new_resolved_cols = MapSet.put(resolved_cols, column)
      new_resolved_rules = Map.put(resolved_rules, rule, column)
      simplify_matches(new_rule_matches, new_resolved_cols, new_resolved_rules)
    else
      {rule_matches, resolved_rules}
    end
  end

  def solve(input) do
    [rule_input, ticket_input, others_input] = String.split(input, "\n\n")

    rules = rule_input
      |> String.split("\n")
      |> Enum.map(&parse_rule/1)
      |> Map.new()

    [_, ticket_input] = String.split(ticket_input, "\n")
    my_ticket = ticket_input
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    [_ | others_input] = String.split(others_input, "\n")
    other_tickets = others_input
      |> Enum.map(fn x -> Enum.map(String.split(x, ","), &String.to_integer/1) end)

    IO.puts("Input counts: #{Enum.count(rules)}, #{Enum.count(my_ticket)} and #{Enum.count(other_tickets)}")

    # Part 1
    valid_set = rules
      |> Map.values()
      |> Enum.reduce(&MapSet.union/2)

    all_values = List.flatten(other_tickets)
    result = all_values
      |> Enum.reject(&MapSet.member?(valid_set, &1))
      |> Enum.sum()

    IO.puts("Result: #{result}")

    # Part 2
    valid_tickets = other_tickets
      |> Enum.reject(fn x -> not Enum.all?(x, &MapSet.member?(valid_set, &1)) end)

    init_rule_matches = rules
      |> Enum.map(fn {x, _} -> {x, MapSet.new(0..(Enum.count(rules) - 1))} end)

    rules_matches = valid_tickets
      |> Enum.reduce(init_rule_matches, &process_ticket(&1, &2, rules))

    {unresolved_matches, resolved_rules} = simplify_matches(rules_matches, MapSet.new(), %{})
    # if Enum.any?(unresolved_matches, fn {r, _s} -> String.starts_with?(r, "departure") end) do
    if Enum.any?(unresolved_matches) do
      IO.puts("Unable to resolve matches :(")
      IO.puts(unresolved_matches)
    else
      final_result = resolved_rules
        |> Enum.filter(fn {r, _c} -> String.starts_with?(r, "departure") end)
        |> Enum.map(fn {_r, c} -> Enum.at(my_ticket, c) end)
        |> Enum.reduce(&*/2)
      IO.puts("Result 2: #{final_result}")
    end
  end
end

 TicketTranslation.solve(input)
