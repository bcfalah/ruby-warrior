require 'byebug'
require 'map'
require 'space'

class Player
  def initialize
    @all_actions_executed = false
    @map = Map.new
  end

  def play_turn(warrior)
    byebug
    @map.populate(warrior)
    if !bind_near_enemy(warrior)
      return if go_for_extra_points(warrior)
      # TODO rescue close captives first
      stairs_direction = warrior.direction_of_stairs
      # TODO see why I cannot use a case with the space returned by warrior.feel(stairs_direction)
      if warrior.feel(stairs_direction).captive?
        warrior.rescue!(stairs_direction)
      elsif warrior.feel(stairs_direction).enemy?
        warrior.attack!(stairs_direction)
      else
        warrior.walk!(stairs_direction)
      end
    end
  end

  def bind_near_enemy(warrior)
    @map.bind_near_enemy(warrior)
  end

  def go_for_extra_points(warrior)
    @map.go_for_extra_points(warrior)
  end
end
