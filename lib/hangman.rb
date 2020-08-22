require 'erb'

class Hangman
    attr_accessor :show_open
    def initialize
        @random_word = get_random_word
        word_length = @random_word.length
        @guess_spaces = Array.new(word_length, "_")
        @wrong_attempted_letters = Array.new
        @attempts_left = 6
        @opt_string = ""
        @show_open = true

        # run
    end

    def save_option save_question
        if save_question.downcase == "save"
            File.open('handman_gameplay', 'w+') do |f|  
               Marshal.dump(self, f)  
           end
           puts "Game saved"
           exit(0)
       end
       
    end

    def display_open_option
        if @show_open== true
            puts "Would you like to OPEN a previously saved game? (y/n)"
                open_question = gets.chomp
                if open_question.downcase == "y"
                    File.open('handman_gameplay') do |f|  
                        @saved_game = Marshal.load(f)  
                        @saved_game.show_open= false
                        @saved_game.run
                    end 
                end
        end

    end

    def draw_board
        
        if win?
            puts "\nYou Win!!"
            exit(true)            
        end
        puts "\n\n\n"
        for letter in @guess_spaces do
            print "#{letter} "
        end
        print "   | Type SAVE to save this game |"
        print " \nAttempts left: #{@attempts_left}"
        if !@wrong_attempted_letters.empty?
            print " | Incorrect letters : <#{@wrong_attempted_letters.join(", ")}>\n"
        end
    end

    def replace_wrong_letters letter_attempted
        @wrong_attempted_letters.push(letter_attempted)
        @attempts_left -=1
    end

    def replace_correct_letters letter_attempted
        @random_word.each_char.with_index do |letter, index|
            if letter.downcase == letter_attempted
                @guess_spaces[index] = letter_attempted
            end
        end
    end

    def replace_letters letter_attempted
        if @random_word.downcase.include? letter_attempted
            replace_correct_letters letter_attempted
        else
            replace_wrong_letters letter_attempted
        end
    end

    def get_user_input
        puts "" 
        return gets.chomp.downcase
    end

    def get_random_word
        words = File.read('5desk.txt').split
        words.select! {|word| word.length >4 && word.length< 13}
        return words[rand(0..words.length-1)]
    end

    def win?
        !@guess_spaces.include? "_" 
    end
    def process_input 
        input = get_user_input
        save_option input
        replace_letters input
    
    end

    def sorry_message
        puts "\nThe word was '#{@random_word},' try again later\n"
    end

    def run
        display_open_option
        until @attempts_left == 0
            draw_board
            process_input 
            
        end
        sorry_message
    end

end

hm = Hangman.new
hm.run
