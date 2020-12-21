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

  def build_ast(lex, stack) do
    {current, new_stack} = List.pop_at(stack, -1)
    cond do
      # Case 1: Left hand side
      not Map.has_key?(current, :left) ->
        case lex do
          "(" -> stack ++ [%{}]
          n when is_integer(n) -> new_stack ++ [%{left: n}]
          _ ->
            IO.puts("Got unexpected '#{lex}' on the left side")
            :error
        end
      # Case 2: Operation or leaf node
      not Map.has_key?(current, :op) ->
        case lex do
          ")" ->
            {prev, new_new_stack} = List.pop_at(new_stack, -1)
            cond do
              # Braces were on right hand side
              Map.has_key?(prev, :op) ->
                # IO.puts("Poped a frame and calc #{prev.left} with #{current.left}")
                res = Map.put(prev, right: current.left)
                new_new_stack ++ [%{left: res}]
              # Braces were on left hand side
              Enum.empty?(prev) ->
                # IO.puts("Poped a frame and put left as #{current.left}")
                new_new_stack ++ [%{left: current.left}]
              true ->
                # IO.puts("Got a frame with just left after popping")
                :error
            end
          "+" -> new_stack ++ [%{left: current.left, op: "+"}]
          "*" -> new_stack ++ [%{left: current.left, op: "*"}]
          _ ->
            IO.puts("Got unexpected '#{lex}' on the operator position")
            :error
        end
      # Case 3: Right hand side
      true ->
        case lex do
          "(" -> stack ++ [%{}]
          n when is_integer(n) ->
            # IO.puts("Reduced current frame with  #{current.left} and #{n}")
            res = Map.put(current, right: n)
            new_stack ++ [%{left: res}]
          true ->
            IO.puts("Got unexpected '#{lex}' on the right side")
            :error
        end
    end
  end

  def reduce_tree(node, op, op_fun) do
    left = reduce_tree(node.left, op, op_fun)
    unless Map.has_key?(:op) do
      left
    else
      right = reduce_tree(node.right, op, op_fun)
      if node.op = op do
        op_fun(
      end
    end
  end

  def eval_line(line) do
    final_stack = line
      |> lex_line()
      |> Enum.reduce([%{}], &eval_expr/2)
    [root_node] = final_stack
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
