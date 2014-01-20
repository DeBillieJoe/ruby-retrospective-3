module Graphics
  class Point
    attr_accessor :x, :y, :points

    def initialize(x, y)
      @x = x
      @y = y
      @points = [[@x, @y]]
    end

    def eql?(other)
      @x == other.x and @y == other.y
    end

    alias :== :eql?

    def +(other)
      Point.new x + other.x, y + other.y
    end

    def -(other)
      Point.new x - other.x, y - other.y
    end

    def /(divisor)
      Point.new x / divisor, y / divisor
    end

    def <=>(other)
      return -1 if x < other.x or (x == other.x and y < other.y)
      return 0 if self == other
      1
    end

    def draw()
      points
    end
  end

  class Line
    attr_accessor :from, :to, :points

    def initialize(from, to)
      @from, @to = *[from, to].sort
      @points = []
    end

    def eql?(other)
      @from == other.from and @to == other.to
    end

    alias :== :eql?

    def step
      [(to.x - from.x).abs, (to.y-from.y).abs].max
    end

    def draw
      delta = (to - from) / step.to_r
      current_point = from

      step.succ.times do 
        @points << [current_point.x.round, current_point.y.round]
        current_point = current_point + delta 
      end

      points
    end
  end

  class Rectangle
    attr_accessor :points, :left, :right, :top_left, :top_right,
                  :bottom_left, :bottom_right

    def initialize(left, right)
      @left, @right = *[left, right].sort
      @top_left, @bottom_left, @top_right, @bottom_right = *[left, right, 
        Point.new(left.x, right.y), 
        Point.new(right.x, left.y)].sort

      @corners = [top_left, bottom_left, bottom_right, top_right]
      @points = []
    end

    def draw
      sides.each { |side| points << side.draw }
      points.flatten 1
    end

    def sides
      [
        Line.new(top_left,    top_right   ),
        Line.new(top_right,   bottom_right),
        Line.new(bottom_left, bottom_right),
        Line.new(top_left,    bottom_left )
      ]
    end
  end

  class Canvas
    attr_accessor :pixels

    def initialize(width, height)
      @pixels = {}
      0.upto(height-1) do |y|
        0.upto(width-1) do |x|
          pixels[[x, y]] = false

      @width = width
      @height = height
    end

    def set_pixel(x, y)
      @pixels[[y, x]] = true
    end

    def pixel_at?(x, y)
      @pixels[[y, x]]
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
    module Ascii
      SYMBOLS = {true => "@".freeze, false => "-".freeze, :new_line => "\n".freeze,
                  :start => "", :end => ""}
    end

    module Html
      SYMBOLS = {true => "<b></b>".freeze, false => "<i></i>".freeze, :new_line => "<br>".freeze,
                  :start => @start, :end => @end}

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