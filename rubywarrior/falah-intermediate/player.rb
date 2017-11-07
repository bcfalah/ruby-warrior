require 'byebug'

class Player
  @all_enemies_bound = false

  def play_turn(warrior)
    if !bind_near_enemies(warrior)
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

  def bind_near_enemies(warrior)
    unless @all_enemies_bound
      [:forward, :left, :right, :backward].each do |direction|
        if warrior.feel(direction).enemy?
          warrior.bind!(direction)
          return true
        end
      end
      @all_enemies_bound = true
    end
    false
  end
end
