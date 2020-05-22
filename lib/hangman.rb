module Dictionary
    def dictionary
        File.read("../dictionary.txt")
    end
end

class Computer
    include Dictionary
    attr_reader :word

    def initialize(letters="", word=get_random_word)
        @letters = letters
        @word = word
    end

    def get_random_word
        medium_words = dictionary.split.select do |word|
            word.length >=5 && word.length <= 12
        end
        
        medium_words.sample.downcase
    end

    def get_matching_letters(letter)
        @word.count(letter).times do
            @letters += letter
        end
    end

    def secret_word(guesses)
        secret_word = @word.split("")
        secret_word.map do |letter|
            if !guesses.include?(letter)
                letter = "_"
            else
                letter
            end
        end.join(" ")
    end
end

class Player
    attr_reader :guesses

    def initialize(guesses="")
        @guesses = guesses
    end

    def get_guess
        puts "\n"
        puts "Please guess a letter:"
        guess = gets.chomp.downcase
        guess = ensure_valid_guess(guess)
        guess = ensure_new_guess(guess)
        

        @guesses += guess
        guess
    end


    private

    def already_guessed?(letter)
        @guesses.include?(letter)
    end

    def ensure_new_guess(guess)
        while already_guessed?(guess)
            puts "\n"
            puts "You have already guessed #{guess}."
            puts "Please choose another letter:"
            guess = ensure_valid_guess(gets.chomp.downcase)
        end

        guess
    end

    def ensure_valid_guess(guess)
        until guess.match?(/^\w$/)
            guess_error
            guess = ensure_new_guess(gets.chomp.downcase)
        end

        guess
    end

    def guess_error
        puts "\n"
        puts "Your guess must be a single letter. E.g. \'a\'."
        puts "Please choose another letter:"
    end

end

class Game
    def initialize(player, computer, guesses_left=15)
        @player = player
        @computer = computer
        @guesses_left = guesses_left
    end

    def play
        computer_chose_word_message
        puts "\n"
        while true
            get_incorrect_guesses
            guess = @player.get_guess
            puts "\n"
            matching_letters_message(@computer.word, guess)
            puts @computer.secret_word(@player.guesses)
            puts "\n"
            remaining_guesses

            if game_over?
                if guessed_word?
                    victory_message
                    return
                end

                if out_of_guesses?
                    defeat_message
                    return
                end
            end


            @guesses_left -= 1
        end
    end

   private

    def matching_letters_message(word, guess)
        if word.include?(guess)
            letter_count = word.count(guess)
            puts "There are #{letter_count} #{guess}\'s in the Computer\'s word."
        else
            puts "There aren\'t any #{guess}\'s in the Computer\'s word."
        end
    end

    def get_incorrect_guesses
        if @player.guesses.empty?
            puts "You have not made any guesses so far."
            return
        end

        incorrect_guesses = []
        @player.guesses.split("").each do |letter|
            incorrect_guesses.push(letter) if !@computer.word.include?(letter)
        end

        if incorrect_guesses.empty?
            puts "You have no incorrect guesses so far."
            return
        end

        puts "Your previous incorrect guesses are:"
        puts "#{incorrect_guesses.join(", ")}."
    end
    
    def victory_message
        puts "\n"
        puts "Congrats! You guessed the Computer\'s word:"
        puts "#{@computer.word}"
    end

    def defeat_message
        puts "\n"
        puts "Sorry! You didn't guess the Computer\'s word:"
        puts "#{@computer.word}"
    end

    def game_over?
        out_of_guesses? || guessed_word? ? true : false
    end

    def out_of_guesses?
        @guesses_left <= 0
    end

    def guessed_word?
        @player.guesses.split("").sort == @computer.word.split("").sort
    end

    def computer_chose_word_message
        puts "The Computer has chosen a random word."
    end

    def remaining_guesses
        puts "You have #{@guesses_left} guesses remaining."
    end
    
end


player = Player.new
computer = Computer.new
game = Game.new(player, computer)
game.play
