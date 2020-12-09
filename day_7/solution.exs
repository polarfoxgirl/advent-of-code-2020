{:ok, input} = File.read("test_input")

defmodule HandyHaversacks do
  def parse_subrule(subrule) do
    subrule_regex = ~r/\d+ ([\w\s]+) bags?/
    captures = Regex.run(subrule_regex, subrule, capture: :all_but_first)
    List.first(captures)
  end

  def parse_rule(rule) do
    rule_regex = ~r/([\w\s]+) bags contain (no other bags|(\d+ [\w\s]+ bags?,? ?)+)\./
    captures = Regex.run(rule_regex, rule, capture: :all_but_first)
    rule_color = Enum.at(captures, 0)
    if Enum.count(captures) == 2 do
      # IO.puts("Rule for #{rule_color}: no bags (#{Enum.count(captures)})")
      # %{color: rule_color, children: []}
      %{}
    else
      subrules = Enum.at(captures, 1)
        |> String.split(", ")
        |> Enum.map(&HandyHaversacks.parse_subrule/1)

      # do a reverse tree on rules

      # IO.puts("Rule for #{rule_color}: #{subrules} (#{Enum.count(subrules)})")
      # %{color: rule_color, children: subrules}
    end
  end

  def process_rule(rule_struct, result_set) do
    if Enum.any?(rule_struct[:children], &MapSet.member?(result_set, &1)) do
      MapSet.put(result_set, rule_struct[:color])
    else
      result_set
    end
  end

  def solve(input) do
    rules = input
      |> String.split("\r\n")
      |> Enum.map(&HandyHaversacks.parse_rule/1)
      |> Enum.reduce(%{}, &Map.put_new(&2, &1[:color], &1[:children]))

    IO.puts "Input count: #{Enum.count(rules)}"
    # init_set = MapSet.new(["shiny gold"])
    # results = Enum.reduce(rules, init_set, &HandyHaversacks.process_rule/2)
    # IO.puts "Result: #{Enum.count(results) - 1}"
    # IO.puts "Result: #{results}"
  end
end

HandyHaversacks.solve(input)
