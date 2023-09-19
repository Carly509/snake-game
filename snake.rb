class Snake
    attr_writer :direction

    def initialize
      @positions = [[2, 1], [2, 2], [2, 3], [2, 4]]
      @direction = 'down'
      @snake_growth = false
    end

    def draw
      @positions.each do |pos|
        Square.new(x: pos[0] * SNAKE_SIZE, y: pos[1] * SNAKE_SIZE, size: SNAKE_SIZE - 1, color: 'white')
      end
    end

    def move
      @positions.shift unless @snake_growth

      case @direction
      when 'down'
        @positions.push(new_coordinates(snake_head[0], snake_head[1] + 1))
      when 'up'
        @positions.push(new_coordinates(snake_head[0], snake_head[1] - 1))
      when 'left'
        @positions.push(new_coordinates(snake_head[0] - 1, snake_head[1]))
      when 'right'
        @positions.push(new_coordinates(snake_head[0] + 1, snake_head[1]))
      end

      @snake_growth = false
    end

    def opposite_direction?(new_direction)
      case @direction
      when 'down'
        new_direction != 'up'
      when 'up'
        new_direction != 'down'
      when 'left'
        new_direction != 'right'
      when 'right'
        new_direction != 'left'
      end
    end

    def new_coordinates(x, y)
      [x % GRID_WIDTH, y % GRID_HEIGHT]
    end

    def x
      snake_head[0]
    end

    def y
      snake_head[1]
    end

    def snake_growth
      @snake_growth = true
    end

    def hit_itself?
      @positions.uniq.length != @positions.length
    end

    private

    def snake_head
      @positions.last
    end
  end
