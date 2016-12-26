require "csv"

class Hangman

	def initialize
		system "clear" or system "cls"
		introduction
	end

	def introduction
		puts "Welcome to Hangman!\n\nType 1 to start a new game or 2 to load a saved game.\nAnything else will close the program."
		selection = gets.chomp
		case selection
		when '1' then new_game
		when '2' then find_saved_game
		else 
			exit
		end
	end

	#This section includes methods exclusive to brand new games
	def new_game
		@guesses_left = 6
		@word = generate_word
		@correct_guesses = []
		@incorrect_guesses = []
		@guess_so_far = []
		starting_template(@word.length)
		gameplay
	end

	def generate_word
		dictionary = File.open("5desk.txt", 'r').readlines
		random_word_index = rand(dictionary.length) + 1
		word = dictionary[random_word_index].strip.downcase
		return word if (4 < word.length && word.length < 13)
		generate_word
	end

	def starting_template (n)
		n.times {@guess_so_far << "_"}
	end

	#This section includes methods exclusive to loading saved games
	def saved_game
		@guesses_left = @game[:guesses_left].to_i
		@word = @game[:word]
		@correct_guesses = @game[:correct_guesses].chars
		@incorrect_guesses = @game[:incorrect_guesses].chars
		@guess_so_far = @game[:guess_so_far].chars
		gameplay
	end

	def find_saved_game
		puts "#, Name, Guess So Far, Guesses Left"
		saved_games = CSV.read("saved_games/saved_games.csv", headers: true, header_converters: :symbol)
		saved_games.each do |row|
			id = row [0]
			puts "#{id}: #{row[:name]}  #{row[:guess_so_far]}  #{row[:guesses_left]}"
		end
		puts "Type the number of the game you would like to play."
		game_id = gets.chomp.to_i
		unless game_id == 0 || saved_games[(game_id - 1)].nil?
			@game = saved_games[(game_id - 1)]
		else
			puts "Please choose a number from the list"
			find_saved_game
		end
		saved_game
	end

	def gameplay
		puts "\n#{@guesses_left} mistakes left."
		puts "Incorrect letters so far: #{@incorrect_guesses.join(" ")}"
		puts "#{@guess_so_far.join(" ")}"
		pick_a_letter
	end

	def save_game
		puts "What would you like to name your saved game?"
		name = gets.chomp
		id = IO.readlines('saved_games/saved_games.csv').size
		saved_games = CSV.open("saved_games/saved_games.csv", "a", headers: true, header_converters: :symbol)
		@game = [id, name, @word, @guess_so_far.join, @guesses_left, @correct_guesses.join, @incorrect_guesses.join]
		#saved_games.generate_line(@game)
		saved_games.puts @game
		puts "SAVED!"
		puts @game[1]
		puts "Come again soon!"
		exit
	end

	#This section includes all methods shared by both new and saved games
	def pick_a_letter
		puts "\nPlease choose a letter or type 1 to save your current game and exit."
		guess = gets.chomp
		puts ''
		bad_guess unless guess.match(/^[A-z1]$/)
		guess.downcase! unless guess == "1"
		second_guessing(guess) if (@correct_guesses + @incorrect_guesses).include? guess
		correct_letter(guess) if @word.chars.include? guess
		save_game if guess == "1"
		incorrect_letter(guess)

	end

	def bad_guess
		puts "Please enter only single letters at a time from a-z!"
		pick_a_letter
	end

	def second_guessing(guess)
		puts "Why would you guess #{guess} again? Try again!"
		pick_a_letter
	end

	def correct_letter(char)
		puts "Good choice!"
		@correct_guesses << char
		letter_index = 0
		@word.each_char do |ch|
			if ch == char
				@guess_so_far[letter_index] = char
			end
			letter_index += 1
		end
		unless @guess_so_far.include? "_"
			return game_over_win
		end
		gameplay
	end

	def incorrect_letter(char)
		@incorrect_guesses << char
		@guesses_left > 1 ? @guesses_left -= 1 : game_over_lose
		puts "Well I guess sombody hasn't been studying their vocab"
		gameplay
	end

	def game_over_win
		puts "You Win! The word was #{@word}\n\nGood Job I guess. Its only a children's game after all"
		play_again?
	end

	def game_over_lose
		puts "LOSER! The word was #{@word}"
		play_again?
	end

	def play_again?
		puts "Would you like to start over? (y to start over, anything else to exit)"
		exit unless gets.chomp == "y"
		introduction
	end

end

Hangman.new