class Map
  attr_reader :enemies_count

  def populate(warrior)
    @warrior = warrior
    spaces_with_units = @warrior.listen
    @all_spaces = []

    spaces_with_units.each do |space_with_unit|
      direction = warrior.direction_of(space_with_unit)
      custom_space = Space.new(space: space_with_unit, direction: direction)
      @all_spaces << custom_space
    end
  end

  def execute_prioritized_action
    # bind a near enemy unless is the only one that is free
    if (near_enemy = near_spaces_with(:enemy).first) && interferes_with_next_action?(near_enemy)
      #bind_enemy
      attack_enemy
    elsif (near_hostage = near_spaces_with(:hostage).first) && interferes_with_next_action?(near_hostage)#near_spaces_with(:hostage).any?
      rescue_hostage
    end
  end

  def go_for_extra_points
    if hostage_space = spaces_by_priority(:hostage).first
      direction = hostage_space.direction
      @warrior.walk!(direction)
    end
  end

  def next_prioritazed_direction
    if hostage_space = spaces_by_priority(:hostage).first
      hostage_space.direction
    elsif enemy_space = spaces_by_priority(:enemy).first
      enemy_space.direction
    else
      @warrior.direction_of_stairs
    end
  end

  private

  def spaces_with(unit_type)
    @all_spaces.select { |space| space.has_a?(unit_type) }
  end

  def near_spaces_with(unit_type)
    spaces_with(unit_type).select do |space|
      near_space = @warrior.feel(space.direction)
      space.location == near_space.location
    end
  end

  def bind_enemy
    @warrior.bind! direction_of_nearer_space_with(:enemy)
  end

  def attack_enemy
    @warrior.attack! direction_of_nearer_space_with(:enemy)
  end

  def rescue_hostage
    @warrior.rescue! direction_of_nearer_space_with(:hostage)
  end

  def direction_of_nearer_space_with(unit_type)
    near_spaces_with(unit_type).first.direction
  end

  def interferes_with_next_action?(space)
    space.direction == next_prioritazed_direction
  end

  def spaces_by_priority(unit_type)
    case unit_type
    when :hostage
      spaces_with(:hostage).sort { |s| s.ticking? ? 0 : 1 }
    when :enemy
      spaces_with(:enemy)
    end
  end
end
