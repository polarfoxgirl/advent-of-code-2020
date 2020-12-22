{:ok, input} = File.read("input")

defmodule AllergenAssessment do
  def parse_line(line) do
    regex = ~r/(.*) \(contains ([^\)]+)\)/
    [ingredient_str, allergen_str] = Regex.run(regex, line, capture: :all_but_first)
    ingredients = String.split(ingredient_str) |> MapSet.new()
    allergens = String.split(allergen_str, ", ")
    {ingredients, allergens}
  end

  def update_suspect_map(product, suspect_map) do
    {ingredients, allergens} = product

    process_allergen = fn allergen, acc_map ->
      if Map.has_key?(acc_map, allergen) do
        current_set = Map.fetch!(acc_map, allergen)
        updated_set = MapSet.intersection(current_set, ingredients)
        Map.replace!(acc_map, allergen, updated_set)
      else
        Map.put_new(acc_map, allergen, ingredients)
      end
    end

    Enum.reduce(allergens, suspect_map, process_allergen)
  end

  def try_reduce_map(suspect_map, known_allergens) do
    new_known_allergens = suspect_map
      |> Enum.filter(fn {_a, ingrs} -> Enum.count(ingrs) == 1 end)
      |> Enum.map(fn {a, ingrs} -> {a, Enum.at(ingrs, 0)} end)
      |> Map.new()

    if Enum.empty?(new_known_allergens) do
      {suspect_map, known_allergens}
    else
      new_ided_ingredients = MapSet.new(Map.values(new_known_allergens))
      updated_suspect_map = suspect_map
        |> Enum.reject(fn {a, _} -> Map.has_key?(new_known_allergens, a) end)
        |> Enum.map(fn {a, ingrs} -> {a, MapSet.difference(ingrs, new_ided_ingredients)} end)
        |> Map.new()

      updated_known_allergens = Map.merge(known_allergens, new_known_allergens)
      try_reduce_map(updated_suspect_map, updated_known_allergens)
    end
  end

  def solve(input) do
    products = input
      |> String.split("\n")
      |> Enum.map(&parse_line/1)

    IO.puts("Input count: #{Enum.count(products)}")

    # First find indgredients that are present in all products
    # where the allegen is listed.
    suspect_map = Enum.reduce(products, %{}, &update_suspect_map/2)

    # Then we reduce suspect map as much as possible
    {reduced_suspect_map, known_allergens} = try_reduce_map(suspect_map, %{})

    IO.puts("Reduced to #{Enum.count(reduced_suspect_map)} unknown and #{Enum.count(known_allergens)} known allergens")

    all_ingredients = products
      |> Enum.map(fn {ingrs, _a} -> ingrs end)
      |> Enum.reduce(&MapSet.union/2)

    known_allergen_ingredients = Map.values(known_allergens) |> MapSet.new()
    known_non_allergens = MapSet.difference(all_ingredients, known_allergen_ingredients)

    IO.puts("Found #{Enum.count(known_non_allergens)} non-allergen ingredients")

    result = products
      |> Enum.map(fn {ingrs, _a} -> Enum.count(ingrs, &MapSet.member?(known_non_allergens, &1)) end)
      |> Enum.sum()

    IO.puts("Result: #{result}")

    result_2 = known_allergens
      |> Enum.sort_by(fn {a, _i} -> a end)
      |> Enum.map(fn {_a, i} -> i end)
      |> Enum.join(",")

    IO.puts("Result 2: #{result_2}")
  end
end

AllergenAssessment.solve(input)
