{:ok, input} = File.read("input")
regex = ~r/(\d+)\-(\d+) ([a-z]): ([a-z]+)/
entries = Regex.scan(regex, input, capture: :all_but_first)

defmodule PasswordPhilosophy do
  def check_entry(entry) do
    [min_cnt, max_cnt, letter, password] = entry
    max_cnt = String.to_integer(max_cnt)
    min_cnt = String.to_integer(min_cnt)
    cnt = password |> String.graphemes() |> Enum.count(fn c -> c == letter end)
    (cnt >= min_cnt) and (cnt <= max_cnt)
  end

  def check_entry_v2(entry) do
    [p1, p2, letter, password] = entry
    letter1 = String.at(password, String.to_integer(p1) - 1)
    letter2 = String.at(password, String.to_integer(p2) - 1)
    if letter1 && letter2 do
      result = ((letter1 == letter) or (letter2 == letter)) and (letter1 != letter2)
      # IO.puts "#{p1} (#{letter1}) #{p2} (#{letter2}) #{letter} #{password}: #{result}"
      result
    else
      # IO.puts "#{p1} (#{letter1}) #{p2} (#{letter2}) #{letter} #{password}: false"
      false
    end
  end

  def count_valid_passwords(entries) do
    # entries = Enum.take(entries, 10)
    Enum.count(entries, &check_entry_v2/1)
  end
end

IO.puts "Entries count: #{Enum.count(entries)}"
IO.puts "Last entry: #{List.last(entries)}"
IO.puts "Result: #{PasswordPhilosophy.count_valid_passwords(entries)}"
