{:ok, input} = File.read("input")

defmodule OperationOrder do
  def lex_line(line) do
    chars = String.graphemes(line)

    process_char = fn ch, acc ->
      {curr, prev} = acc
      int_val_res = Integer.parse(ch)
      cond do
        ch == " " -> acc
        int_val_res != :error ->
          {int_val, _} = int_val_res
          {curr ++ [int_val], prev}
        true ->
          if Enum.empty?(curr) do
            {[], prev ++ [ch]}
          else
            {[], prev ++ [Integer.undigits(curr), ch]}
          end
      end
    end

    {last, lexemes} = Enum.reduce(chars, {[], []}, process_char)
    if Enum.empty?(last) do
      lexemes
    else
      lexemes ++ [Integer.undigits(last)]
    end
  end

  def eval_expression(lexemes, pos, acc) do
    {add_acc, mult_list} = acc

    if pos == tuple_size(lexemes) do
      result = Enum.reduce([add_acc | mult_list], &*/2)
      {result, pos}
    else
      case elem(lexemes, pos) do
        "+" -> eval_expression(lexemes, pos + 1, acc)
        "*" ->
          new_acc = {0, [add_acc | mult_list]}
          eval_expression(lexemes, pos + 1, new_acc)
        n when is_integer(n) ->
          new_acc = {add_acc + n, mult_list}
          eval_expression(lexemes, pos + 1, new_acc)
        "(" ->
          {sub_res, new_pos} = eval_expression(lexemes, pos + 1, {0, []})
          new_acc = {add_acc + sub_res, mult_list}
          eval_expression(lexemes, new_pos, new_acc)
        ")" ->
          result = Enum.reduce([add_acc | mult_list], &*/2)
          {result, pos + 1}
      end
    end
  end

  def eval_line(line) do
    {result, _} = line
      |> lex_line()
      |> List.to_tuple()
      |> eval_expression(0, {0, []})
    result
  end


  def solve(input) do
    lines = String.split(input, "\n")

    IO.puts("Input counts: #{Enum.count(lines)}")

    result = lines
      |> Enum.map(&eval_line/1)
      |> Enum.sum()

    IO.puts("Result: #{result}")
  end
end

OperationOrder.solve(input)
