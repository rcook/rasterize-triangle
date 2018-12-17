#!/usr/bin/env ruby

require 'chunky_png'

class Point2D
    attr_reader :x
    attr_reader :y

    def initialize(x, y)
        @x = x
        @y = y
    end
end

def orient_2d(a, b, c)
    (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
end

def draw_triangle(image, colour, v0, v1, v2)
    # Compute triangle bounding box
    min_x, max_x = [v0.x, v1.x, v2.x].minmax
    min_y, max_y = [v0.y, v1.y, v2.y].minmax

    # Clip against screen bounds
    min_x = [min_x, 0].max
    min_y = [min_y, 0].max
    max_x = [max_x, image.width - 1].min
    max_y = [max_y, image.height - 1].min

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
a = Point2D.new(100, 100)
b = Point2D.new(200, 200)
c = Point2D.new(50, 250)
draw_triangle(png, colour, a, b, c)

png.save 'output.png', interlace: true
