package main

import java.io.File
import java.io.InputStream
import java.util.*
import kotlin.math.max
import kotlin.math.min

typealias Maze<CellType> = Array<Array<CellType>>

data class Point(val row: Int, val col: Int) {
    operator fun plus(other: Point) = Point(this.row + other.row, this.col + other.col)
    fun isIn(maze: Maze<Boolean>): Boolean {
        return row > 0 && col > 0 && row < maze.size && col < maze[0].size && !maze[row][col]
    }
}

enum class Direction {
    NORTH {
        override fun getPoint() = Point(row = -1, col = 0)
        override fun getOpposite() = SOUTH
    },

    SOUTH {
        override fun getPoint() = Point(row = 1, col = 0)
        override fun getOpposite(): Direction = NORTH
    },

    WEST {
        override fun getPoint() = Point(row = 0, col = -1)
        override fun getOpposite() = EAST
    },

    EAST {
        override fun getPoint() = Point(row = 0, col = 1)
        override fun getOpposite() = WEST
    };

    abstract fun getPoint(): Point
    abstract fun getOpposite(): Direction
}

data class MazeState(val position: Point, val facing: Direction)

fun part1(maze: Maze<Boolean>, start: Point, end: Point): Int {
    val costs = Array(maze.size) { Array(maze[0].size) { Int.MAX_VALUE } }
    val (startRow, startCol) = start
    costs[startRow][startCol] = 0

    val toExplore = PriorityQueue<MazeState>(compareBy { costs[it.position.row][it.position.col] })
    toExplore.add(MazeState(start, Direction.EAST))

    val exploredMaze = Maze(maze.size) { Array(maze[0].size) { false } }

    while (!toExplore.isEmpty()) {
        val currentState = toExplore.poll()
        val (currentPoint, facing) = currentState
        println("exploring $currentPoint")
        val (row, col) = currentPoint
        exploredMaze[row][col] = true
        val currentCost = costs[row][col]

        if (currentPoint == end) {
            return costs[row][col]
        }

        if (row > 0 && !maze[row - 1][col]) {
            val moveCost = currentCost + if (facing == Direction.NORTH)  1 else 1001

            costs[row - 1][col] = min(moveCost, costs[row - 1][col])
            if (!exploredMaze[row-1][col]) {
                println("Adding ${Point(row - 1, col)}")
                toExplore.add(MazeState(Point(row - 1, col), Direction.NORTH))
            }
        }

        if ((row < maze.size - 1) && !maze[row + 1][col]) {
            val moveCost = currentCost + if (facing == Direction.SOUTH)  1 else 1001

            costs[row + 1][col] = min(moveCost, costs[row + 1][col])
            if (!exploredMaze[row+1][col]) {
                println("Adding ${Point(row + 1, col)}")
                toExplore.add(MazeState(Point(row + 1, col), Direction.SOUTH))
            }
        }

        if (col > 0 && !maze[row][col - 1]) {
            val moveCost = currentCost + if (facing == Direction.WEST)  1 else 1001

            costs[row][col - 1] = min(moveCost, costs[row][col - 1])
            if (!exploredMaze[row][col - 1]) {
                println("Adding ${Point(row, col - 1)}")
                toExplore.add(MazeState(Point(row, col - 1), Direction.WEST))
            }
        }

        if (col < maze[0].size - 1 && !maze[row][col + 1]) {
            val moveCost = currentCost + if (facing == Direction.EAST)  1 else 1001

            costs[row][col + 1] = min(moveCost, costs[row][col + 1])
            if (!exploredMaze[row][col+1]) {
                println("Adding ${Point(row, col+1)}")
                toExplore.add(MazeState(Point(row, col + 1), Direction.EAST))
            }
        }
    }

    throw Error("This shouldn't happen")
}

// I realized that for part 2, I actually need to keep track of the cost to get to each position in each direction separately.
// So, I copied part 1 and updated it, so that you can still see the original code for part 1.


