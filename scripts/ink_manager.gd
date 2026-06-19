class_name InkManager extends Node
# class ^
# this manager handles the functions directly related to ink and passes info between itself and text_manager

var NewInkPlayer = load("res://addons/inkgd/ink_player.gd")
@onready var _ink_player = NewInkPlayer.new()

@onready var text_mgr = %TextManager
@onready var button_mgr = %ButtonManager

# Replace the path with the path to your story. UNIQUE
var i_file: String = "res://story/testing.ink.json"

@export var is_loaded: bool = false
@export var can_continue: bool = false
@export var has_choices: bool = false
@export var is_finished: bool = false

@export var story_text: String = ""
@export var story_so_far: String = ""
@export var choice_array: Array = []
@export var cont_tag_array: Array = [] # these are the tags while story can continue

@export var var_array: Array = []
@export var changed_var_dict: Dictionary = {}

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

# is the story loaded?
func _story_loaded(successfully: bool):
	if !successfully:
		return
	is_loaded = true
	_observe_variables()
	# _bind_externals()
	_continue_story()

# public function
func continue_story() -> void:
	_continue_story()

# this one is doing a lot
func _continue_story():
	story_text = ""
	while _ink_player.can_continue:
		can_continue = true
		
		# += is important else it will just show last line from ink
		# the br is here in BBC code to add extra white space after each paragraph/line break
		story_text += _ink_player.continue_story() + "[br]"
		
		text_mgr.set_text_box(story_text)
		
		cont_tag_array = _ink_player.current_tags 
		
		text_mgr.build_setting(cont_tag_array) # gathers the tags and uses them to apply the appropriate settings
		text_mgr.build_prog_array(cont_tag_array) # progress array tracks the "finish" tag UNIQUE
		
	if _ink_player.has_choices:
		has_choices = true
		is_finished = false
		
		story_so_far += story_text
		text_mgr.set_ssf(story_so_far)
		
		# this needs to stay under the choices clause, and take the tags that are available at the time of the choice
		text_mgr.build_prog_dict(_ink_player.current_tags)
		
		# 'current_choices' contains a list of the choices, as strings.
		choice_array = _ink_player.current_choices
		
		button_mgr.clear_choice_buttons()
		var choice_index: int = 0 # this will increment in order to assign the button to the correct choice index
		for choice in choice_array: 
			button_mgr.build_choice_buttons(choice, choice_index)
			choice_index += 1
		
	else: # This code runs when the story reaches it's end.
		is_finished = true
		can_continue = false
		has_choices = false
		
		button_mgr.clear_choice_buttons()
		print("The End")
		#print(text_manager.prog_array)
		#print(text_manager.prog_dict)


# '_select_choice' is a function that will take the index of your selection and continue the story.
func select_choice(index):
	_ink_player.choose_choice_index(index)
	_continue_story()

#You can observe multiple variables by putting adding them in the array. UNIQUE
func _observe_variables():
	_ink_player.observe_variables(var_array, self, "_variable_changed")

func _variable_changed(variable_name, new_value):
	if var_array.has(variable_name):
		changed_var_dict[variable_name] = new_value
		#print("Variable '%s' changed to: %s" %[variable_name, new_value])

func reset() -> void:
	story_so_far = ""
	_ink_player.reset()
	_continue_story()

# -------------------------------------------------------------------------- #
# IDK what this stuff is tbh
# -------------------------------------------------------------------------- #



# Uncomment to bind an external function.
#
# func _bind_externals():
# 	_ink_player.bind_external_function("<function_name>", self, "_external_function")
#
#
# func _external_function(arg1, arg2):
# 	pass
