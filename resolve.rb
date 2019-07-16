require 'awesome_print'
require_relative 'string_color'



class Cell
  attr_reader :x, :y

  def initialize(x, y, letter)
    @x = x
    @y = y
    @letter = letter
  end

  def to_s
    case @letter
    when '.' then @letter.blue
    when 'D' then '.'.red
    when 'S' then @letter.magenta
    when 'E' then @letter.magenta
    when 'T' then '.'.brown
    when 'W' then '.'.green
    else
      @letter
    end
  end

  def start?
    @letter == 'S'
  end

  def test!
    @letter = 'T' if @letter == '.'
  end

  def testable?
    ['E', '.'].include? @letter
  end

  def dead!
    @letter = 'D'
  end

  def success!
    @letter = 'W'
  end

  def sortie?
    @letter == 'E'
  end
end

class Labyrinthe
  def initialize(file_path)
    @file_path = file_path
    parse
  end

  def debug?(cell)
    cell.x == 2 && cell.y == 3
  end

  def show
    sleep(0.03)
    system "clear"
    @height.times do |j|
      @width.times do |i|
        print @cells.find { |c| c.x == i && c.y == j }
      end
      print "\n"
    end
    puts "\n\n\n"
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
    resolve_cell(cell_start)
  end

  def cell_start
    @start ||= @cells.find { |c| c.start? }
  end

  def resolve_cell(cell)
    return true if cell.sortie?

    show
    cell.test!
    ad_cells = adjacente_cells(cell)
    success = ad_cells.any? { |c| resolve_cell(c) }
    success ? cell.success! : cell.dead!
    show
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

Labyrinthe.new("map2.txt").resolve



