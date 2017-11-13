class Map
  attr_reader :enemies_count

  def populate(warrior)
    @warrior = warrior
    @max_health ||= @warrior.health
    @current_healh = @warrior.health

    spaces_with_units = @warrior.listen
    @all_spaces = []

    spaces_with_units.each do |space_with_unit|
      direction = warrior.direction_of(space_with_unit)
      custom_space = Space.new(space: space_with_unit, direction: direction)
      @all_spaces << custom_space
    end
  end

  # this method should only handle prioritized actions (actions to do for
  # achieving a prioritized action (for now a ticking hostage))
  def execute_prioritized_action
    direction = next_prioritazed_direction
    direction_actions(direction) if direction
  end

  def execute_extra_points_action
    if @all_spaces.any?
      rest_until_healthy || direction_actions(@all_spaces.first.direction)
    end
  end

  def direction_actions(direction)
    if near_spaces_with(unit_type: :enemy, direction: direction).any?
      # handle interfering enemy
      # bind a near enemy unless is the only one that is free
      if near_spaces_with(unit_type: :enemy).count > 1
        bind_enemy
      else
        attack_enemy
      end
    elsif near_spaces_with(unit_type: :hostage, direction: direction).any?
      # rescue interfering hostage
      rescue_hostage
    elsif @warrior.feel(direction).empty?
      @warrior.walk!(direction)
    end
  end

  def next_prioritazed_direction
    if (space = spaces_with_priority.first)
      space.direction
    end
  end

  def rest_until_healthy
    @warrior.rest! unless under_atack? || @warrior.health == @max_health
  end

  def under_atack?
    near_spaces_with(unit_type: :enemy).any?
  end

  private

  def spaces_with(options)
    @all_spaces.select do |space|
      space.has?(options)
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

  def spaces_with_priority
    spaces_with(ticking?: true)
  end
end
