class Recipe
  attr_reader :name, :description, :time, :difficulty
  def initialize(name, description, time, difficulty)
    @name = name
    @description = description
    @time = time
    @difficulty = difficulty
    @done = false
  end

  def done?
    @done
  end

  def mark_as_done!
    @done = true
  end
end
