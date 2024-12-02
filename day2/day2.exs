defmodule Day2 do
  def readInput do
    input = File.read!("input.txt")
    lines = String.split(input, "\n")

    Enum.map(lines, fn line ->
      String.split(line, " ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def part1 do
    reports = readInput()
    IO.puts("#{length(Enum.filter(reports, &is_safe/1))}")
  end

  def part2 do
    reports = readInput()
    IO.puts("#{length(Enum.filter(reports, &is_safe_dampened/1))}")
  end

  def is_safe(report) do
    direction =
      if Enum.at(report, 0) < Enum.at(report, 1) do
        :up
      else
        :down
      end

    acc = {true, Enum.at(report, 0)}

    {safe, _} =
      Enum.reduce(Enum.drop(report, 1), acc, fn x, {safe, prev} ->
        case {safe, direction} do
          {false, _} -> {false, x}
          {true, :up} -> {x > prev and x - prev <= 3, x}
          {true, :down} -> {x < prev and prev - x <= 3, x}
        end
      end)

    safe
  end

  def is_safe_dampened(report) do
    # I'm aware I could do this more efficiently by looking at 3 elements at once in a report,
    # and if the step between the 2 outer ones isn't to big, dampen it.
    # But the input size isn't too big, and this is easier.
    Enum.any?(0..length(report), fn remove_idx ->
      is_safe(List.delete_at(report, remove_idx))
    end)
  end
end

Day2.part1()
Day2.part2()
