require 'csv'

class Cookbook
  def initialize(csv_file_path)
    @recipes = []
    CSV.read(csv_file_path).each do |recipe|
      @recipes << Recipe.new(recipe[0], recipe[1], recipe[2], recipe[3])
    end
    @csv_file = csv_file_path
  end

  # returning all recipes
  def all
    @recipes
  end

  # add recipe
  def add_recipe(recipe)
    @recipes << recipe
    CSV.open(@csv_file, 'wb') do |csv|
      @recipes.each { |element| csv << [element.name, element.description, element.time, element.difficulty] }
    end
  end

  # remove recipe
  def remove_recipe(recipe_index)
    @recipes.delete_at(recipe_index)
    CSV.open(@csv_file, 'wb') do |csv|
      @recipes.each { |element| csv << [element.name, element.description, element.time, element.difficulty] }
    end
  end
end
