require 'byebug'
require 'map'
require 'space'

class Player
  def initialize
    @all_actions_executed = false
    @map = Map.new
  end

  def play_turn(warrior)
    @map.populate(warrior)
    if !execute_prioritized_action
      #return if go_for_extra_points
      stairs_direction = warrior.direction_of_stairs
      if warrior.feel(stairs_direction).captive?
        warrior.rescue!(stairs_direction)
      elsif warrior.feel(stairs_direction).enemy?
        warrior.attack!(stairs_direction)
      else
        warrior.walk!(stairs_direction)
      end
    end
  end

  def execute_prioritized_action
    @map.execute_prioritized_action
  end

  def go_for_extra_points
    @map.go_for_extra_points
  end
end
