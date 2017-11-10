class Map
  attr_reader :enemies_count

  def populate(warrior)
    @warrior = warrior
    @max_health ||= @warrior.health
    spaces_with_units = @warrior.listen
    @all_spaces = []

    spaces_with_units.each do |space_with_unit|
      direction = warrior.direction_of(space_with_unit)
      custom_space = Space.new(space: space_with_unit, direction: direction)
      @all_spaces << custom_space
    end
  end

  # TODO this method should only handle prioritized actions (actions to do for
  # achieving a prioritized action (for now a ticking hostage))
  def execute_prioritized_action
    # bind a near enemy unless is the only one that is free
    direction = next_prioritazed_direction
    if near_spaces_with(unit_type: :enemy, direction: direction).any?# && interferes_with_next_action?(near_enemy)
      # handle interfering enemy
      if near_spaces_with(unit_type: :enemy).count > 1
        bind_enemy
      else
        attack_enemy
      end
    elsif near_spaces_with(unit_type: :hostage, direction: direction).any?# && interferes_with_next_action?(near_hostage)
      # rescue interfering hostage
      rescue_hostage
    elsif @warrior.feel(direction).empty?
      # if lacks ticking sludges
      @warrior.walk!(direction)
    else
      rest_until_healthy
    end
  end

  # def go_for_extra_points
  #   extra_points_space = spaces_by_priority(:hostage).first || spaces_by_priority(:enemy).first
  #   direction = extra_points_space ? extra_points_space.direction : @warrior.direction_of_stairs
  #   @warrior.walk!(direction)
  # end

  def next_prioritazed_direction
    if hostage_space = spaces_by_priority(:hostage).first
      hostage_space.direction
    elsif enemy_space = spaces_by_priority(:enemy).first
      enemy_space.direction
    else
      @warrior.direction_of_stairs
    end
  end

  def rest_until_healthy
    @warrior.rest! unless @warrior.health == @max_health
  end

  private

  def spaces_with(options)
    @all_spaces.select do |space|
      space.has_a?(options[:unit_type]) && space.direction?(options[:direction])
    end
  end

  def near_spaces_with(options)
    spaces_with(options).select do |space|
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
    near_spaces_with(unit_type: unit_type).first.direction
  end

  def interferes_with_next_action?(space)
    space.direction == next_prioritazed_direction
  end

  def spaces_by_priority(unit_type)
    case unit_type
    when :hostage
      spaces_with(unit_type: :hostage).sort { |s| s.ticking? ? 0 : 1 }
    when :enemy
      spaces_with(unit_type: :enemy)
    end
  end
end
