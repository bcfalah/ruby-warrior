class Player
  def play_turn(warrior)
    stairs_direction = warrior.direction_of_stairs
    if warrior.feel(stairs_direction).enemy?
      warrior.attack!(stairs_direction)
    else
      warrior.walk!(stairs_direction)
    end
  end
end
