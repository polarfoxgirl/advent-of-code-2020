{:ok, input} = File.read("input")

defmodule HandyHaversacks do
  def parse_subrule(subrule) do
    subrule_regex = ~r/(\d+) ([\w\s]+) bags?/
    captures = Regex.run(subrule_regex, subrule, capture: :all_but_first)
    %{List.last(captures) => String.to_integer(List.first(captures))}
  end

  def parse_rule(rule) do
    rule_regex = ~r/([\w\s]+) bags contain (no other bags|(\d+ [\w\s]+ bags?,? ?)+)\./
    captures = Regex.run(rule_regex, rule, capture: :all_but_first)
    rule_color = Enum.at(captures, 0)
    if Enum.count(captures) == 2 do
      # IO.puts("Rule for #{rule_color}: no bags (#{Enum.count(captures)})")
      %{color: rule_color, children: %{}}
    else
      subrules = Enum.at(captures, 1)
        |> String.split(", ")
        |> Enum.reduce(%{}, &Map.merge(&2, HandyHaversacks.parse_subrule(&1)))

      # IO.puts("Rule for #{rule_color}: #{subrules} (#{Enum.count(subrules)})")
      %{color: rule_color, children: subrules}
    end
  end

  def populate_reverse_rule(outer_color, rule_map, reverse_map) do
    update_set = fn (map, key) ->
      MapSet.put(Map.fetch!(map, key), outer_color)
    end

    Map.fetch!(rule_map, outer_color)
    |> Map.keys()
    |> Enum.reduce(reverse_map, &Map.replace!(&2, &1, update_set.(&2, &1)))
  end

  def dfs_reverse_rules(reverse_rules, layer, seen_colors) do
    next_layer = layer
      |> Enum.reduce(MapSet.new(), &MapSet.union(&2, Map.fetch!(reverse_rules, &1)))
      |> MapSet.difference(seen_colors)

    if Enum.any?(next_layer) do
      HandyHaversacks.dfs_reverse_rules(reverse_rules, next_layer, MapSet.union(seen_colors, next_layer))
    else
      seen_colors
    end
  end

  def dfs_measures(rule_map, known_measures) do
    calc_measure = fn children ->
      m = children
        |> Enum.map(fn {k, v} -> v * Map.fetch!(known_measures, k) end)
        |> Enum.sum()
      m + 1
    end

    new_measures = rule_map
      |> Enum.reject(fn {k, _v} -> Map.has_key?(known_measures, k) end)
      |> Enum.filter(fn {_k, v} -> Enum.all?(Map.keys(v), &Map.has_key?(known_measures, &1)) end)
      |> Enum.map(fn {k, v} -> {k, calc_measure.(v)} end)
      |> Map.new()

    # IO.puts("DFS step from #{Enum.count(known_measures)} by #{Enum.count(new_measures)}")
    if Enum.any?(new_measures) do
      dfs_measures(rule_map, Map.merge(known_measures, new_measures))
    else
      known_measures
    end
  end

  def solve(input) do
    rule_map = input
      |> String.split("\r\n")
      |> Enum.map(&HandyHaversacks.parse_rule/1)
      |> Enum.reduce(Map.new(), &Map.put_new(&2, &1[:color], &1[:children]))

    # Part 1
    init_reverse_rules = rule_map
      |> Map.keys()
      |> Enum.reduce(%{}, &Map.put_new(&2, &1, MapSet.new()))
    reverse_rules = rule_map
      |> Map.keys()
      |> Enum.reduce(init_reverse_rules, &HandyHaversacks.populate_reverse_rule(&1, rule_map, &2))

    IO.puts "Input count: #{Enum.count(reverse_rules)}"

    root_layer = MapSet.new(["shiny gold"])
    results = HandyHaversacks.dfs_reverse_rules(reverse_rules, root_layer, root_layer)
    IO.puts "Result: #{Enum.count(results) - 1}"

    # Part 2
    init_measures = rule_map
      |> Enum.reject(fn {_k, v} -> Enum.any?(v) end)
      |> Enum.map(fn {k, _v} -> {k, 1} end)
      |> Map.new()
    measures= dfs_measures(rule_map, init_measures)
    if Enum.count(measures) < Enum.count(rule_map) do
      IO.puts("Unable to calc all measures")
    else
      IO.puts("Inner bag count: #{Map.fetch!(measures, "shiny gold") - 1}")
    end
  end
end

HandyHaversacks.solve(input)
