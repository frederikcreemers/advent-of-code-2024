import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(contents) = simplifile.read("input.txt")
  let assert [raw_rules, raw_prints] = string.split(contents, "\n\n")
  let rules = parse_rules(raw_rules)
  let prints = parse_prints(raw_prints)

  io.println("Part 1")
  io.debug(part1(rules, prints))
  io.println("Part 2")
  io.debug(part2(rules, prints))
}

fn parse_rules(raw_rules: String) -> List(#(Int, Int)) {
  raw_rules
  |> string.split("\n")
  |> list.map(fn(rule) -> #(Int, Int) {
    let assert [a, b] = string.split(rule, "|")
    let assert Ok(int_a) = int.parse(a)
    let assert Ok(int_b) = int.parse(b)
    #(int_a, int_b)
  })
}

fn parse_prints(raw_prints: String) -> List(List(Int)) {
  raw_prints
  |> string.split("\n")
  |> list.map(fn(print) -> List(Int) {
    list.map(string.split(print, ","), fn(x) {
      let assert Ok(int_x) = int.parse(x)
      int_x
    })
  })
}

fn matches_rule(print: List(Int), rule: #(Int, Int)) -> Bool {
  let #(x, y) = rule
  case list.contains(print, x) {
    True -> {
      case print {
        [first, ..] if first == x -> True
        [first, ..] if first == y -> False
        [_first, ..rest] -> matches_rule(rest, rule)

        [] -> True
      }
    }
    False -> True
  }
}

fn middle_page(print: List(Int)) -> Int {
  let len = list.length(print)
  let mid = len / 2
  let assert Ok(midpage) = print |> list.drop(mid) |> list.first()
  midpage
}

fn fix_print(print: List(Int), rules: List(#(Int, Int))) -> List(Int) {
  let maybe_fixed =
    list.fold(rules, print, fn(print, rule) {
      case matches_rule(print, rule) {
        True -> print
        False -> print_fix_rule(print, rule)
      }
    })

  case list.all(rules, fn(rule) -> Bool { matches_rule(maybe_fixed, rule) }) {
    True -> maybe_fixed
    False -> fix_print(maybe_fixed, rules)
  }
}

fn print_fix_rule(print: List(Int), rule: #(Int, Int)) -> List(Int) {
  let #(x, y) = rule
  case print {
    [first, ..rest] if first == x -> [y, ..print_fix_rule(rest, rule)]
    [first, ..rest] if first == y -> [x, ..print_fix_rule(rest, rule)]
    [first, ..rest] -> [first, ..print_fix_rule(rest, rule)]
    [] -> []
  }
}

fn part1(rules: List(#(Int, Int)), prints: List(List(Int))) -> Int {
  prints
  |> list.filter(fn(print) -> Bool {
    list.all(rules, fn(rule) -> Bool { matches_rule(print, rule) })
  })
  |> list.map(fn(print) { middle_page(print) })
  |> int.sum()
}

fn part2(rules: List(#(Int, Int)), prints: List(List(Int))) -> Int {
  prints
  |> list.filter(fn(print) -> Bool {
    list.any(rules, fn(rule) -> Bool { !matches_rule(print, rule) })
  })
  |> list.map(fn(print) { fix_print(print, rules) })
  |> list.map(fn(print) { middle_page(print) })
  |> int.sum()
}
