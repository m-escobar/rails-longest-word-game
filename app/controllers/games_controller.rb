require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = generate_grid(3 + rand(10))
    @grid_str = @grid.join
    @start_time = Time.now
  end

  def score
    attempt = params[:word]
    grid = params[:grid]
    start_time = params[:stime].to_time
    end_time = Time.now
    @result = run_game(attempt,grid, start_time, end_time)
  end
end


def generate_grid(grid_size)
  # TODO: generate random grid of letters
  letters = ('A'..'Z').to_a

  grid_size > letters.length ? size = letters.length : size = grid_size
  grid_size > letters.length ? extra = grid_size - letters.length : extra = 0

  grid = letters.sample(size)
  grid.concat(letters.sample(extra)) if extra.positive?
  return grid
end


def run_game(attempt, grid, start_time, end_time)
  grid = grid.split('').map { |x| x.downcase! }
  check = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{attempt.downcase}").read)
  time = (end_time - start_time).round
  
  if check["found"] == true && attempt.split("").all? { |e| attempt.count(e) <= grid.count(e) }
    # message = "Well Done!"
    # score = ((check["length"] * 100) - ((end_time - start_time) * 10)).round
    return { time: time, score: ((check["length"] * 100) - (time * 10)).round, message: "Well Done!" }

  elsif !attempt.split("").all? { |e| attempt.count(e) <= grid.count(e) }
    return { time: time, score: 0, message: "the given word is not in the grid" }

  elsif check["found"] == false
    return { time: time, score: 0, message: "This is not an english word" }
  end
end
