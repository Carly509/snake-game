require 'ruby2d'

SNAKE_SIZE = 10
GRID_WIDTH = Window.width / SNAKE_SIZE
GRID_HEIGHT = Window.height / SNAKE_SIZE

set background: 'random'

class Snake
    attr_writer :direction
    def initialize
        @positions = [[2,1],[2,2],[2,3],[2,4]]
        @direction = 'down'
    end
    def draw
        @positions.each do |pos|
            Square.new(x: pos[0] * SNAKE_SIZE, y: pos[1] * SNAKE_SIZE, size: SNAKE_SIZE-1, color: 'white')
        end
    end
    def move
        @positions.shift
        case @direction
        when 'down'
            @positions.push([@positions.last[0], @positions.last[1] + 1])
        when 'up'
            @positions.push([@positions.last[0], @positions.last[1] - 1])
        when 'left'
            @positions.push([@positions.last[0] - 1, @positions.last[1]])
        when 'right'
            @positions.push([@positions.last[0] + 1, @positions.last[1]])
        end
    end

    def opposite_direction?(new_direction)
      case @direction
        when 'down' then new_direction != 'up'
        when 'up' then new_direction != 'down'
        when 'left' then new_direction != 'right'
        when 'right' then new_direction != 'left'
      end
    end

    def new_coordinates(x, y)
        [x % GRID_WIDTH, y % GRID_HEIGHT]
    end

    private
    def snake_head
        @positions.last
    end
    def snake_tail
        @positions[0]
    end
end


snake = Snake.new

#ruby2d built-in event
update do
    clear
    snake.draw
    snake.move
end

on :key_down do |e|
    if ['up', 'down', 'left', 'right'].include?(e.key)
        snake.direction = e.key
    end
end

#show the window
show
