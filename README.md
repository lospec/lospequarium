# Lospequarium

A simple aquarium simulator reusing the fish assets from the Pikzel Lake collab.

Play Online: [https://lospecdotcom.itch.io/lospequarium](https://lospecdotcom.itch.io/lospequarium)

## Controls

`Left Click` to feed the fish and collect the coins.

Click the shop button in the bottom right to open the shop menu. 

## Contribute

Use godot 4.2+, and gdscript.

### Adding Fish

1. add sprite png to `/art/fish/` folder, with the fishes name (a-z and dahes)
2. duplicate a fish in the `/fish/` folder and rename it to the fish name
3. replace the Sprite2D's texture with the new fish sprite
4. adjust the collision shape to fit the sprite, and do the same with the mouth collision shape and MouthPoint and Bubbles
5. on the fishes scene root, set the `Proper Name`, `Max Speed`, `Cost`, and `Rarity` properties

Rarity level determines the chance of the fish showing in the shop, and the minimum tank size required. It should be a number between 1 and 16. To pick the right one, you should run the game, which prints out the rarity levels of all currently added fish to the console. Ideally each rarity level should have less fish than the ones before it, and the prices should be similar within the rarity level. Bigger fish should be rarer. 

Your fish name must fit on the the shop/info panel, so the max is ~13 characters. If your name is near this length, test it.

#### Fish Sprite Guidelines
- must be 16x16, 32x32, 48x48, or 64x64
- must be horizontal and facing left
- must match the style of the other fish
- must be properly sized (if real)
- must use [Cartoon Candy Palette](https://lospec.com/palette-list/cartoon-candy) colors

Here is the basics of the style, but you should reference the existing sprites for more details
- black outlines
- minimal AA, only when needed
- no dithering
- a little shading on the botton 
- highlights are small and round, but rare. usually on the forehead
- rarely textured, at most small group of 2x1 squares for scales
- black rectangular eyes with a shine in the middle left
- minor internal selout to soften lines where needed

Sprite size should reflect the fishes real world size if based on a real fish:
- **small 16x16** - could be picked up in one hand, ~1 foot long or less. aquarium fish, tiny fish like minnows, goldfish. most tropical fish.
- **medium 32x32** - bigger fish,  ~1-3 feet long. most edible fish are this size. takes two hands to hold.
- **big 48x48** - giant fish, 4-6 feet long or longer. big sea fish, sharks, tunas, etc. maybe the occasional river monster.
- **giant 64x64** - things that are too big to catch on a rod, giant squid, whale, megalodon, cthulu. very rare stuff.

### Adding A minigame

1. create a new folder in the minigames folder with the games name (a-z and dashes)
2. add a 72x44 `icon.png` to the folder
3. on `main.tscn`, add a new arcade button to the menu, and set the `game_id` to the folder name, and pretty name to whatever
4. create a new scene in the folder called `game.tscn`
5. name the root Node2d the same as the folder name
6. add an instance of the MinigameController to the root 
7. create your game in this scene however you choose
8. try to reuse existing assets where possible, but put all new assets in your game folder
9. use these functions on the controller:

- `.increase_score(Int)` - increase the score (the coins the player has won and will collect at the end)
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