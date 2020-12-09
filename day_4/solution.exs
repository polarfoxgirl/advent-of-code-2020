{:ok, input} = File.read("input")

defmodule PassportProcessing do
  @required_fields [:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]

  @eye_colors MapSet.new(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])

  def convert_matches(matches) do
    [field, value] = matches
    %{String.to_atom(field) => value}
  end

  def preprocess_row(row) do
    pair_regex = ~r/(\w+):([^\s]+)/
    Regex.scan(pair_regex, row, capture: :all_but_first)
    |> Enum.map(&PassportProcessing.convert_matches/1)
    |> Enum.reduce(&Map.merge/2)
  end

  def validate_fields(passport) do
    Enum.all?(@required_fields, &(Map.has_key?(passport, &1)))
  end

  def validate_year(str, min, max) do
    unless Regex.match?(~r/^\d{4}$/, str) do
      false
    else
      value = String.to_integer(str)
      cond do
        !value -> false
        (value < min) or (value > max) -> false
        true -> true
      end
    end
  end

  def validate_hgt(str) do
    cond do
      Regex.match?(~r/^\d{3}cm$/, str) ->
        value = String.to_integer(String.slice(str, 0..2))
        (value >= 150) and (value <= 193)
      Regex.match?(~r/^\d{2}in$/, str) ->
        value = String.to_integer(String.slice(str, 0..1))
        (value >= 59) and (value <= 76)
      true -> false
    end
  end

  def advanced_validate_fields(passport) do
    result = Enum.all?(@required_fields, &(Map.has_key?(passport, &1)))
      and PassportProcessing.validate_year(passport[:byr], 1920, 2002)
      and PassportProcessing.validate_year(passport[:iyr], 2010, 2020)
      and PassportProcessing.validate_year(passport[:eyr], 2020, 2030)
      and PassportProcessing.validate_hgt(passport[:hgt])
      and Regex.match?(~r/^#[0-9a-f]{6}$/, passport[:hcl])
      and MapSet.member?(@eye_colors, passport[:ecl])
      and Regex.match?(~r/^\d{9}$/, passport[:pid])
    # IO.puts(result)
    result
  end

  def solve(input) do
    passports = input
    |> String.split("\r\n\r\n")
    |> Enum.map(&PassportProcessing.preprocess_row/1)

    IO.puts "Passport count: #{Enum.count(passports)}"
    result = passports |> Enum.count(&PassportProcessing.advanced_validate_fields/1)
    IO.puts "Valid count: #{result}"
  end
end

PassportProcessing.solve(input)
