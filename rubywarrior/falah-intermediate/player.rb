require 'byebug'
require 'map'
require 'space'

class Player
  def initialize
    @map = Map.new
  end

  def play_turn(warrior)
    @map.populate(warrior)
    if !execute_prioritized_action
      if !execute_extra_points_action
        warrior.walk!(warrior.direction_of_stairs)
      end
    end
  end

  def execute_prioritized_action
    @map.execute_prioritized_action
  end

  def execute_extra_points_action
    @map.execute_extra_points_action
  end
end
