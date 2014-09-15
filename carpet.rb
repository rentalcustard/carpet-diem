require 'forwardable'
require 'texplay'
require 'chingu'
require_relative 'positionable'

class Carpet
  include Positionable
  extend Forwardable
  def_delegators :@carpet_image, :width, :height
  CARPET_SPEED = 5
  attr_accessor :x, :y
  attr_reader :carpet_image
  alias :image :carpet_image
  undef :carpet_image

  def initialize(window, carpet_image_file = 'media/carpet.png', carpet_image_flipped_file = 'media/carpet_flipped.png')
    @carpet_image = @carpet_image_right = Gosu::Image.new(window, carpet_image_file)
    @carpet_image_left = Gosu::Image.new(window, carpet_image_flipped_file)
    @window = window
    @x = window.width/2.0 - @carpet_image.width/2.0
    @x += 1 if window.width.odd? && @carpet_image.width.odd?
    @y = window.height/(18/13.0) - @carpet_image.height/2.0
  end

  def draw
    @carpet_image.draw(@x, @y, 4)
  end

  def move_left
    @x = [@x - CARPET_SPEED, 0 - @carpet_image.height / 4].max
    @carpet_image = @carpet_image_left
  end

  def move_right
    @x = [@x + CARPET_SPEED, @window.width - @carpet_image.height / 2].min
    @carpet_image = @carpet_image_right
  end

  def collides_with?(object)
    images_overlap?(object) && !opaque_overlapping_pixels(object).empty?
  end

  def images_overlap?(object)
    object.bottom  > top    &&
      object.top   < bottom &&
      object.right > left   &&
      object.left  < right
  end

  def opaque_overlapping_pixels(object)
    overlapping_pixels(object).select do |x,y|
      !@carpet_image.transparent_pixel?(x,y) && !object.image.transparent_pixel?(x,y)
    end
  end

  def overlapping_pixels(object)
    if left < object.left
      box_left = object.left
      if right < object.right
        box_width = right - object.left
      else
        box_width = object.width
      end
    else
      box_width = object.right - left
      box_left = left
    end
    if top < object.top
      box_top = object.top
      if bottom < object.bottom
        box_height = bottom - object.top
      else
        box_height = object.height
      end
    else
      box_top = top
      box_height = object.bottom - top
    end
    pixels(box_left, box_top, box_width, box_height)
  end

  def pixels(offset_x, offset_y, width, height)
    height.round.times.flat_map do |y|
      width.round.times.map do |x|
        [(x + offset_x).to_i, (y + offset_y).to_i]
      end
    end
  end

end
