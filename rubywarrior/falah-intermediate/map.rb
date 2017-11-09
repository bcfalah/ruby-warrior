class Map
  attr_reader :enemies_count

  def populate(warrior)
    spaces_with_units = warrior.listen
    @enemies_count ||= warrior.listen.count(&:enemy?)
    @enemies_bound_count ||= 0
    @all_spaces = []
    @near_spaces = []

    spaces_with_units.each do |space_with_unit|
      direction = warrior.direction_of(space_with_unit)
      custom_space = Space.new(space: space_with_unit, direction: direction)
      @all_spaces << custom_space
    end
  end

  # bind a near enemy unless is the only one that is free
  def bind_near_enemy(warrior)
    if (near_enemies.count > 1)
      direction = near_enemies.first.direction
      warrior.bind!(direction)
      @enemies_bound_count += 1
      direction
    end
  end

  def go_for_extra_points(warrior)
    position = warrior.location
    nearer_enemy(position)
    nearer_hostage(position)
    if (all_enemies.count > 0)
      direction = near_enemy_direction
      warrior.bind!(direction)
      @enemies_bound_count += 1
      direction
    end
  end

  private

  def all_enemies
    @all_spaces.select { |space| space.has_a?(:enemy) }
  end

  def near_enemies(warrior)
    all_enemies.select do |space|
      direction = warrior.direction_of(space)
      near_space = warrior.feel(direction)
      space.location == near_space.location
    end
  end

  def nearer_enemy(location)
    all_enemies.select do |space|
      near_space.location
    end
  end

  def nearer_hostage(position)
  end

  def hostages
    @all_spaces.select { |space| space.has_a?(:hostage) }
  end
  # def near_enemy
  #   near_enemies.find { |space| space.has_a?(:enemy) }
  # end

  def an_enemy
    near_enemies.find { |space| space.has_a?(:enemy) }
  end
end
