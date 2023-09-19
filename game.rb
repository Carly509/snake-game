require 'ruby2d'

SNAKE_SIZE = 10
set background: 'random'

class Snake
    def initialize
        @positions = [[2,1],[2,2],[2,3],[2,4]]
    end
    def draw
        @positions.each do |pos|
            Square.new(x: pos[0] * SNAKE_SIZE, y: pos[1] * SNAKE_SIZE, size: SNAKE_SIZE-1, color: 'white')
        end
    end
end

snake = Snake.new
snake.draw
#show the window
show
