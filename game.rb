require 'ruby2d'

SNAKE_SIZE = 10
GRID_WIDTH = Window.width / SNAKE_SIZE
GRID_HEIGHT = Window.height / SNAKE_SIZE

set background: 'navy'
set fps_cap: 20

class Snake
    attr_writer :direction
    def initialize
        @positions = [[2,1],[2,2],[2,3],[2,4]]
        @direction = 'down'
        @snake_growth = false
    end
    def draw
        @positions.each do |pos|
            Square.new(x: pos[0] * SNAKE_SIZE, y: pos[1] * SNAKE_SIZE, size: SNAKE_SIZE-1, color: 'white')
        end
    end
    def move
        if !@snake_growth
            @positions.shift
        end
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
        @finished = false
    end

    def draw_food
        display_score
        unless game_over?
        Square.new(x: @food_x * SNAKE_SIZE, y: @food_y * SNAKE_SIZE, size: SNAKE_SIZE, color: 'green')
        end
    end
    def display_score
        Text.new(text_message, x: 10, y: 10, color: 'red',size:12)
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

    def finish
        @finished = true
    end
    def game_over?
        @finished
    end

    private
    def text_message
        if game_over?
            "Game Over, your score is: #{@score}. Press 'R' to restart."
        else
            "Score: #{@score}"
        end
    end
end


snake = Snake.new
game = Game.new

#ruby2d built-in event
update do
    clear
    unless game.game_over?
    snake.move
    end
    snake.draw
    game.draw_food
    if game.food_was_eaten?(snake.x, snake.y)
        game.record_score
        snake.snake_growth
    end
    if snake.hit_itself?
        game.finish
    end
end

on :key_down do |e|
    if ['up', 'down', 'left', 'right'].include?(e.key)
        if snake.opposite_direction?(e.key)
            snake.direction = e.key
        end
    else if e.key == 'r'
        snake = Snake.new
        game = Game.new
    end
    end
end

#show the window
show
