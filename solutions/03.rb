module Graphics
  class Point
    attr_reader :x, :y
    attr_accessor :points

    def initialize(x, y)
      @x = x
      @y = y
      @points = [[@x, @y]]
    end

    def hash
      [x, y].hash
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
    attr_reader :from, :to
    attr_accessor :points

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
      step.zero? ? from.draw : bresenham_algorithm
    end

    def bresenham_algorithm
      delta = (to - from) / step.to_r
      current_point = from

      step.succ.times do
        @points << [current_point.x.round, current_point.y.round]
        current_point = current_point + delta
      end

      points
    end

    def hash
      [from, to].hash
    end
  end

  class Rectangle
    attr_reader :left, :right, :top_left, :top_right,
                  :bottom_left, :bottom_right
    attr_accessor :points

    def hash
      [top_left, bottom_left, bottom_right, top_right].hash
    end

    def eql?(other)
      @top_left == other.top_left and @top_right == other.top_right and
      @bottom_right == other.bottom_right and @bottom_left == other.bottom_left
    end

    alias :== :eql?

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
    attr_reader :width, :height

    def initialize(width, height)
      @pixels = {}
      0.upto(height-1) do |y|
        0.upto(width-1) do |x|
          pixels[[x, y]] = false
        end
      end

      @width = width
      @height = height
    end

    def set_pixel(x, y)
      @pixels[[x, y]] = true
    end

    def pixel_at?(x, y)
      @pixels[[x, y]]
    end

    def draw(figure)
      figure.draw.each { |point| set_pixel(*point) }
    end

    def canvas(width, height)
      0.upto(height - 1).map { |y| 0.upto(width - 1).map { |x| [x, y] } }
    end

    def render_as(renderer)

      renderer::CONTENT % canvas(@width, @height).map  { |row| row.map { |point| renderer::SYMBOLS[@pixels[point]] }.join }.join(renderer::SYMBOLS[:new_line])

    end
  end

  module Renderers
    module Ascii
      SYMBOLS = {true => "@".freeze, false => "-".freeze, :new_line => "\n".freeze,
                  :start => "", :end => ""}
      CONTENT = "%s"
    end

    module Html
      SYMBOLS = {true => "<b></b>".freeze, false => "<i></i>".freeze, :new_line => "<br>".freeze}

      CONTENT =
        "<!doctypehtml>
        <html>
        <head>
          <title>Rendered Canvas</title>
          <style type=\"text/css\">
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
          <divclass=\"canvas\">
            %s
          </div>
        </body>
        </html>"
    end
  end
end