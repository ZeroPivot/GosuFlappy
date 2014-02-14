class Player

  GRAVITY = 100
  JUMP_TIME = 0.3
  JUMP_POWER = -250
  INCREASE_GRAVITY = 10
  attr_accessor :x, :y, :dead

  def self.load_image(window)
    image = ""
    images = ['media/flappy-1.png', 'media/flappy-2.png', 'media/flappy-3.png']
    sec = (Gosu::milliseconds / 1000).to_s.split(//).last
    if ["0","3","6","9"].include? sec
      image = images[0]
    elsif ["1","4","7"].include? sec
      image = images[1]
    elsif ["2","5","8"].include? sec
      image = images[2]
    else
      image = images[2]
    end
    @player_image = Gosu::Image.new(window, image, true)
  end

  def initialize(window)
    @player_image = self.class.load_image(window)
    @window = window

    @velocityY = 0
    @gravity = 50
    @delta = 0.25

    @space = false
    @space_before = false

    @jump = false
    @jump_max = 0.3
    @jump_start = 0

    @dead = false

    reset
  end

  def reset
    @x = @window.width / 4
    @y = @window.height / 2
    @a = 0
  end

  def draw
    @player_image = self.class.load_image(@window)
    @player_image.draw_rot(@x, @y, 1, @a)
  end

  def update
    dead_if_touch_ground
    if @dead
      if @y < @window.ground_y - @player_image.height/2
        @gravity += INCREASE_GRAVITY
        @a += 25
        @a = [@a,90].min
        @y += @gravity * @window.delta
      else
        @y = @window.ground_y - @player_image.height/2
      end
    else
      move
      @y += @velocityY * @window.delta
      @gravity += INCREASE_GRAVITY
      @a += 0.5
      @a = [@a,90].min
      @y += @gravity * @window.delta
    end
  end

  def move

    @space = true if @window.button_down?(Gosu::KbSpace)
    @space = false if !@window.button_down?(Gosu::KbSpace)

    if @space && !@space_before
      @jump_start = Gosu::milliseconds / 1000.0
    end

    if @jump_start > 0
      @gravity = GRAVITY
      if ((Gosu::milliseconds / 1000.0) - @jump_start) > JUMP_TIME
        @jump_start = 0
      else
        @velocityY = JUMP_POWER
        @a = -45
        @a = -22 if ((Gosu::milliseconds / 1000.0) - @jump_start) > JUMP_TIME / 3
        @a = 0 if ((Gosu::milliseconds / 1000.0) - @jump_start) > (JUMP_TIME / 3)*2
      end
    end

    @space_before = @space
  end

  def killed?
    (@y == @window.ground_y - @player_image.height/2) ? true : false
  end

  def dead_if_touch_ground
    if @y >= @window.ground_y - @player_image.height/2
      @dead = true
    end
  end

  def through_wall?(other)
    @x > other.x + (other.width/2)
  end

  def collision?(other)
    @y + @player_image.height/2 > other.y &&
    @y               < other.y + other.height &&
    @x + @player_image.width/2  > other.x &&
    @x               < other.x + other.width
  end

end
