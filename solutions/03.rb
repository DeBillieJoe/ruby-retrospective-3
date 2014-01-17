module Graphics
  class Point
    attr_accessor :x, :y, :points

    def initialize(x, y)
      @points = []
      @x = x
      @y = y
    end

    def eql?(other)
      @x == other.x and @y == other.y
    end

    alias :== :eql?

    def lefter?(other)
      @x <= other.x
    end

    def upper?(other)
      @y <= other.y
    end

    def draw()
      @points = [[@x, @y]]
    end
  end

  class Line
    attr_accessor :from, :to, :points

    def initialize(from, to)
      @points = []
      if from.lefter? to
        @from, @to = from, to
      else
        @from, @to= to, from
      end
    end

    def eql?(other)
      @from == other.from and @to == other.to
    end

    alias :== :eql?

    def from()
      if @from.x == @to.x
        @from.y <= @to.y ? @from : @to
      else
        @from
      end
    end

    def to()
      if @from.x == @to.x
        @from.y <= @to.y ? @to : @from
      else
        @to
      end
    end

    def vertical?()
      @from.x == @to.x
    end

    def horizontal?()
      @from.y == @to.y
    end

    def draw()
      vertical_draw if vertical?
      horizontal_draw if horizontal?
      draw_line() if points.empty?
      points
    end

    def vertical_draw()
      from.y.upto(to.y).each { |y| points << [from.x, y] } if points.empty?
    end

    def horizontal_draw()
      from.x.upto(to.x).each { |x| points << [x, from.y] } if points.empty?
    end

    def draw_line()

    end

  end
  class Rectangle
    attr_accessor :points, :left, :right, :top_left, :top_right,
                  :bottom_left, :bottom_right

    def initialize(left, right)
      if left.lefter? right or left.upper? right
        @left, @right  = left, right
      else
        @left, @right  = right, left
      end
      left_corners()
      right_corners()
    end

    def left_corners()
      other_left_point = Point.new left.x, right.y
      if left.upper? other_left_point
        @top_left, @bottom_left = left, other_left_point
      else
        @top_left, @bottom_left = other_left_point, left
      end
    end

    def right_corners()
      other_right_point = Point.new right.x, left.y
      if right.upper? other_right_point
        @top_right, @bottom_right = right, other_right_point
      else
        @top_right, @bottom_right = other_right_point, right
      end
    end

    def left?()
      @left
    end

    def right?()
      @right
    end

    def draw()
      @points = []
      sides = [Line.new(bottom_left, top_left), Line.new(top_left, top_right),
               Line.new(top_right, bottom_right), Line.new(bottom_left, bottom_right)]
      sides.each { |side| points << side.draw }

      points.flatten(1).uniq
    end

    def top_left()
      @top_left
    end

    def bottom_left()
      @bottom_left
    end

    def top_right
      @top_right
    end

    def bottom_right
      @bottom_right
    end
  end

  class Canvas
    attr_accessor :pixels

    def initialize(width, height)
      @pixels = {}
      0.upto(height-1) do |y|
        0.upto(width-1) do |x|
          pixels[[x, y]]=false
        end
      end
      @width = width
      @height = height
    end

    def set_pixel(x, y)
      @pixels[[x, y]]=true
    end

    def pixel_at?(x, y)
      @pixels[[x, y]]
    end

    def draw(figure)
      figure.draw.each { |point| set_pixel(*point) }
    end

    def render(renderer)
      content = ""
      length = renderer.symbols[:symbol_length]
      pixels.values.each { |value| content += renderer.symbols[value] }
      content.chars.each_slice(30*length).map(&:join).join(renderer.symbols[:new_line])
    end

    def render_as(renderer)
      output = renderer.symbols[:start]
      output += render(renderer)
      output += renderer.symbols[:end]
      output
    end
  end

  module Renderers
    class Ascii
      @symbols = {true => "@", false => "-", :new_line => "\n",
                  :start => "", :end => "", :symbol_length => 1}

      def Ascii.symbols()
        @symbols
      end
    end

    class Html
      @start = "<!DOCTYPE html>
<html>
<head>
  <title>Rendered Canvas</title>
  <style type="'text/css'">
    .canvas {
      font-size: 1px;
      line-height: 1px;
    }
    .canvas * {
      display: inline-block;
      width: 10px;
      height: 10px;
      border-radius: 5px;
    }
    .canvas i {
      background-color: #eee;
    }
    .canvas b {
      background-color: #333;
    }
  </style>
</head>
<body>
  <div class="'canvas'">
    "

      @end =  "</div>
             </body>
             </html>"
      @symbols = {true => "<b></b>", false => "<i></i>", :new_line => "<br>",
                  :start => @start, :end => @end, :symbol_length => 7}

      def Html.symbols()
        @symbols
      end
    end
  end
end