# The template structure

Most of the template is covered in [the project structure document](Structure.txt). Won't cover how they work - they're fairly sufficiently documented to hopefully make it obvious. This covers the most basic stuff already in the template and what it's for, including `Scripts\Singletons` `Scenes\Singletons`.

## random_helpers

A `Node` script allowing random numbers to be generated as if they were "rolled" by dice, and allows the total to be added to or subtracted from. May contain other random-related functions too.

## helper_functions

A `Node` script, for non-game(play) related settings (resolution, detail, volume etc). Contains convenience functions for adding, creating and switching to nodes/scenes and a function to run code only once.

## *_player (jingle/music/sound)

These are all sound players using `AudioStreamPlayer`. Jingles are non-looped (usually short) pieces of music. Music is obvious, and sounds are looped sounds (ambient) or non-looped. They're set up to use the respective audio buses. Should cover most basic use cases between them. `sound_player` should be used just for non-looped effects; looped sounds should be handled directly.

These are all non-positional; use the appropriate stream players in a scene as required.

## Assets/Fonts/OpenSans-Regular.ttf

Used as a default font for the UI theme.

## Assets/UI/Default.tres

Used as a default UI/HUD theme for the game.