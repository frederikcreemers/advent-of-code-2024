function loadFile()
    open("input.txt") do file
        return [split(line, "") for line in eachline(file)]
    end
end

# A grid of letters from the input file
grid = loadFile()

nrows = length(grid)
ncols = length(grid[1])

# While we iterate through the grid, blockId is the index of the block the current cell will be added to.
blockId = 0
# blockSizes holds the number of cells in each block, indexed by block Id
blockSizes = Vector{Int}()
# blockFences holds the number of fences around each block, indexed by block Id
blockFences = Vector{Int}()
# blockSides holds the number of sides of each block, indexed by block Id
blockSides = Vector{Int}()
# blockGrid holds the block Id of each cell in the grid
blockGrid = zeros(Int, nrows, ncols)

# It can happen that we start a new block going left to right, 
# and then find that the current cell also matches a cell above in an existing block.
# In that case, w merge the two blocks.
function mergeBlocks(aboveBlock, leftBlock)
    global blockSizes[aboveBlock] += blockSizes[leftBlock]
    global blockFences[aboveBlock] += blockFences[leftBlock]
    global blockSides[aboveBlock] += blockSides[leftBlock]
    blockSizes[leftBlock] = 0
    blockFences[leftBlock] = 0
    blockSides[leftBlock] = 0
    for row in range(1, nrows)
        for col in range(1, ncols)
            if blockGrid[row, col] == leftBlock
                blockGrid[row, col] = aboveBlock
            end
        end
    end
end

# Iterate through the grid
for row in range(1, nrows)
    for col in range(1, ncols)
        nFences = 0
        nSides = 0
        sameAsAbove = row == 1 ? false : grid[row][col] == grid[row - 1][col]
        sameAsLeft = col == 1 ? false : grid[row][col] == grid[row][col - 1]
        sameAsBelow = row == nrows ? false : grid[row][col] == grid[row + 1][col]
        sameAsRight = col == ncols ? false : grid[row][col] == grid[row][col + 1]

        # For each of the sides, check if there should be a fence,
        # by checking if it's either on the edge, or it differs from its neighbor on that side.
        if !sameAsAbove || row == 1
            nFences += 1
            # We check if this fence introduces a new edge.
            # For horizontal fences, this is true if it's the first column, or if its left neighbor didn't have a corresponding fence.
            if col == 1 || !sameAsLeft || (row > 1 && grid[row - 1][col - 1] == grid[row][col])
                nSides += 1
            end
        end
        if !sameAsLeft || col == 1
            # Similarly, for vetical fences, it introduces a new side
            # if it's on the first row, or if its above neighbor doesn't have a corresponding fence.
            if row == 1 || ! sameAsAbove || (col > 1 && grid[row - 1][col - 1] == grid[row][col])
                nSides += 1
            end
            nFences += 1
        end
        if !sameAsBelow || row == nrows
            if col == 1 || !sameAsLeft || (row < nrows && grid[row + 1][col - 1] == grid[row][col])
                nSides += 1
            end
            nFences += 1
        end
        if !sameAsRight || col == ncols
            if row == 1 || !sameAsAbove || (col < ncols && grid[row - 1][col + 1] == grid[row][col])
                nSides += 1
            end
            nFences += 1
        end 

        # Check which block this cell should be added to.
        block = if sameAsAbove
            blockGrid[row - 1, col]
        elseif sameAsLeft
            blockGrid[row, col - 1]
        else
            # It doesn't match any of the neighbors we've already iterated on (left and top), so start a new block
            global blockId += 1
            append!(blockSizes, 0)
            append!(blockFences, 0)
            append!(blockSides, 0)
            blockId
        end
        blockGrid[row, col] = block
        blockSizes[block] += 1
        blockFences[block] += nFences
        blockSides[block] += nSides
        # Oops, it looks like the current block fits in the block to the left, and the block above,
        # but they're different blocks, so we merge them.
        if sameAsAbove && sameAsLeft && blockGrid[row - 1, col] != blockGrid[row, col - 1]
            leftBlock = blockGrid[row, col - 1]
            aboveBlock = blockGrid[row - 1, col]
            mergeBlocks(aboveBlock, leftBlock)
        end
    end
end

total1 = 0
total2 = 0
for i in range(1, blockId)
    if blockSizes[i] == 0
        continue
    end
    price1 = blockSizes[i] * blockFences[i]
    price2 = blockSizes[i] * blockSides[i]
    println("Block ", i, " size: ", blockSizes[i], " fences: ", blockFences[i], " price: ", price2)
    global total1 += price1
    global total2 += price2
end

println("Part 1: ", total1)
println("Part 2: ", total2)