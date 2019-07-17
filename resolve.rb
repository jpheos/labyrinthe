# frozen_string_literal: true

require 'curses'

class Cell
  attr_reader :x, :y

  WALL     = 1
  START    = 2
  EXIT     = 3
  EMPTY    = 4
  TESTING  = 5
  DEAD     = 6
  SUCCESS  = 7

  def initialize(x, y, letter)
    @x = x
    @y = y
    @type = case letter
            when '#' then WALL
            when '.' then EMPTY
            when 'S' then START
            when 'E' then EXIT
            end
  end

  def win_print(win)
    letter = case @type
             when WALL then '#'
             when EXIT then 'E'
             when START then 'S'
             else
               '•'
             end
    win.setpos(@y, @x)
    win.color_set(@type)
    win.addstr(letter)
    win.refresh
    # win.color_set(WALL)
  end

  def start?
    @type == START
  end

  def test!
    @type = TESTING if @type == EMPTY
  end

  def testable?
    [EXIT, EMPTY].include? @type
  end

  def dead!
    @type = DEAD
  end

  def success!
    @type = SUCCESS unless [START, EXIT].include? @type
  end

  def sortie?
    @type == EXIT
  end
end

class Labyrinthe

  attr_reader :width
  attr_reader :height
  attr_writer :win

  def initialize(file_path)
    @file_path = file_path
    parse
  end

  def debug?(cell)
    cell.x == 2 && cell.y == 3
  end

  def print_all
    @height.times do |j|
      @width.times do |i|
        cell = @cells.find { |c| c.x == i && c.y == j }
        cell.win_print(@win)
      end
      @win.addstr("\n")
    end
  end

  def parse
    @cells = []
    file = File.open(@file_path, "r")
    data = file.read.split("\n")
    @height = data.size
    @width = data.first.size
    data.each_with_index do |row, i|
      row.chars.each_with_index do |letter, j|
        @cells << Cell.new(j, i, letter)
      end
    end
  end

  def resolve
    print_all
    resolve_cell(cell_start)
  end

  def cell_start
    @start ||= @cells.find { |c| c.start? }
  end

  def resolve_cell(cell)
    return true if cell.sortie?
    cell.win_print(@win)
    cell.test!
    cell.win_print(@win)
    sleep(0.05)
    ad_cells = adjacente_cells(cell)
    success = ad_cells.any? { |c| resolve_cell(c) }
    success ? cell.success! : cell.dead!
    cell.win_print(@win)
    success
  end

  def adjacente_cells(cell)
    @cells.select do |c|
      (c.x == cell.x - 1 && c.y == cell.y) ||
      (c.x == cell.x + 1 && c.y == cell.y) ||
      (c.x == cell.x && c.y == cell.y - 1) ||
      (c.x == cell.x && c.y == cell.y + 1)
    end.select(&:testable?)
  end
end

begin
  Curses.init_screen
  Curses.start_color
  Curses.noecho
  Curses.cbreak
  Curses.init_pair(Cell::WALL,    Curses::COLOR_WHITE, Curses::COLOR_BLACK)
  Curses.init_pair(Cell::START,   Curses::COLOR_MAGENTA, Curses::COLOR_BLACK)
  Curses.init_pair(Cell::EXIT,    Curses::COLOR_MAGENTA, Curses::COLOR_BLACK)
  Curses.init_pair(Cell::EMPTY,   Curses::COLOR_BLACK, Curses::COLOR_BLACK)
  Curses.init_pair(Cell::TESTING, Curses::COLOR_YELLOW, Curses::COLOR_BLACK)
  Curses.init_pair(Cell::DEAD,    Curses::COLOR_RED, Curses::COLOR_BLACK)
  Curses.init_pair(Cell::SUCCESS, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
  laby = Labyrinthe.new("map4.txt")

  top, left = (Curses.lines - laby.height) / 2, (Curses.cols - laby.width) / 2
  win = Curses::Window.new(laby.height, laby.width, top, left)
  laby.win = win
  laby.resolve
  win.getch
ensure
  win.close
end



