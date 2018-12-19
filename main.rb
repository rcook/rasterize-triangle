#!/usr/bin/env ruby

require 'chunky_png'

class Numeric
  def degrees
    self * Math::PI / 180
  end
end

class Point2D
  attr_reader :x
  attr_reader :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_s
    "(#{@x}, #{@y})"
  end
end

def centroid(*args)
  points = args.is_a?(Array) && args.first.is_a?(Array) ? args.first : args
  acc_x, acc_y = points.reduce([0, 0]) { |(acc_x, acc_y), p| [acc_x + p.x, acc_y + p.y]}
  n = points.size
  Point2D.new(acc_x / n, acc_y / n)
end

# See https://math.stackexchange.com/questions/978642/how-to-sort-vertices-of-a-polygon-in-counter-clockwise-order
def sort_clockwise(*args)
  points = args.is_a?(Array) && args.first.is_a?(Array) ? args.first : args
  c = centroid(points)
  points.sort do |a, b|
    a1 = (Math.atan2(a.x - c.x, a.y - c.y).degrees + 360) % 360
    a2 = (Math.atan2(b.x - c.x, b.y - c.y).degrees + 360) % 360
    a1 - a2
  end
end

def orient_2d(a, b, c)
  (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
end

def draw_triangle(image, colour, v0, v1, v2)
  v0, v1, v2 = sort_clockwise(v0, v1, v2)

  # Compute triangle bounding box
  min_x, max_x = [v0.x, v1.x, v2.x].minmax
  min_y, max_y = [v0.y, v1.y, v2.y].minmax

  # Clip against screen bounds
  min_x = [min_x, 0].max
  min_y = [min_y, 0].max
  max_x = [max_x, image.width - 1].min
  max_y = [max_y, image.height - 1].min

  # Rasterize
  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      p = Point2D.new(x, y)
      w0 = orient_2d(v1, v2, p)
      w1 = orient_2d(v2, v0, p)
      w2 = orient_2d(v0, v1, p)
      if w0 >= 0 && w1 >= 0 && w2 >= 0
        image[x, y] = colour
      end
    end
  end
end

png = ChunkyPNG::Image.new(640, 480, ChunkyPNG::Color::TRANSPARENT)

colour = ChunkyPNG::Color.rgb(150, 0, 0)
a = Point2D.new(340, 80)
b = Point2D.new(245, 149)
c = Point2D.new(281, 261)
draw_triangle(png, colour, a, b, c)

png.save 'red-triangle.png', interlace: true
