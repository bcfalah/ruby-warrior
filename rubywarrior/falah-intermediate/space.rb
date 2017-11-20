class Space
  attr_accessor :unit_type, :status, :direction, :distance

  def initialize(attrs)
    @space = attrs[:space]
    @direction = attrs[:direction]
    @distance = attrs[:distance]

    if @space.enemy?
      @unit_type = :enemy
      @status = :free
    elsif @space.captive?
      @unit_type = :hostage
      @status = :captive
    end
  end

  def self.build(space, warrior)
    attributes = custom_attrs(space, warrior)
    Space.new({ space: space }.merge(attributes))
  end

  def self.update(custom_space, basic_space, warrior)
    attibutes = custom_attrs(basic_space, warrior)
    custom_space.direction = attibutes[:direction]
    custom_space.distance = attibutes[:distance]

    if custom_space.has_a?(:enemy)
      custom_space.status = basic_space.enemy? ? :free : :captive
    elsif custom_space.has_a?(:hostage)
      custom_space.status = :captive
    end
  end

  def has?(options)
    options.all? do |key, value|
      respond_to?(key) ? eval_value(key, value) : @space.send(key)
    end
  end

  def eval_value(key, value)
    if key == :distance
      value.include? send(key)
    else
      send(key) == value
    end
  end

  def free_enemy?
    has_a?(:enemy) && status == :free
  end

  def has_a?(unit_type)
    @unit_type == unit_type
  end

  def direction?(direction)
    # check only if direction given
    direction ? @direction == direction : true
  end

  def location
    @space.location
  end

  def status?(status)
    @status == status
  end

  private

  def self.custom_attrs(space, warrior)
    direction = warrior.direction_of(space)
    distance = warrior.distance_of(space)
    { direction: direction, distance: distance }
  end
end
