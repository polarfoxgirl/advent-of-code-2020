{:ok, input} = File.read("input")

defmodule ComboBreaker do

  @mod_prime 20201227
  @subject_num 7

  defp force_loop_size(pub_key) do
    force_loop_size(pub_key, 1, @subject_num)
  end

  defp force_loop_size(pub_key, n, subject) do
    case rem(subject * @subject_num, @mod_prime) do
      ^pub_key -> n
      other -> force_loop_size(pub_key, n + 1, other)
    end
  end

  defp encrypt(subject, loop_size) do
    1..loop_size
    |> Enum.reduce(subject, fn _, acc -> rem(acc * subject, @mod_prime) end)
  end

  def solve(input) do
    [card_pub, door_pub] = input
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    IO.puts("Input: #{card_pub}, #{door_pub}")

    card_loop = force_loop_size(card_pub)
    door_loop = force_loop_size(door_pub)

    IO.puts("Loop sizes: #{card_loop}, #{door_loop}")

    card_key = encrypt(door_pub, card_loop)
    door_key = encrypt(card_pub, door_loop)

    IO.puts("Encryption key: #{card_key}, #{door_key}")
  end
end

ComboBreaker.solve(input)
