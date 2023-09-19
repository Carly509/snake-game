require 'ruby2d'
require_relative 'snake'

SNAKE_SIZE = 10
GRID_WIDTH = Window.width / SNAKE_SIZE
GRID_HEIGHT = Window.height / SNAKE_SIZE

set background: 'olive'
fps_cap = 20
set fps_cap: fps_cap
code_executed = false

class Game < Snake
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
        Square.new(x: @food_x * SNAKE_SIZE, y: @food_y * SNAKE_SIZE, size: SNAKE_SIZE, color: 'lime')
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

    def score
        @score
    end

    def increase_level
        @level += 1
        puts @level

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
    if game.score % 5 == 0 && game.score != 0  && !code_executed
        game.increase_level
        fps_cap += 5
        set fps_cap: fps_cap
        code_executed = true
    elsif game.score % 5 != 0
        code_executed = false
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
