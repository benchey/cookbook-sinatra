require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require_relative "cookbook"
require_relative "recipe"
require 'nokogiri'
require 'open-uri'

set :bind, '0.0.0.0'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end


get '/' do
  csv_file = File.join(__dir__, 'recipes.csv')
  @cookbook = Cookbook.new(csv_file)
  erb :index
end

get '/about' do
  erb :about
end

get '/team/:username' do
  puts params[:username]
  "The username is #{params[:username]}"
end

get '/new' do
  erb :new
end

post '/recipes' do
  recipe = create(params[:name], params[:description], params[:time], params[:difficulty])
  erb :index
end

get '/delete/:index' do
  csv_file = File.join(__dir__, 'recipes.csv')
  @cookbook = Cookbook.new(csv_file)
  @cookbook.remove_recipe(params[:index].to_i - 1)
  erb :index
end

get '/recipes/:index' do
  csv_file = File.join(__dir__, 'recipes.csv')
  @cookbook = Cookbook.new(csv_file)
  @recipe = @cookbook.all[params[:index].to_i - 1]
  erb :recipe
end

get '/scrape' do
  erb :scrape
end

post '/scrape' do
  keyword = params[:keyword]
  file = open("https://www.marmiton.org/recettes/recherche.aspx?aqt=#{keyword}").read
  doc = Nokogiri::HTML(file)
  names = []
  links = []
  @search_results = []
  doc.search(".recipe-card__title").each { |element| names << element.text }
  doc.search(".recipe-card").each { |e| links << "https://www.marmiton.org" + e.attributes['href'] }
  names.each_with_index { |name, i| @search_results << [name, links[i]] }
  erb :scrape
end

get '/import_from_marmitton' do
  file = open(params[:url]).read
  doc = Nokogiri::HTML(file)
  description = ""
  name = doc.search(".main-title").text
  description = doc.css(".recipe-preparation__list__item").each { |step| description += step.text.gsub("\t", "").gsub("\n", "").gsub("\r", "") + "\n" }
  time = doc.search(".recipe-infos__timmings__total-time span").text
  difficulty = doc.search(".recipe-infos__level span").text
  create(name, description, time, difficulty)
  erb :index
end

def create(name, description, time, difficulty)
  recipe = Recipe.new(name, description, time, difficulty)
  csv_file = File.join(__dir__, 'recipes.csv')
  @cookbook = Cookbook.new(csv_file)
  @cookbook.add_recipe(recipe)
end
