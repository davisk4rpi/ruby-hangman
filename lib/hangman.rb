class Hangman

	def initialize
		introduction
	end

	def new_game
		@guesses_left = 6
		@word = generate_word
		@correct_guesses = []
		@incorrect_guesses = []
		@guess_so_far = []
		starting_template(@word.length)
		gameplay
	end

	def gameplay
		puts "\n#{@guesses_left} mistakes left."
		puts "Incorrect letters so far: #{@incorrect_guesses.join(" ")}"
		puts "#{@guess_so_far.join(" ")}"
		puts @word
		pick_a_letter
	end

	def introduction
		puts "Welcome to Hangman!\n\nType 1 to start a new game or 2 to load a saved game.\nAnything else will close the program."
		selection = gets.chomp
		case selection
		when '1' then new_game
		when '2' then saved_game
		else 
			exit
		end
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

	def pick_a_letter
		puts "\nPlease choose a letter"
		guess = gets.chomp.downcase
		puts ''
		bad_guess unless guess.match(/^[a-z]$/)
		second_guessing(guess) if (@correct_guesses + @incorrect_guesses).include? guess
		correct_letter(guess) if @word.scan(/./).include? guess
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
		puts "LOSER!"
		play_again?
	end

	def play_again?
		puts "Would you like to start over? (y to start over, anything else to exit)"
		exit unless gets.chomp == "y"
		introduction
	end

end

Hangman.new