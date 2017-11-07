require 'byebug'
require 'map'
require 'space'

class Player
  def initialize
    @all_actions_executed = false
  end

  def play_turn(warrior)
    create_map(warrior)
    @map.bind_enemy unless @map.all_enemies_bound?

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

  def create_map(warrior)
    @map = Map.new(warrior)
  end

  # return true if it executed some action, otherwise retuns false
  # def execute_near_actions(warrior)
  #   unless @all_actions_executed
  #     [:forward, :left, :right, :backward].each do |direction|
  #       if warrior.feel(direction).enemy?
  #         warrior.bind!(direction)
  #         return true
  #       end
  #     end
  #     @all_actions_executed = true
  #   end
  #   false
  # end
end
