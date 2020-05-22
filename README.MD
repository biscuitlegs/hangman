# Hangman

## About:
This is a version of the game Hangman made in *Ruby(2.6.3)* that is played from the command line.

## How to play:
### In a browser:
* You can play in a browser through REPL.it: **link_here**

### On a local machine:
* CD to the location of *hangman.rb* on your machine.
* Run the file with: `ruby hangman.rb`.

## Rules:
* The Computer will choose a word randomly from a dictionary. It is your job to guess this word.
* Each turn you will be shown the number of turns you have left, any incorrect guesses you have made so far, and the word the Computer has chosen -- but only the letters you've guessed so far!
* Then, you will be asked to guess a letter of the Computer's word.
* If the letter you guess appears more than once in the word, all instances of it will be revealed to you.
* If 15 turns pass without you guessing the Computer's word, you lose.
* If you guess all the letters in the Computer's word, you win.