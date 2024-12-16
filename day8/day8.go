package main

import (
	"fmt"
	"os"
	"slices"
	"strings"
)

func main() {
	bcontents, _ := os.ReadFile("input.txt")
	contents := string(bcontents)
	lines := strings.Split(contents, "\n")

	antennae := make(map[rune][][2]int)
	for row, line := range lines {
		for col, char := range line {
			if char != '.' {
				if antennae[char] == nil {
					antennae[char] = make([][2]int, 0)
				}
				antennae[char] = append(antennae[char], [2]int{row, col})
			}
		}
	}

	nrows := len(lines)
	ncols := len(lines[0])
	part1res := part1(antennae, nrows, ncols)
	fmt.Println("Part 1:", part1res)
	part2res := part2(antennae, nrows, ncols)
	fmt.Println("Part 2:", part2res)
}

func part1(antennae map[rune][][2]int, nrows, ncols int) int {
	res := [][2]int{}
	for _, positions := range antennae {
		for _, pair := range makePairs(positions) {
			rowdist := pair[0][0] - pair[1][0]
			coldist := pair[0][1] - pair[1][1]
			a1row := pair[0][0] + rowdist
			a1col := pair[0][1] + coldist
			a2row := pair[1][0] - rowdist
			a2col := pair[1][1] - coldist
			if 0 <= a1row && a1row < nrows && 0 <= a1col && a1col < ncols {
				if !slices.Contains(res, [2]int{a1row, a1col}) {
					res = append(res, [2]int{a1row, a1col})
				}
			} else {
				//fmt.Println(string(char), "No antinode at", a1row, a1col, " is out of bounds")
			}
			if 0 <= a2row && a2row < nrows && 0 <= a2col && a2col < ncols {
				if !slices.Contains(res, [2]int{a2row, a2col}) {
					res = append(res, [2]int{a2row, a2col})
				}
			} else {
				//fmt.Println(string(char), "No antinode at", a2row, a2col, " is out of bounds")
			}
		}
	}
	return len(res)
}

func part2(antennae map[rune][][2]int, nrows, ncols int) int {
	res := [][2]int{}
	for _, positions := range antennae {
		for _, pair := range makePairs(positions) {
			linePoints := getLinePoints(pair[0], pair[1], nrows, ncols)
			for _, point := range linePoints {
				if !slices.Contains(res, point) {
					res = append(res, point)
				}
			}
		}
	}
	return len(res)
}

func makePairs(positions [][2]int) [][2][2]int {
	res := make([][2][2]int, 0)
	for i := 0; i < len(positions); i++ {
		for j := i + 1; j < len(positions); j++ {
			res = append(res, [2][2]int{positions[i], positions[j]})
		}
	}
	return res
}

func getLinePoints(p1, p2 [2]int, nrows, ncols int) [][2]int {
	rowdist := p1[0] - p2[0]
	coldist := p1[1] - p2[1]

	res := [][2]int{p1}
	i := 1
	for true {
		an1row := p1[0] + i*rowdist
		an1col := p1[1] + i*coldist
		an2row := p1[0] - i*rowdist
		an2col := p1[1] - i*coldist
		a1InBounds := 0 <= an1row && an1row < nrows && 0 <= an1col && an1col < ncols
		a2InBounds := 0 <= an2row && an2row < nrows && 0 <= an2col && an2col < ncols
		if a1InBounds {
			res = append(res, [2]int{an1row, an1col})
		}

		if a2InBounds {
			res = append(res, [2]int{an2row, an2col})
		}

		if !a1InBounds && !a2InBounds {
			break
		}
		i += 1
	}
	return res
}
