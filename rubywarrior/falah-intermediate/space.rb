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

  def has?(options)
    options.all? do |key, value|
      respond_to?(key) ? send(key) == value : @space.send(key)
    end
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
end
