class Map
  # based on how much damages a detonation
  MINIMUM_HEALTH = 5

  def populate(warrior)
    @warrior = warrior
    @max_health ||= @warrior.health

    spaces_with_units = @warrior.listen
    @all_spaces = []

    spaces_with_units.each do |space_with_unit|
      direction = @warrior.direction_of(space_with_unit)
      distance = @warrior.distance_of(space_with_unit)
      custom_space = Space.new(space: space_with_unit, direction: direction,
        distance: distance)
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
    # evaluate if it is better to fo to stairs
    if @all_spaces.any?
      rest_until_healthy || direction_actions(@all_spaces.first.direction)
    end
  end

  def direction_actions(direction)
    enemies_actions(direction) || hostages_actions(direction) ||
      walk_actions(direction)
  end

  def enemies_actions(ahead_direction)
    space_ahead = @warrior.feel(ahead_direction)
    if !space_ahead.empty?
      if near_spaces_with(unit_type: :enemy).count > 1
        bind_side_enemy(ahead_direction)
        #bind_enemy
      elsif space_ahead.enemy?
        attack_enemy(ahead_direction)
      end
    else
      far_enemies_actions(ahead_direction)
    end
  end

  def hostages_actions(direction)
    if near_spaces_with(unit_type: :hostage, direction: direction).any?
      rescue_hostage
    end
  end

  def walk_actions(direction)
    @warrior.walk!(direction) if @warrior.feel(direction).empty?
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
    spaces_with(options.merge(distance: 1))
  end

  def bind_side_enemy(direction)
    side_space = near_spaces_with(unit_type: :enemy).find do |space|
      space.direction != direction
    end
    @warrior.bind! side_space.direction
  end

  def bind_enemy
    @warrior.bind! direction_of_nearer_space_with(:enemy)
  end

  def attack_enemy(direction)
    if !hostages_in_detonation_ratio?
      detonation_actions(direction)
    else
      @warrior.attack!(direction)
    end
  end

  def far_enemies_actions(direction)
    if should_detonate?(direction)
      detonation_actions(direction)
    end
  end

  def should_detonate?(direction)
    # TODO considere using spaces_with
    # look for enemies in the radio of detonation
    enemies_ahead = @warrior.look(direction).select { |s| s.enemy? && @warrior.distance_of(s) <= 2 }
    #enemies_ahead.any?
    !hostages_in_detonation_ratio? && enemies_ahead.count > 1
  end

  def hostages_in_detonation_ratio?
    spaces_with(unit_type: :hostage).select { |s| @warrior.distance_of(s) <= 2 }.any?
  end

  def detonation_actions(direction)
    if @warrior.health < MINIMUM_HEALTH
      # enemies could be further
      if @warrior.feel(direction).enemy?
        @warrior.bind!(direction)
      else
        @warrior.rest!
      end
    else
      @warrior.detonate!(direction)
    end
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
