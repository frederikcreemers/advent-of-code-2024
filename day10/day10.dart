import "dart:io";

(List<List<int>>, List<(int, int)>, List<(int, int)>) loadInput() {
  var input = File("input.txt");
  var nines = <(int, int)>[];
  var zeros = <(int, int)>[];
  var map = input.readAsLinesSync().asMap().entries.map((entry) {
    var line = entry.key;
    return entry.value.split("").asMap().entries.map((charEntry) {
      var val = int.parse(charEntry.value);
      var col = charEntry.key;
      if (val == 9) {
        nines.add((line, col));
      }
      if (val == 0) {
        zeros.add((line, col));
      }
      return val;
    }).toList();
  }).toList();

  return (map, zeros, nines);
}

List<List<int>> calculateScores(List<List<int>> map, List<(int, int)> nines) {
  var scores = List.generate(
      map.length, (index) => List.generate(map[index].length, (index) => 0));
  for (var nine in nines) {
    var toInspect = [nine];
    var seen = List.generate(map.length,
        (index) => List.generate(map[index].length, (index) => false));
    while (toInspect.isNotEmpty) {
      var (currentRow, currentCol) = toInspect.removeAt(0);
      if (seen[currentRow][currentCol]) {
        continue;
      }
      seen[currentRow][currentCol] = true;
      scores[currentRow][currentCol] += 1;
      var currentAltitude = map[currentRow][currentCol];
      if (currentAltitude == 0) {
        continue;
      }
      var nextOptions = [
        (currentRow - 1, currentCol),
        (currentRow + 1, currentCol),
        (currentRow, currentCol - 1),
        (currentRow, currentCol + 1)
      ];

      nextOptions.forEach((option) {
        var (row, col) = option;
        if (row >= 0 &&
            row < map.length &&
            col >= 0 &&
            col < map[row].length &&
            map[row][col] == currentAltitude - 1) {
          toInspect.add((row, col));
        }
      });
    }
  }
  return scores;
}

int part1(List<List<int>> map, List<(int, int)> zeros, List<(int, int)> nines) {
  var scores = calculateScores(map, nines);
  for (var row in scores) {
    print(row.join(" "));
  }
  return zeros.map((zero) => scores[zero.$1][zero.$2]).reduce((a, b) => a + b);
}

List<List<int>> calculateRatingsPart2(
    List<List<int>> map, List<(int, int)> nines) {
  var scores = List.generate(
      map.length, (index) => List.generate(map[index].length, (index) => 0));
  for (var nine in nines) {
    var toInspect = [nine];
    while (toInspect.isNotEmpty) {
      var (currentRow, currentCol) = toInspect.removeAt(0);
      scores[currentRow][currentCol] += 1;
      var currentAltitude = map[currentRow][currentCol];
      if (currentAltitude == 0) {
        continue;
      }
      var nextOptions = [
        (currentRow - 1, currentCol),
        (currentRow + 1, currentCol),
        (currentRow, currentCol - 1),
        (currentRow, currentCol + 1)
      ];

      nextOptions.forEach((option) {
        var (row, col) = option;
        if (row >= 0 &&
            row < map.length &&
            col >= 0 &&
            col < map[row].length &&
            map[row][col] == currentAltitude - 1) {
          toInspect.add((row, col));
        }
      });
    }
  }
  return scores;
}

int part2(List<List<int>> map, List<(int, int)> zeros, List<(int, int)> nines) {
  var scores = calculateRatingsPart2(map, nines);
  for (var row in scores) {
    print(row.join(" "));
  }
  return zeros.map((zero) => scores[zero.$1][zero.$2]).reduce((a, b) => a + b);
}

void main() {
  var (map, zeros, nines) = loadInput();
  print("part 1: ${part1(map, zeros, nines)}");
  print("part 2: ${part2(map, zeros, nines)}");
}
