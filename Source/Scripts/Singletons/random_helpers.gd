### "Helper" functions for random numbers.
# Mostly dice-like functions (generating random numbers by "rolling dice").

extends Node

onready var RNG := RandomNumberGenerator.new ()	# Used by all random generator functions.

func _ready () -> void:
	init_rng ()	# Initialise the random number seed.
	return

## init_rng
# Just a front for the randomize function. This usually is only called by _ready.
func init_rng () -> void:
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Always use a fixed seed for debugging.
		RNG.seed = -6398989897141750821
		print_debug ("DEBUG: RNG initialised to a fixed seed; seed is ", RNG.seed, ".")
	else:						# Not running in debug mode, random numbers can be "truly" random.
		RNG.randomize ()
		print_debug ("INFO: RNG initialised; seed is ", RNG.seed, ".")
		return

## roll_dice
# roll_dice (number_of_dice, dice_sides, add_to, sub_from)
# Rolls a given number (number_of_dice) of dice with sides (dice_sides).
# Can add to (add_to) or subtract from (sub_from) the calculated total.
# Defaults to 1d6+0-0 (1, 6, 0, 0).
# Returns the total given, or -1 if not enough dice, or -2 if not enough sides.
func roll_dice (number_of_dice:int = 1, dice_sides:int = 6, add_to:int = 0, sub_from:int = 0) -> int:
	var total_rolled:int = 0	# The total of the dice rolled.
	var dice_count:int = 0		# Used to count the number of dice rolled.
	var dice_rolled:int = 0		# Total of the current dice rolled.
	if (number_of_dice < 1):	# Invalid number of dice.
		printerr ("ERROR: roll_dice requires at least 1 \"dice\".")
		return (-1)
	if (dice_sides < 2):	# Dice need to have at least two sides.
		printerr ("ERROR: roll_dice requires a \"dice\" to have at least two \"sides\".")
		return (-2)
	while (dice_count < number_of_dice):	# Roll the dice.
		dice_rolled = RNG.randi_range (1, dice_sides)
		total_rolled += dice_rolled
		print_debug ("ROLLED: ", dice_rolled, "; TOTAL IS NOW: ", total_rolled, ".")
		dice_count += 1
	# Total calculated, so do any addition or subtraction needed here and return it.
	total_rolled = (total_rolled + add_to) - sub_from
	return (total_rolled)

## find_random_average
# find_random_average (total_numbers, random_range)
# Generates <total_numbers> of random numbers (1 up to <random_range>), returning the average of that total.
# The average returned is a float rounded (down) to an int.
func find_random_average (total_numbers:int = 1, random_range:int = 6) -> int:
	var total:float = 0.0
	total = float (roll_dice (total_numbers, random_range)) / float (total_numbers)
	return (int (total))
