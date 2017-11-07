class Map
  attr_accessor :spaces

  def initialize(warrior)
    @spaces = []
    spaces_with_units = warrior.listen

    spaces_with_units.each do |space_with_unit|
      space = Space.new(space_with_unit)
      space.direction = warrior.direction_of(space_with_unit)
      @spaces << space
    end
  end

  def bind_enemy(warrior)
    warrior.bind!(direction)
    enemies_bound.first
  end

  def all_enemies_bound?
    enemies_bound.empty?
  end

  private

  def enemies
    @spaces.select { |space| space.has_a?(:enemy) }
  end

  def enemies_bound
    enemies.select { |e| e.status?(:bound) }
  end
end