fun part2(maze: Maze<Boolean>, start: Point, end: Point): Int {
    // Start out the same as in part 1, get the minimum cost from the start to each cell.
    val costs = Array(maze.size) { Array(maze[0].size) { Int.MAX_VALUE } }
    val (startRow, startCol) = start
    costs[startRow][startCol] = 0

    val toExplore = PriorityQueue<MazeState>(compareBy { costs[it.position.row][it.position.col] })
    toExplore.add(MazeState(start, Direction.EAST))

    var exploredMaze = Array(maze.size) { Array(maze[0].size) { false } }

    while (!toExplore.isEmpty()) {
        val currentState = toExplore.poll()
        val (currentPoint, facing) = currentState
        println("exploring $currentPoint $facing")
        val (row, col) = currentPoint
        exploredMaze[row][col] = true
        val currentCost = costs[row][col]
        println("Current cost = $currentCost")

        Direction.entries.forEach { dir ->
            val moveCost = currentCost + if (facing == dir)  1 else 1001
            val newPoint = currentPoint + dir.getPoint()


            if (dir !== facing.getOpposite() && newPoint.isIn(maze) && !exploredMaze[newPoint.row][newPoint.col]) {
                if (moveCost < costs[newPoint.row][newPoint.col]) {
                    costs[newPoint.row][newPoint.col] = moveCost
                }

                println("Adding $newPoint")
                toExplore.add(MazeState(newPoint, dir))
            }
        }
    }

    // Now, search backwards from the goal, only taking paths that are are either 1 or 1001 steps below the current cost.
    // These steps must by definition be part of an optimal path.

    // We can start from the goal going west or south.
    //toExplore.add(MazeState(end, Direction.WEST))
    toExplore.add(MazeState(end, Direction.SOUTH))

    exploredMaze = Array(maze.size) { Array(maze[0].size) { false } }

    var n = 1
    while (!toExplore.isEmpty()) {
        val (position, facing) = toExplore.poll()
        val (row, col) = position
        val currentCost = costs[row][col]

        println("Reverse exploring $position $facing at $currentCost")

        Direction.entries.forEach { dir ->
            val newPoint = position + dir.getPoint()
            println("Considering $newPoint $dir")
            if (newPoint.isIn(maze) &&
                arrayOf(1, 1001, if (dir === facing) -999 else Int.MIN_VALUE).contains(currentCost - costs[newPoint.row][newPoint.col]) &&
                !exploredMaze[newPoint.row][newPoint.col]) {
                println("counting $newPoint")
                n += 1
                exploredMaze[newPoint.row][newPoint.col] = true
                toExplore.add(MazeState(newPoint, dir))
            } else {
                val reason = when {
                    !newPoint.isIn(maze) -> "Point not in the maze"
                    // The cell is either a normal stepp (step  or step + turn) away, or it's 1 fewer step but 1 more turn away.
                    !arrayOf(1, 1001, -999).contains(currentCost - costs[newPoint.row][newPoint.col]) -> "Cost: difference is off. ${currentCost - costs[newPoint.row][newPoint.col]}"
                    exploredMaze[newPoint.row][newPoint.col] -> "Already explored"
                    else -> "huh, wtf?"
                }
                println("Rejected: $reason")
            }
        }
    }

    // code used for debugging
    exploredMaze.forEach { row ->
        var line = ""
        row.forEach { cell ->
            line += if (cell) "O" else "#"
        }
        println(line)
    }
    return n
}

fun readMaze(): Triple<Maze<Boolean>, Point, Point> {
    val inputStream: InputStream = File("input.txt").inputStream()
    val lineList = mutableListOf<String>()
    inputStream.bufferedReader().forEachLine { lineList.add(it) } 

    var maze = Maze(lineList.size) { Array(lineList[0].length) { false } }
    var start: Point = Point(0, 0)
    var end: Point = Point(0, 0)

    lineList.forEachIndexed { i, line ->
        line.forEachIndexed { j, c ->
            if (c == '#') {
                maze[i][j] = true
            }
            if (c == 'S') {
                start = Point(i, j)
            }
            if (c == 'E') {
                end = Point(i, j)
            }
        }
    }

    return Triple(maze, start, end)
}


fun main() {
    val (maze, start, end) = readMaze()
    //println("Part 1: ${part1(maze, start, end)}")
    println("Part 2: ${part2(maze, start, end)}")

}