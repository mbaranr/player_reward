# Player-Reward-MIPS-Assembly

The game consists of a simple walled environment. The player ('P') can move around the environment using the keyboard to collect different rewards ('R'). The game extension implements an enemy ('E') that uses Taxicab geometry logic to block the player's path.

## Ruleset

The rules for the creation of the game are as follows:

1. The game must be presented to the user via the ‘Display’ device in MARS 4.5
2. The user should be able to interact with the game via the ‘Keyboard’
device in the lower part of the same window.
3. The user should be able to use the ‘WASD’ keys to move the player around
the environment.
4. Each collected reward should contribute 5 points to the player’s score.
5. When a reward is collected, a new reward should appear in a di↵erent
randomly-allocated location in the environment.
6. The score should be presented to the user at the top of the display in the
form ‘Score: 25’.
7. If the player collides with a wall (i.e. tries to move into the wall), or if the
player reaches 100 points, the game should end.
8. When the game ends, the display should be cleared and a message displayed
saying ‘GAME OVER’, along with the final score.

## Structure

The folder "Part 1" contains the first version of the game, without the implementation of an enemy. While folder "Part 2" contains a new file called "Tracker_enemy.asm" that handles enemy behaviour.

## Instructions

Instructions on how to play the game are specified on the pdf file. This file also contains a high level description of the logic implemented to create the game. I personally recommend anyone who is interested in this project to check it out too.

## Credits
* [m4mbo](https://github.com/m4mbo) - Code.
* [James Stovold](https://www.linkedin.com/in/jstovold/) - Coursework material.
