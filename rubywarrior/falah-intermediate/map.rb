class Map
  attr_reader :enemies_count

  def populate(warrior)
    spaces_with_units = warrior.listen
    @enemies_count ||= warrior.listen.count(&:enemy?)
    @enemies_bound_count ||= 0
    @near_spaces = []

    spaces_with_units.each do |space_with_unit|
      direction = warrior.direction_of(space_with_unit)
      near_space = warrior.feel(direction)
      if (space_with_unit.location == near_space.location)
        @near_spaces << Space.new(space: space_with_unit, direction: direction)
      end
    end
  end

  # bind a near enemy unless is the only one that is free
  def bind_near_enemy(warrior)
    if (near_enemies.count > 1) && (direction = near_enemy_direction)
      warrior.bind!(direction)
      @enemies_bound_count += 1
      direction
    end
  end

  private

  def near_enemies
    @near_spaces.select { |space| space.has_a?(:enemy) }
  end

  def near_enemy_direction
    near_enemy ? near_enemy.direction : nil
  end

  def near_enemy
    near_enemies.find { |space| space.has_a?(:enemy) }
  end
end
