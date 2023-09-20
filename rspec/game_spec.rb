require 'rspec'
require 'ruby2d'
require_relative 'snake'
require_relative 'game'

describe Game do
  let(:game) { Game.new }
  let(:snake) { Snake.new }

  describe '#initialize' do
    it 'sets the initial score to 0' do
      expect(game.score).to eq(0)
    end

    it 'sets the initial level to 1' do
      expect(game.instance_variable_get(:@level)).to eq(1)
    end

    it 'sets the initial food position randomly within the grid' do
      expect(game.instance_variable_get(:@food_x)).to be_between(0, GRID_WIDTH - 1)
      expect(game.instance_variable_get(:@food_y)).to be_between(0, GRID_HEIGHT - 1)
    end

    it 'sets the initial finished flag to false' do
      expect(game.game_over?).to be(false)
    end
  end

  describe '#draw_food' do
    it 'displays the food on the screen' do
      expect_any_instance_of(Square).to receive(:new).with(x: game.instance_variable_get(:@food_x) * SNAKE_SIZE, y: game.instance_variable_get(:@food_y) * SNAKE_SIZE, size: SNAKE_SIZE, color: 'lime')
      game.draw_food
    end

    it 'does not display the food if the game is over' do
      allow(game).to receive(:game_over?).and_return(true)
      expect_any_instance_of(Square).not_to receive(:new)
      game.draw_food
    end
  end

  describe '#food_was_eaten?' do
    it 'returns true if the given coordinates match the food position' do
      game.instance_variable_set(:@food_x, 5)
      game.instance_variable_set(:@food_y, 5)
      expect(game.food_was_eaten?(5, 5)).to be(true)
    end

    it 'returns false if the given coordinates do not match the food position' do
      game.instance_variable_set(:@food_x, 5)
      game.instance_variable_set(:@food_y, 5)
      expect(game.food_was_eaten?(4, 4)).to be(false)
    end
  end

  describe '#record_score' do
    it 'increments the score by 1' do
      expect { game.record_score }.to change { game.score }.by(1)
    end

    it 'sets a new random position for the food' do
      old_food_position = [game.instance_variable_get(:@food_x), game.instance_variable_get(:@food_y)]
      game.record_score
      new_food_position = [game.instance_variable_get(:@food_x), game.instance_variable_get(:@food_y)]
      expect(new_food_position).not_to eq(old_food_position)
    end
  end

  describe '#finish' do
    it 'sets the finished flag to true' do
      game.finish
      expect(game.game_over?).to be(true)
    end
  end

  describe '#increase_level' do
    it 'increments the level by 1' do
      expect { game.increase_level }.to change { game.instance_variable_get(:@level) }.by(1)
    end

    it 'increases the FPS cap by 5' do
      old_fps_cap = fps_cap
      game.increase_level
      new_fps_cap = get(:fps_cap)
      expect(new_fps_cap).to eq(old_fps_cap + 5)
    end

    it 'does not increase the FPS cap if the score is not a multiple of 5' do
      allow(game).to receive(:score).and_return(3)
      old_fps_cap = fps_cap
      game.increase_level
      new_fps_cap = get(:fps_cap)
      expect(new_fps_cap).to eq(old_fps_cap)
    end

    it 'only increases the FPS cap once per level' do
      expect { game.increase_level }.to change { fps_cap }.by(5)
      expect { game.increase_level }.not_to change { fps_cap }
    end
  end

  describe '#text_message' do
    it 'returns a "Game Over" message with the score if the game is over' do
      allow(game).to receive(:game_over?).and_return(true)
      allow(game).to receive(:score).and_return(10)
      expect(game.send(:text_message)).to eq("Game Over, your score is: 10. Press 'R' to restart.")
    end

    it 'returns a "Score" message with the current score if the game is not over' do
      allow(game).to receive(:game_over?).and_return(false)
      allow(game).to receive(:score).and_return(5)
      expect(game.send(:text_message)).to eq("Score: 5")
    end
  end

  describe '#update' do
    before { allow(snake).to receive_messages(move: nil, draw: nil, snake_growth: nil, hit_itself?: nil) }

    context 'when the snake eats the food' do
      before { allow(game).to receive_messages(food_was_eaten?: true, record_score: nil) }

      it 'calls #record_score on the game object' do
        expect(game).to receive(:record_score)
        game.update
      end

      it 'calls #snake_growth on the snake object' do
        expect(snake).to receive(:snake_growth)
        game.update
      end
    end

    context 'when the snake hits itself' do
      before { allow(snake).to receive_messages(hit_itself?: true) }

      it 'calls #finish on the game object' do
        expect(game).to receive(:finish)
        game.update
      end
    end

    context 'when the score is a multiple of 5 and has not been executed yet' do
      before { allow(game).to receive_messages(score: 5) }

      it 'calls #increase_level on the game object' do
        expect(game).to receive(:increase_level)
        game.update
      end

      it 'increases the FPS cap by 5' do
        old_fps_cap = fps_cap
        game.update
        new_fps_cap = get(:fps_cap)
        expect(new_fps_cap).to eq(old_fps_cap + 5)
      end

      it 'sets the code_executed flag to true' do
        game.update
        expect(code_executed).to be(true)
      end
    end

    context 'when the score is not a multiple of 5 or has already been executed' do
      before { allow(game).to receive_messages(score: 3) }

      it 'does not call #increase_level on the game object' do
        expect(game).not_to receive(:increase_level)
        game.update
      end

      it 'does not increase the FPS cap' do
        old_fps_cap = fps_cap
        game.update
        new_fps_cap = get(:fps_cap)
        expect(new_fps_cap).to eq(old_fps_cap)
      end

      it 'does not set the code_executed flag to true' do
        game.update
        expect(code_executed).to be(false)
      end
    end

    context 'when a key is pressed' do
      context 'when a valid direction key is pressed and not in opposite direction of current direction' do
        before { allow(e = double(key: 'up')).to receive_messages(key: e.key) }

        it 'changes the direction of the snake to the pressed key' do
          old_direction = snake.direction.dup.freeze # dup.freeze to prevent mutation of old_direction by #opposite_direction?
          snake.direction = 'down'
          expect { game.trigger(:key_down, key: e.key) }.to change { snake.direction }.from(old_direction).to(e.key)
        end
      end

      context 'when "r" is pressed' do
        before { allow(e = double(key: 'r')).to receive_messages(key: e.key) }

        it 'resets the snake and game objects' do
          old_snake_x = snake.x.dup.freeze # dup.freeze to prevent mutation of old_snake_x by #initialize method of Snake class
          old_game_score = game.score.dup.freeze # dup.freeze to prevent mutation of old_game_score by #initialize method of Game class
          game.trigger(:key_down, key: e.key)
          expect(snake.x).not_to eq(old_snake_x)
          expect(game.score).not_to eq(old_game_score)
        end
      end

      context 'when an invalid direction key is pressed or in opposite direction of current direction' do
        before { allow(e = double(key: 'down')).to receive_messages(key: e.key) }

        it "does not change the direction of the snake and keeps it moving in its current direction" do
          old_direction = snake.direction.dup.freeze # dup.freeze to prevent mutation of old_direction by #opposite_direction?
          expect { game.trigger(:key_down, key: e.key) }.not_to change { snake.direction }
          expect(snake.direction).to eq(old_direction)
        end
      end
    end
  end
