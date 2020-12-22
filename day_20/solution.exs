use Bitwise, only_operators: true

{:ok, input} = File.read("input")
{:ok, monster_input} = File.read("monster_input")

defmodule JurassicJigsaw do

  @img_size 12

  # =========================== Parsing ===========================

  def process_line(line_pair) do
    {line, i} = line_pair
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {ch, j} -> {{i, j}, ch == "#"} end)
  end

  def parse_tile(tile_str) do
    [title | lines] = String.split(tile_str, "\n")

    title_regex = ~r/Tile (\d+):/
    [id_str] = Regex.run(title_regex, title, capture: :all_but_first)
    id = String.to_integer(id_str)

    tile = lines
      |> Enum.with_index()
      |> Enum.map(&process_line/1)

    {id, tile}
  end

  def parse_monster(monster_input) do
    String.split(monster_input, "\n")
    |> Enum.with_index()
    |> Enum.map(&process_line/1)
    |> List.flatten()
    |> Enum.filter(fn {_, v} -> v end)
    |> Enum.map(fn {coord, _} -> coord end)
  end

  # =========================== Precompute signatures =============

  def build_signatures(tile_info) do
    {id, tile} = tile_info

    first_row = Enum.at(tile, 0)
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.map(fn {{_i, j}, _v} -> j end)
    top = calc_signature(first_row, false)

    last_row = Enum.at(tile, 9)
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.map(fn {{_i, j}, _v} -> j end)
    bottom = calc_signature(last_row, true)

    first_col = tile
      |> Enum.map(&Enum.at(&1, 0))
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.map(fn {{i, _j}, _v} -> i end)
    left = calc_signature(first_col, true)

    last_col = tile
      |> Enum.map(&Enum.at(&1, 9))
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.map(fn {{i, _j}, _v} -> i end)
    right = calc_signature(last_col, false)

    {id, [top, left, bottom, right]}
  end

  def calc_signature(int_set, reverse) do
    {sign, co_sign} = int_set
      |> Enum.map(fn x -> {x, 9 - x} end)
      |> Enum.map(fn {x, y} -> {1 <<< x, 1 <<< y} end)
      |> Enum.reduce(fn {x, y}, {acc_x, acc_y} -> {acc_x + x, acc_y + y} end)

    if reverse do
      {co_sign, sign}
    else
      {sign, co_sign}
    end
  end

  # =========================== Main recursion ====================

  def get_above_restrictions(reverse_signs, x, y, img, unused_ids) do
    if x == 0 do
      {unused_ids, fn _ -> true end}
    else
      above = Map.fetch!(img, {x-1, y})
      above_res = Map.fetch(reverse_signs, above.bottom)
      case above_res do
        :error ->
          :error
        {:ok, above_ids} ->
          {MapSet.intersection(unused_ids, above_ids), fn s -> s == above.bottom end}
      end
    end
  end

  def get_left_restrictions(reverse_signs, x, y, img, unused_ids) do
    if y == 0 do
      {unused_ids, fn _ -> true end}
    else
      left = Map.fetch!(img, {x, y-1})
      left_res = Map.fetch(reverse_signs, left.right)
      case left_res do
        :error ->
          :error
        {:ok, left_ids} ->
          {MapSet.intersection(unused_ids, left_ids), fn s -> s == left.right end}
      end
    end
  end

  def gen_apply_rotation(rotation) do
    {t, _l, _b, _r, flipped} = rotation
    fn {x, y} ->
      case t do
        0 -> if flipped, do: {x, 9 - y}, else: {x, y}
        1 -> if flipped, do: {y, x}, else: {y, 9 - x}
        2 -> if flipped, do: {9 - x, y}, else: {9 - x, 9 - y}
        3 -> if flipped, do: {9 - y, 9 - x}, else: {9 - y, x}
      end
    end
  end

  def find_tile_rotations(id, tile_signs, above_check, left_check) do
    tile_list = Map.fetch!(tile_signs, id)

    check_rotation = fn {t, l, _b, _r, flipped} ->
      {top_sign, top_cosign} = Enum.at(tile_list, t)
      {left_sign, left_cosign} = Enum.at(tile_list, l)
      if flipped do
        above_check.(top_cosign) and left_check.(left_cosign)
      else
        above_check.(top_sign) and left_check.(left_sign)
      end
    end

    rotations = 0..3
      |> Enum.map(fn i -> {i, rem((i + 1), 4), rem((i + 2), 4), rem((i + 3), 4), false} end)
    flipped_rotations = rotations
      |> Enum.map(fn {t, l, b, r, _f} -> {t, r, b, l, true} end)
    valid_rotations = Enum.filter(rotations ++ flipped_rotations, check_rotation)

    if Enum.empty?(valid_rotations) do
      :error
    else
      process_rotation = fn rotation ->
        {_t, _l, b, r, flipped} = rotation
        apply_fun = gen_apply_rotation(rotation)
        {bottom_sign, bottom_cosign} = Enum.at(tile_list, b)
        {right_sign, right_cosign} = Enum.at(tile_list, r)
        if flipped do
          %{id: id, bottom: bottom_sign, right: right_sign, fun: apply_fun}
        else
          %{id: id, bottom: bottom_cosign, right: right_cosign, fun: apply_fun}
        end
      end

      Enum.map(valid_rotations, process_rotation)
    end
  end

  def apply_candidate_restrictions(tile_info, x, y, img, unused_ids, above_res, left_res) do
    {tile_signs, _} = tile_info

    {above_ids, above_check} = above_res
    {left_ids, left_check} = left_res

    candidates = MapSet.intersection(above_ids, left_ids)
      |> Enum.map(&find_tile_rotations(&1, tile_signs, above_check, left_check))
      |> Enum.reject(fn x -> x == :error end)
      |> List.flatten()

    {x1, y1} = if y == @img_size - 1, do: {x + 1, 0}, else: {x, y + 1}

    build_recursively = fn candidate ->
      new_img = Map.put(img, {x, y}, candidate)
      new_unused = MapSet.delete(unused_ids, candidate.id)
      build_img(tile_info, x1, y1, new_img, new_unused)
    end

    results = candidates
      |> Enum.map(build_recursively)
      |> Enum.reject(fn x -> x == :error end)
      |> List.flatten()
    if Enum.empty?(results) do
      :error
    else
      results
    end
  end

  def build_img(tile_info, x, y, img, unused_ids) do
    {_, reverse_signs} = tile_info

    if x == @img_size do
      [img]
    else
      above_res = get_above_restrictions(reverse_signs, x, y, img, unused_ids)
      left_res = get_left_restrictions(reverse_signs, x, y, img, unused_ids)

      case {above_res, left_res} do
        {:error, _} -> :error
        {_, :error} -> :error
        _ -> apply_candidate_restrictions(tile_info, x, y, img, unused_ids, above_res, left_res)
      end
    end
  end

  # =========================== Vizualize ==========================

  def get_tile_pixels(tiles, img_pair) do
    {{x, y}, info_map} = img_pair
    tile = Map.fetch!(tiles, info_map.id)
    transform = info_map.fun

    tile
    |> List.flatten()
    |> Enum.map(fn {coord, val} -> {transform.(coord), val} end)
    |> Enum.reject(fn {{i, j}, _} -> i == 0 or j == 0 or i == 9 or j == 9 end)
    |> Enum.map(fn {{i, j}, v} -> {{i - 1 + 8 * x, j - 1 + 8 * y}, v} end)
  end

  def get_img_pixels(tiles, img) do
    img
      |> Enum.map(&get_tile_pixels(tiles, &1))
      |> List.flatten()
      |> Map.new()
  end

  def viz_img(pixel_map) do
    board_size = (@img_size * 8) - 1

    build_line = fn i ->
      0..board_size
      |> Enum.map(&Map.fetch!(pixel_map, {i, &1}))
      |> Enum.map(fn v -> if v, do: "#", else: "." end)
      |> Enum.join(" ")
    end

    text = 0..board_size
      |> Enum.map(build_line)
      |> Enum.join("\n")

    File.write!("output", text)
  end

  # =========================== Find monsters ==========================

  def apply_monster(pixel_map, monster, point) do
    {x, y} = point
    board_size = (@img_size * 8) - 1

    check_point = fn {x1, y1} ->
      cond do
        x1 >= board_size -> false
        y1 >= board_size -> false
        true -> Map.fetch!(pixel_map, {x1, y1})
      end
    end

    monster
    |> Enum.map(fn {i, j} -> {x + i, y + j} end)
    |> Enum.all?(check_point)
  end

  def find_monsters(pixel_map, monster) do
    board_size = (@img_size * 8) - 1

    all_points = 0..board_size
      |> Enum.map(fn i -> Enum.map(0..board_size, fn j -> {i, j} end) end)
      |> List.flatten()
      |> Enum.filter(&apply_monster(pixel_map, monster, &1))

    Enum.count(all_points)
  end

  # =========================== Main ==============================

  def get_border_count(tile, reverse_signs) do
    {id, sign_pairs} = tile

    nbr_count = fn {x, co_x} ->
      cnt = MapSet.union(Map.fetch!(reverse_signs, x), Map.fetch!(reverse_signs, co_x))
        |> Enum.count()
      cnt - 1
    end

    border_cnt = sign_pairs
    |> Enum.map(nbr_count)
    |> Enum.filter(fn x -> x == 0 end)
    |> Enum.count()

    {id, border_cnt}
  end

  def solve(input, monster_input) do
    tiles = input
      |> String.split("\n\n")
      |> Enum.map(&parse_tile/1)
      |> Map.new()

    monster = parse_monster(monster_input)

    IO.puts("Input counts: #{Enum.count(tiles)}")

    tile_signs = tiles
      |> Enum.map(&build_signatures/1)
      |> Map.new()

    reverse_signs = tile_signs
      |> Enum.map(fn {id, pairs} -> Enum.map(pairs, fn {s, co_s} -> [{s, id}, {co_s, id}] end) end)
      |> List.flatten()
      |> Enum.group_by(fn {s, _} -> s end, fn {_, id} -> id end)
      |> Enum.map(fn {k, v} -> {k, MapSet.new(v)} end)
      |> Map.new()

    # Part 1
    corner_sum = tile_signs
      |> Enum.map(&get_border_count(&1, reverse_signs))
      |> Enum.filter(fn {_, n} -> n == 2 end)
      |> Enum.map(fn {id, _} -> id end)
      |> Enum.reduce(&*/2)
    IO.puts("Corners #{corner_sum}")

    # Part 2

    all_ids = MapSet.new(Map.keys(tile_signs))
    pixel_maps = build_img({tile_signs, reverse_signs}, 0, 0, %{}, all_ids)
      |> Enum.map(&get_img_pixels(tiles, &1))

    IO.puts("Got #{Enum.count(pixel_maps)} solutions")

    {pixel_map, monster_count} = pixel_maps
      |> Enum.map(fn pm -> {pm, find_monsters(pm, monster)} end)
      |> Enum.find(fn {_pm, m} -> m > 0 end)

    viz_img(pixel_map)

    total_sharps = Enum.count(pixel_map, fn {_, v} -> v end)
    monster_sharps = Enum.count(monster)
    final_result = total_sharps - monster_count * monster_sharps
    IO.puts("Final result: #{final_result} = #{total_sharps} - #{monster_count} * #{monster_sharps}")
  end
end

JurassicJigsaw.solve(input, monster_input)
