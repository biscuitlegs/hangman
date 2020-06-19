require 'yaml'

module Dictionary
    def dictionary
        File.read("dictionary.txt")
    end
end

class Computer
    include Dictionary
    attr_reader :word

    def initialize(word=get_random_word)
        @word = word
    end

    def get_random_word
        medium_words = dictionary.split.select do |word|
            word.length >=5 && word.length <= 12
        end
        
        medium_words.sample.downcase
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

    def get_input
        puts "\n"
        puts "Please guess a letter or enter \'save\' to save your game:"
        input = gets.chomp.downcase

        return input if input.downcase == "save"
    
        input = ensure_valid_guess(input)
        input = ensure_new_guess(input)
        
        
        @guesses += input
        return input
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
    attr_reader :player, :computer, :guesses_left

    def initialize(player=Player.new, computer=Computer.new, guesses_left=15)
        @player = player
        @computer = computer
        @guesses_left = guesses_left
    end

    def self.start
        puts "Would you like to load a saved game?(Y/N)"
        input = gets.chomp

        while !input.match(/[ynYN]/)
            puts "\n"
            puts "Please enter \'Y\' for yes or \'N\' for no:"
            input = gets.chomp
            puts "\n"
        end

        if input.upcase == "Y"
            Game.load.play
        else
            Game.new.play
        end
    end

    def self.load
        puts "Please enter the name of the save file you wish to load:"
        file_name = gets.chomp
        file = File.read("savegames/#{file_name}")
        saved_game = Game.unserialize(file)
    end

    def serialize
        YAML.dump(self)
    end

    def self.unserialize(string)
        YAML.load(string)
    end

    def play

        computer_chose_word_message
        puts "\n"

        while true
            get_incorrect_guesses

            input = @player.get_input
            if input == 'save'
                save_game
                saved_game_message
                next
            end

            puts "\n"
            matching_letters_message(@computer.word, input)
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

    def save_game
        Dir.mkdir("savegames") if !Dir.exists?("savegames")

        time = Time.now.to_s[0..18]
        File.write("savegames/#{time}.txt", self.serialize)
    end

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

    def saved_game_message
        puts "\n"
        puts "-"*25
        puts "Game successfully saved."
        puts "-"*25
        puts "\n"
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
        guessed_word? || out_of_guesses?
    end

    def out_of_guesses?
        @guesses_left <= 0
    end

    def guessed_word?
        @computer.word.split("").each do |letter|
            return false if !@player.guesses.include?(letter)
        end

        true
    end

    def computer_chose_word_message
        puts "The Computer has chosen a random word."
    end

    def remaining_guesses
        puts "You have #{@guesses_left} guesses remaining."
    end
    
end

Game.start