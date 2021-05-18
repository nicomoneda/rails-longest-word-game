require "open-uri"

class GamesController < ApplicationController

  def new
    char_gen = Array('A'..'Z')
    @letters = Array.new(10) { char_gen.sample }
    @start_time = Time.now
    session[:start_time] = @start_time
  end
  
  def score
    @result = Hash.new(0)
    @end_time = Time.now
    params[:attempt].upcase!
    @result[:time] = @end_time - session[:start_time].to_time
  
    @letters = params[:letters].split(' ') # join, etc
    if comparison_word_grid(params[:attempt], @letters) == true
      @result.merge!(logic_game(params[:attempt], @result[:time]))
    else
      @result[:score] = 0
      @result[:message] = "One or some letters are not in the grid"
    end
    @result
  end

  private

  def real_word?(word)
    # Method to know if the word exist or not
    url = "https://wagon-dictionary.herokuapp.com/#{word.downcase}"
    word_serialized = URI.open(url).read
    word_info = JSON.parse(word_serialized)
    return word_info["found"]
  end

  def comparison_word_grid(attempt, grid)
    # Method to compare the word attempted to the grid
    attempt.chars.all? { |letter|  attempt.count(letter) <= grid.count(letter) }
  end
  
  def calcul_score(attempt, time)
    # Method to compute the score
    size_word = attempt.size
    final_score = size_word - time
    return final_score
  end
  
  def logic_game(attempt, time)
    result_game = Hash.new(0)
    if real_word?(attempt) == true
      result_game[:score] = calcul_score(attempt, time)
      result_game[:message] = "Perfection ! Well done"
    else
      result_game[:score] = 0
      result_game[:message] = "It's not an english word"
    end
    # if result_game[:score] < 0
    #   result_game[:score] = 0
    #   result_game[:message] = "You were too slow"
    # end
    return result_game
  end

end
