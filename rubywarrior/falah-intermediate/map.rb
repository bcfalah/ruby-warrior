class Map
  # based on how much damages a detonation
  MINIMUM_HEALTH = 5

  def populate(warrior)
    @warrior = warrior
    @max_health ||= @warrior.health

    spaces_with_units = @warrior.listen
    @all_spaces ||= []

    spaces_with_units.each do |space_with_unit|
      if (custom_space = spaces_with(location: space_with_unit.location).first)
        Space.update(custom_space, space_with_unit, warrior)
      else
        custom_space = Space.build(space_with_unit, warrior)
        @all_spaces << custom_space
      end
    end

    delete_old_spaces(spaces_with_units)
  end

  # this method should only handle prioritized actions (actions to do for
  # achieving a prioritized action (for now a ticking hostage))
  def execute_prioritized_action
    direction = next_prioritazed_direction
    direction_actions(direction) if direction
  end

  def execute_extra_points_action
    # evaluate if it is better to go to stairs
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
    custom_space = get_custom_space(space_ahead)

    if !space_ahead.empty?
      if near_spaces_with(unit_type: :enemy, status: :free).count > 1
        bind_side_enemy(ahead_direction)
        #bind_enemy
      elsif custom_space.free_enemy?
        attack_enemy(ahead_direction)
      end
    else
      far_enemies_actions(ahead_direction)
    end
  end

  def hostages_actions(direction)
    if near_spaces_with(status: :captive, direction: direction).any?
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
    near_spaces_with(unit_type: :enemy, status: :free).any?
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
    side_space = near_spaces_with(unit_type: :enemy, status: :free).find do |space|
      space.direction != direction
    end
    @warrior.bind! side_space.direction
  end

  def bind_enemy
    @warrior.bind! nearer_space_with(:enemy).direction
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
    enemies_ahead = @warrior.look(direction).select { |s| s.enemy? && @warrior.distance_of(s) <= 2 }
    # I cannot do this in a better way, the best would be to have a way to know how many enemies will be damaged
    !hostages_in_detonation_ratio? && enemies_ahead.any? && enemies_in_detonation_ratio?
  end

  def hostages_in_detonation_ratio?
    spaces_with(unit_type: :hostage).select { |s| @warrior.distance_of(s) <= 2 }.any?
  end

  def enemies_in_detonation_ratio?
    spaces_with(unit_type: :enemy, status: :free).select { |s| @warrior.distance_of(s) <= 2 }.any?
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
    hostage_space = near_spaces_with(status: :captive).first
    @warrior.rescue! hostage_space.direction
  end

  def nearer_space_with(unit_type)
    near_spaces_with(unit_type: unit_type).first
  end

  def spaces_with_priority
    spaces_with(ticking?: true)
  end

  def get_custom_space(space)
    spaces_with(location: space.location).first
  end

  def delete_old_spaces(new_spaces)
    locations = new_spaces.map(&:location)
    @all_spaces.delete_if { |space| !locations.include?(space.location) }
  end
end
