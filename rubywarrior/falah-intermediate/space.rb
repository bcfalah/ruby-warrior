class Space
  attr_accessor :unit_type, :status, :direction

  def initialize(space)
    #@space = space
    if space.enemy?
      @unit_type = :enemy
      @status = :free
    elsif space.captive?
      @unit_type = :hostage
      @status = :captive
    end
  end

  def has_a?(unit_type)
    @unit_type == unit_type
  end

  def status?(status)
    @status == status
  end

  def bind
    @status = :bound
  end
end
