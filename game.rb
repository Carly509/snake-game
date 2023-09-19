require 'ruby2d'

SNAKE_SIZE = 10
GRID_WIDTH = Window.width / SNAKE_SIZE
GRID_HEIGHT = Window.height / SNAKE_SIZE

set background: 'black'

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
            @positions.push(new_coordinates(snake_head[0], snake_head[1] + 1))
        when 'up'
            @positions.push(new_coordinates(snake_head[0], snake_head[1] - 1))
        when 'left'
            @positions.push(new_coordinates(snake_head[0] - 1, snake_head[1]))
        when 'right'
            @positions.push(new_coordinates(snake_head[0] + 1, snake_head[1]))
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

    def x
        snake_head[0]
    end

    def y
        snake_head[1]
    end

    private
    def snake_head
        @positions.last
    end
    def snake_tail
        @positions[0]
    end
end

class Game
    def initialize
        @score = 0
        @level = 1
        @food_x = rand(GRID_WIDTH)
        @food_y = rand(GRID_HEIGHT)
    end

    def draw_food
        display_score
        Square.new(x: @food_x * SNAKE_SIZE, y: @food_y * SNAKE_SIZE, size: SNAKE_SIZE, color: 'green')
    end
    def display_score
        Text.new("Score: #{@score}", x: 10, y: 10, color: 'red',size:12)
        Text.new("Level: #{@level}", x: 10, y: 25, color: 'red',size:12)
    end

    def food_was_eaten?(x,y)
        x == @food_x && y == @food_y
    end

    def record_score
        @score += 1
        @food_x = rand(GRID_WIDTH)
        @food_y = rand(GRID_HEIGHT)
    end
end


snake = Snake.new
game = Game.new

#ruby2d built-in event
update do
    clear
    snake.draw
    snake.move
    game.draw_food
    if game.food_was_eaten?(snake.x, snake.y)
        game.record_score
    end
end

on :key_down do |e|
    if ['up', 'down', 'left', 'right'].include?(e.key)
        snake.direction = e.key
    end
end

#show the window
show