end

describe Snake do
  let(:snake) { Snake.new }

  describe '#initialize' do
    it "sets up a new snake with an initial length of three squares" do
      expect(snake.positions.length).to eq(3)
    end

    it "sets up a new snake with an initial position at (0,0)" do
      expect(snake.positions.first).to eq([0,0])
    end

    it "sets up a new snake with an initial direction of right" do
      expect(snake.direction).to eq('right')
    end
  end

  describe '#move' do
    context "when direction is right" do
      before { snake.direction = "right" }

      it "moves one square to the right" do
        old_position = snake.positions.dup.freeze # dup.freeze to prevent mutation of old_position by #move method
        snake.move
        new_position = snake.positions.dup.freeze # dup.freeze to prevent mutation of new_position by #move method
        expect(new_position[0][0]).to eq(old_position[0][0] + SNAKE_SIZE)
        expect(new_position[0][1]).to eq(old_position[0][1])
        expect(new_position[1]).to eq(old_position[0..-2])
        expect(new_position.length).to eq(old_position.length)
      end
    end

    context "when direction is left" do
      before { snake.direction = "left" }

      it "moves one square to the left" do
        old_position = snake.positions.dup.freeze # dup.freeze to prevent mutation of old_position by #move method
        snake.move
        new_position = snake.positions.dup.freeze # dup.freeze to prevent mutation of new_position by #move method
        expect(new_position[0][0]).to eq(old_position[0][0] - SNAKE_SIZE)
        expect(new_position[0][1]).to eq(old_position[0][1])
        expect(new_position[1]).to eq(old_position[0..-2])
        expect(new_position.length).to eq(old_position.length)
      end
    end

    context "when direction is up" do
      before { snake.direction = "up" }

      it "moves one square up" do
        old_position = snake.positions.dup.freeze # dup.freeze to prevent mutation of old_position by #move method
        snake.move
        new_position = snake.positions.dup.freeze # dup.freeze to prevent mutation of new_position by #move method
        expect(new_position[0][0]).to eq(old_position[0][0])
        expect(new_position[0][1]).to eq(old_position[0][1] - SNAKE_SIZE)
        expect(new_position[1]).to eq(old_position[0..-2])
        expect(new_position.length).to eq(old_position.length)
      end
    end

    context "when direction is down" do
      before { snake.direction = "down" }

      it "moves one square down" do
        old_position = snake.positions.dup.freeze # dup.freeze to prevent mutation of old_position by #move method
        snake.move
        new_position = snake.positions.dup.freeze # dup.freeze to prevent mutation of new_position by #move method
        expect(new_position[0][0]).to eq(old_position[0][0])
        expect(new_position[0][1]).to eq(old_position[0][1] + SNAKE_SIZE)
        expect(new_position[1]).to eq(old_position[0..-2])
        expect(new_position.length).to eq(old_position.length)
       end
     end
   end

   describe '#snake_growth' do
     it "adds one square to the tail of the snake" do
       old_length = snake.positions.length
       old_tail_x = snake.positions.last.first
       old_tail_y = snake.positions.last.last
       snake.snake_growth
       new_length = snake.positions.length
       new_tail_x = snake.positions.last.first
       new_tail_y = snake.positions.last.last
       expect(new_length - old_length).to eq(1)
       expect(new_tail_x - old_tail_x).to eq(SNAKE_SIZE)
       expect(new_tail_y - old_tail_y).to eq(0)
     end
   end

   describe '#hit_itself?' do
     context "when the head of the snake collides with its body" do
       before { snake.positions << [snake.x + SNAKE_SIZE, snake.y] }

       it "returns true" do
         expect(snake.hit_itself?).to be(true)
       end
     end

     context "when the head of the snake does not collide with its body" do
       it "returns false" do
         expect(snake.hit_itself?).to be(false)
       end
     end
   end

   describe '#opposite_direction?' do
     context "when given direction is opposite of current direction" do
       before { snake.direction = "right" }

       it "returns true" do
         expect(snake.opposite_direction?("left")).to be(true)
       end
     end
    end
end
