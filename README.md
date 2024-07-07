# Lospequarium

A simple aquarium simulator reusing the fish assets from the Pikzel Lake collab.

## Controls

`Left Click` to feed the fish and collect the coins.

Click the shop button in the bottom right to open the shop menu. 

## Contribute

Use godot 4.2+, and gdscript.

### Adding A minigame

1. create a new folder in the minigames folder with the games name 
2. add a 72x44 `icon.png` to the folder
3. on `main.tscn`, add a new arcade button to the menu, and set the `game_id` to the folder name, and pretty name to whatever
4. create a new scene in the folder called `game.tscn`
5. name the root Node2d the same as the folder name
6. add an instance of the MinigameController to the root 
7. create your game in this scene however you choose
8. try to reuse existing assets where possible, but put all new assets in your game folder
9. use these functions on the controller:

- `.increase_score(Int)` - incrase the score (the coins the player has won and will collect at the end)
- `.end_game()` - end the game, show the player their score (winnings), record high scores, and return to the aquarium

#### Minigame Design Guidelines
A good minigame fits the following criteria:
- fits the fish theme (reuses sprites from main game when possible)
- simple to program, low risk of bugs
- controlled with just mouse
- extremely easy to understand and learn
- has short (~1m) play sessions
- earns coins progressively while playing
- gets progressively harder, eventually leading to the game ending
- gives out ~10-20 coins when played well