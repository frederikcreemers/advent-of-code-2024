import Foundation

let fileURL = URL(fileURLWithPath: "input.txt")
let input = try! String(contentsOf: fileURL, encoding: .utf8)
let lines = input.split(separator: "\n")
let nlines = lines.count

let targets = ["XMAS", "SAMX"]
func part1() {
    var count = 0
    let grid = lines.map({
        count += $0.occurences(of: "XMAS")
        count += $0.occurences(of: "SAMX")
        return Array($0)
    })

    for (y, row) in grid.enumerated() {
        if y > nlines - 4 {
            continue
        }
        for (x, c) in row.enumerated() {
            if c != "X" && c != "S" {
                continue
            }
            var vertres = ""
            var diagResRight = ""
            var diagResLeft = ""
            for i in 0..<4 {
                vertres += String(grid[y+i][x])
                if x <= row.count - 4 {
                    diagResRight += String(grid[y+i][x+i])
                }
                if x >= 3 {
                    diagResLeft += String(grid[y+i][x-i])
                }
            }
            if targets.contains(vertres) {
                count += 1
            }
            if targets.contains(diagResRight) {
                count += 1
            }
            if targets.contains(diagResLeft) {
                count += 1
            }
        }
    }

    print("Part 1: \(count)")
}

func part2() {
    let grid = lines.map({ Array($0)})
    var count = 0
    for x in 1..<grid[0].count - 1 {
        for y in 1..<grid.count - 1 {
            if grid[x][y] != "A" {
                continue
            }
            let d1 = (grid[x-1][y-1] == "M" && grid[x+1][y+1] == "S") ||
                            (grid[x-1][y-1] == "S" && grid[x+1][y+1] == "M")
            let d2 = (grid[x+1][y-1] == "M" && grid[x-1][y+1] == "S") ||
                            (grid[x+1][y-1] == "S" && grid[x-1][y+1] == "M")
            if d1 && d2 {
                count += 1
            }
        }
    }
    print("Part 2: \(count)")
}

extension String.SubSequence {
    func occurences(of needle: String) -> Int {
        return self.split(separator: needle, omittingEmptySubsequences: false).count - 1
    }
}

part1()
part2()