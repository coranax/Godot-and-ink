# warning-ignore-all:return_value_discarded

extends Control


var NewInkPlayer = load("res://addons/inkgd/ink_player.gd")

var ChoiceButt: PackedScene = preload("res://scenes/choice_button.tscn")

@onready var _ink_player = NewInkPlayer.new()

# my variables uwu
@onready var text_box: RichTextLabel = $HBoxContainer/MarginContainerTextBox/MarginContainerTextBoxInner/TextBox
@onready var ssf_label: RichTextLabel = $StorySoFar
@onready var choice_container: VBoxContainer = $HBoxContainer/MarginContainerButtonBox/MarginContainerButtonBoxInner/ChoiceContainer

var story_so_far: String = ""


func _ready():
	# Adds the player to the tree.
	add_child(_ink_player)

	# Replace the example path with the path to your story.
	_ink_player.ink_file = load("res://story/testing.ink.json")

	# It's recommended to load the story in the background.
	_ink_player.loads_in_background = true

	_ink_player.loaded.connect(_story_loaded)

	# Creates the story. 'loaded' will be emitted once Ink is ready
	# continue the story.
	_ink_player.create_story()
	
	ssf_label.set_scroll_follow(true)
	ssf_label.visible = false




func _story_loaded(successfully: bool):
	if !successfully:
		return

	# _observe_variables()
	# _bind_externals()

	_continue_story()


func _continue_story():
	var text: String = ""
	while _ink_player.can_continue:
		text += _ink_player.continue_story() + "[br]" # the br is here in BBC code to add extra white space after each paragraph/line break
		text_box.set_text(text)
		
	if _ink_player.has_choices:
		story_so_far += text_box.get_text()
		ssf_label.set_text(story_so_far)
		
		clear_buttons()
		var id: int = 0 # this will increment in order to assign the button to the correct choice index
		
		for choice in _ink_player.current_choices: # 'current_choices' contains a list of the choices, as strings.
			build_buttons(choice, id)
			id += 1
		
	else: # This code runs when the story reaches it's end.
		print("The End")

func clear_buttons() -> void:
	for button in get_tree().get_nodes_in_group("choice_buttons"):
		button.queue_free()

func build_buttons(choice, id) -> void:
	var cbutt: ChoiceButton = ChoiceButt.instantiate()
	choice_container.add_child(cbutt)
	cbutt.add_to_group("choice_buttons")
	cbutt.set_text(choice.text)	
	cbutt.button_id = id
	cbutt.pressed.connect(choice_button_press.bind(id))

func choice_button_press(id) -> void:
	_select_choice(id)

# '_select_choice' is a function that will take the index of your selection and continue the story.
func _select_choice(index):
	_ink_player.choose_choice_index(index)
	_continue_story()


func _on_reset_button_pressed() -> void:
	story_so_far = ""
	clear_buttons()
	_ink_player.reset()
	_continue_story()


func facy_text(_label: Label) -> void: # todo!!!!!
	pass


func _on_show_ssf_pressed() -> void:
	if ssf_label.visible == true:
		ssf_label.visible = false
	elif ssf_label.visible == false:
		ssf_label.visible = true


# Uncomment to bind an external function.
#
# func _bind_externals():
# 	_ink_player.bind_external_function("<function_name>", self, "_external_function")
#
#
# func _external_function(arg1, arg2):
# 	pass


# Uncomment to observe the variables from your ink story.
# You can observe multiple variables by putting adding them in the array.
# func _observe_variables():
# 	_ink_player.observe_variables(["var1", "var2"], self, "_variable_changed")
#
#
# func _variable_changed(variable_name, new_value):
# 	print("Variable '%s' changed to: %s" %[variable_name, new_value])





	
