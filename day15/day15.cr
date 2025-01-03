alias Grid = Array(Array(Char))

VERBOSE = true

struct WarehouseProblem
  @grid : Grid?
  @bot_pos : Tuple(Int32, Int32)?
  @moves : String?

  def initialize(contents : String, part : Int32)
    gridstr, movesstr = contents.split("\n\n")
    @moves = movesstr.split('\n').join
    @grid = self.parse_grid(gridstr, part)

    @grid.as(Grid).each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if cell == '@'
          @bot_pos = {x, y}
        end
      end
    end
  end

  def parse_grid(gridstr : String, part : Int32) : Array(Array(Char))
    parsed : Array(Array(Char)) = gridstr.split("\n").map { |line| line.chars }

    if part == 2
      return parsed.map do |row|
        newRow = Array(Char).new(row.size * 2, '.')
        row.each_with_index do |cell, i|
          case cell
          when '@'
            newRow[i * 2] = '@'
            newRow[i * 2 + 1] = '.'
          when 'O'
            newRow[i * 2] = '['
            newRow[i * 2 + 1] = ']'
          else
            newRow[i * 2] = cell
            newRow[i * 2 + 1] = cell
          end
        end
        newRow
      end
    end
    return parsed
  end

  def apply_moves
    @moves.as(String).each_char do |move|
      if self.grid_at(@bot_pos.as(Tuple(Int32, Int32))) != '@'
        raise "Bot is not at the right position, in move #{move}"
      end
      self.try_move(move, @bot_pos.as(Tuple(Int32, Int32)))

      self.verbose_debug "after #{move}"
      if VERBOSE
        self.debug_grid
      end
    end
  end

  def get_destination(move : Char, pos : {Int32, Int32}) : {Int32, Int32}
    x, y = pos
    case move
    when 'v'
      return {x, y + 1}
    when '^'
      return {x, y - 1}
    when '>'
      return {x + 1, y}
    when '<'
      return {x - 1, y}
    end
    raise "Invalid move"
  end

  def grid_at(pos : {Int32, Int32}) : Char
    x, y = pos
    return @grid.as(Grid)[y][x]
  end

  def set_grid_at(pos : {Int32, Int32}, value : Char)
    x, y = pos
    @grid.as(Grid)[y][x] = value
  end

  def can_move(move : Char, pos : {Int32, Int32}) : Bool
    dest = self.get_destination(move, pos)
    self.verbose_debug "can_move #{move}, #{self.grid_at(pos)} from #{pos} to #{dest}"
    if dest[0] < 0 || dest[1] < 0 || dest[0] >= @grid.as(Grid)[0].size || dest[1] >= @grid.as(Grid).size
      self.verbose_debug "out of bounds"
      return false
    end
    if self.grid_at(pos) == '#'
      self.verbose_debug "can't move wall"
      return false
    end
    if self.grid_at(pos) == '.'
      self.verbose_debug "Moving empty does nothing, but succeeds"
      return true
    end
    if self.grid_at(dest) == '#'
      self.verbose_debug "can't move into a wall"
      return false
    end
    if self.grid_at(pos) == '[' && (move == 'v' || move == '^')
      return self.can_move_wide_box(move, pos)
    end
    if self.grid_at(pos) == ']' && (move == 'v' || move == '^')
      return self.can_move_wide_box(move, {pos[0] - 1, pos[1]})
    end
    if self.grid_at(dest) == '[' && (move == 'v' || move == '^')
      return self.can_move_wide_box(move, dest)
    end
    if self.grid_at(dest) == ']' && (move == 'v' || move == '^')
      return self.can_move_wide_box(move, {dest[0] - 1, dest[1]})
    end
    if self.grid_at(dest) == '.'
      self.verbose_debug "can move to empty, not moving wide box vertically."
      return true
    end
    self.verbose_debug "Check if we can move destination"
    return self.can_move(move, dest)
  end

  def can_move_wide_box(move : Char, pos : {Int32, Int32}) : Bool
    self.verbose_debug "can_move_wide_box #{move} from #{pos}"
    x, y = pos
    direction = if move == 'v'
                  1
                else
                  -1
                end
    return self.can_move(move, {x, y + direction}) && self.can_move(move, {x + 1, y + direction})
  end

  def try_move(move, pos : {Int32, Int32})
    if self.can_move(move, pos)
      self.do_move(move, pos)
    end
  end

  def do_move(move : Char, pos : {Int32, Int32})
    dest = self.get_destination(move, pos)
    if !"@[]".includes?(self.grid_at(pos))
      self.debug_grid
      raise "Moving something unexpected: #{self.grid_at(pos)}, #{pos}, #{move}, #{@bot_pos}"
    end
    if self.grid_at(dest) != '.'
      self.do_move(move, dest)
    end
    current = self.grid_at(pos)
    if current == '@'
      @bot_pos = dest
    end
    if "[]".includes?(current) && (move == 'v' || move == '^')
      other_side, other_symbol = if current == '['
                                   { {pos[0] + 1, pos[1]}, ']' }
                                 else
                                   { {pos[0] - 1, pos[1]}, '[' }
                                 end
      other_dest = self.get_destination(move, other_side)
      if self.grid_at(other_dest) != '.'
        self.do_move(move, other_dest)
      end
      self.set_grid_at(other_side, '.')
      self.set_grid_at(other_dest, other_symbol)
    end
    self.set_grid_at(pos, '.')
    self.set_grid_at(dest, current)
  end

  def debug_grid(grid : Grid = @grid)
    grid.as(Grid).each do |row|
      puts row.join
    end
  end

  def verbose_debug(msg : String)
    if VERBOSE
      puts msg
    end
  end

  def gps_sum
    sum = 0
    n = 0
    @grid.as(Grid).each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if cell == 'O' || cell == '['
          sum += y * 100 + x
          n += 1
        end
      end
    end
    puts "#{n} boxes"
    return sum
  end
end

file = File.new("input.txt", "r")
content = file.gets_to_end
file.close
# problem = WarehouseProblem.new(content, 1)
# problem.apply_moves
# puts problem.gps_sum

problem = WarehouseProblem.new(content, 2)
problem.apply_moves
puts "Part 2: #{problem.gps_sum}"
puts "Final situation"
problem.debug_grid
