class_name InkManager extends Node
# class ^
# this manager handles the functions directly related to ink and passes info between itself and text_manager

var NewInkPlayer = load("res://addons/inkgd/ink_player.gd")
@onready var _ink_player = NewInkPlayer.new()

# the rest of the management team
@onready var text_mgr = %TextManager
@onready var button_mgr = %ButtonManager

# Replace the path with the path to your story. UNIQUE
var i_file: String = "res://story/testing.ink.json"
#var s_file: String = "res://story/saves/ink.save" # for testing?
var s_file: String = "user://ink.save" # for prod?

# some bools. i don't think these are strictly needed but they might be helpful in state management
@export var is_loaded: bool = false
@export var can_story_continue: bool = false
@export var has_choices: bool = false
@export var is_finished: bool = false

@export var story_text: String = "" # the current story text
@export var story_so_far: String = "" # the cumulative story text
@export var choice_array: Array = [] # array of current choices
@export var cont_tag_array: Array = [] # these are the tags while story can continue

@export var var_array: Array = [] # array of variables, set from text_mgr
@export var changed_var_dict: Dictionary = {} # will store any changed variables


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Ready!
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

func _ready():
	# Adds the player to the tree.
	add_child(_ink_player)
	
	# load the file
	_ink_player.ink_file = load(i_file)

	# It's recommended to load the story in the background.
	_ink_player.loads_in_background = true

	_ink_player.loaded.connect(_story_loaded)

	# Creates the story. 'loaded' will be emitted once Ink is ready
	_ink_player.create_story()


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Story Flow
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

## is the story loaded?
func _story_loaded(successfully: bool):
	if !successfully:
		return
	is_loaded = true
	_observe_variables()
	# _bind_externals()
	_continue_story()

## public function for cont.
func continue_story() -> void:
	_continue_story()

## this one is doing a lot, it is the meat and potatoes of the story flow
func _continue_story():
	story_text = ""
	while _ink_player.can_continue:
		can_story_continue = true
		
		# += is important else it will just show last line from ink
		# the br is here in BBC code to add extra white space after each paragraph/line break
		story_text += _ink_player.continue_story() + "[br]"
		
		cont_tag_array = _ink_player.current_tags 
		
		text_mgr.build_setting(cont_tag_array) # gathers the tags and uses them to apply the appropriate settings
		text_mgr.build_prog_array(cont_tag_array) # progress array tracks the "finish" tag UNIQUE
		
	if _ink_player.has_choices:
		text_mgr.set_text_box(story_text)
		has_choices = true
		is_finished = false
		
		story_so_far += story_text
		text_mgr.set_ssf_label(story_so_far)
		
		# this needs to stay under the choices clause, and take the tags that are available at the time of the choice
		text_mgr.build_prog_dict(_ink_player.current_tags)
		
		# 'current_choices' contains a list of the choices, as strings.
		choice_array = _ink_player.current_choices
		
		button_mgr.clear_choice_buttons()
		button_mgr.build_choice_buttons(choice_array)
		
	else: # This code runs when the story reaches it's end.
		is_finished = true
		can_story_continue = false
		has_choices = false
		
		button_mgr.clear_choice_buttons()
		#print("The End")

## '_select_choice' is a function that will take the index of your selection and continue the story.
func select_choice(index):
	_ink_player.choose_choice_index(index)
	_continue_story()

## You can observe multiple variables by putting adding them in the array. UNIQUE
func _observe_variables():
	_ink_player.observe_variables(var_array, self, "_variable_changed")

## adds the changed variables to a dictonary for observation elsewhere
func _variable_changed(variable_name, new_value):
	if var_array.has(variable_name):
		changed_var_dict[variable_name] = new_value
		#print("Variable '%s' changed to: %s" %[variable_name, new_value])

## reset the story
func reset() -> void:
	story_so_far = ""
	_ink_player.reset()
	_continue_story()

# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Saving and Loading the ink (what about my settings?) TODO
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #


func save_ink() -> void:
	#print("# -----* SAVING ink")
	_ink_player.save_state_to_path(s_file)


func load_ink() -> void:
	#print("# -----* LOADING ink")
	if !FileAccess.file_exists(s_file):
		push_error("File Not Found! :(")
	else:
		_ink_player.load_state_from_path(s_file)
		_continue_story()





# -------------------------------------------------------------------------- #
# unneeded at the moment
# -------------------------------------------------------------------------- #

# Uncomment to bind an external function.
#
# func _bind_externals():
# 	_ink_player.bind_external_function("<function_name>", self, "_external_function")
#
#
# func _external_function(arg1, arg2):
# 	pass
