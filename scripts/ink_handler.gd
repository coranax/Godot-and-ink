# warning-ignore-all:return_value_discarded

extends Control

var NewInkPlayer = load("res://addons/inkgd/ink_player.gd")

var ChoiceButt: PackedScene = preload("res://scenes/choice_button.tscn")

@onready var _ink_player = NewInkPlayer.new()

# my variables uwu
@onready var bg_image: TextureRect = %BgImage
@onready var setting: RichTextLabel = %Setting

@onready var text_box: RichTextLabel = %TextBox
@onready var ssf_label: RichTextLabel = %StorySoFar
@onready var choice_container: VBoxContainer = %ChoiceContainer

@onready var time_line_text_panel: Panel = %TLTextPanel
@onready var time_line_text: RichTextLabel = %TimeLineText
@onready var time_line_choice_panel = %TLChoicePanel
@onready var time_line_choice_container = %TLChoiceContainer

@onready var bg_music: AudioStreamPlayer2D = %BgMusic
@onready var click: AudioStreamPlayer2D = %Click
@onready var mute_music_butt: CheckButton = $MCPanel/MenuContainer/MuteMusic
@onready var mute_sfx_butt: CheckButton = $MCPanel/MenuContainer/MuteSFX
# waow that's a lot. 

# record the players progress in various ways
var story_so_far: String = "" # this is mainly just for display text
var prog_array: Array = []

var prog_dict: Dictionary
var ch_id: int = 0
var ch_title: String = ""
var ch_body: String

var current_loc
var loc_list: Array = ["ch0101", "ch0102", "ch0103", "ch0201", "ch0202", "ch0203", "ch0301", "ch0302", "ch0303"]

# these two may vary per project but it must be done. UNIQUE
const bgi_path: String = "res://art/"
const bgm_path: String = "res://music/"


func _ready():
	# Adds the player to the tree.
	add_child(_ink_player)

	# Replace the example path with the path to your story. UNIQUE
	_ink_player.ink_file = load("res://story/testing.ink.json")

	# It's recommended to load the story in the background.
	_ink_player.loads_in_background = true

	_ink_player.loaded.connect(_story_loaded)

	# Creates the story. 'loaded' will be emitted once Ink is ready
	# continue the story.
	_ink_player.create_story()
	
	# get the story so far scrolling situated
	ssf_label.set_scroll_follow(true)
	ssf_label.visible = false
	time_line_text_panel.visible = false
	time_line_choice_panel.visible = false
	
	# make sure menu buttons make a click sound. UNIQUE
	for mb in get_tree().get_nodes_in_group("menu_buttons"):
		mb.pressed.connect(play_click.bind())


# -------------------------------------------------------------------------- #
# Story and ink stuff
# -------------------------------------------------------------------------- #

# is the story loaded?
func _story_loaded(successfully: bool):
	if !successfully:
		return
	_observe_variables()
	# _bind_externals()
	_continue_story()

# this one is doing a lot
func _continue_story():
	var text: String = ""
	while _ink_player.can_continue:
		 # += is important here else it will just show last line from ink
		text += _ink_player.continue_story() + "[br]" # the br is here in BBC code to add extra white space after each paragraph/line break
		text_box.set_text(text)
		text_box.scroll_to_line(0)
		
		# gathers the tags and uses them to apply the appropriate settings
		build_setting(_ink_player.current_tags)
		# progress array tracks the "finish" tag UNIQUE
		build_prog_array(_ink_player.current_tags)
		
	if _ink_player.has_choices:
		# this needs to be here instead of above because otherwise each paragraph is repeated until the story hits a choice point
		story_so_far += text_box.get_text()
		ssf_label.set_text(story_so_far)
		
		# prog dict tracks the "record" tag UNIQUE
		build_prog_dict(_ink_player.current_tags)
		
		clear_choice_buttons() # clear the old buttons first
		var id: int = 0 # this will increment in order to assign the button to the correct choice index
		for choice in _ink_player.current_choices: # 'current_choices' contains a list of the choices, as strings.
			build_choice_buttons(choice, id)
			id += 1
		
	else: # This code runs when the story reaches it's end.
		# final update to story so far
		story_so_far += text_box.get_text()
		ssf_label.set_text(story_so_far)
		# clear buttons
		clear_choice_buttons()
		print("The End")
		print(prog_array)
		print(prog_dict)

# '_select_choice' is a function that will take the index of your selection and continue the story.
func _select_choice(index):
	_ink_player.choose_choice_index(index)
	_continue_story()

#You can observe multiple variables by putting adding them in the array. UNIQUE
func _observe_variables():
	_ink_player.observe_variables(["current_loc"], self, "_variable_changed")

func _variable_changed(variable_name, new_value):
	if variable_name == "current_loc": # UNIQUE
		current_loc = str(new_value)
	print("Variable '%s' changed to: %s" %[variable_name, new_value])

# this works hand in hand with the next one. would have liked to do it in one but i'm only so brave
func is_tag_listed(tags: Array, item: String) -> bool:
	# deliminatior
	var d = ": "
	
	var is_listed: bool = false
	
	if tags.is_empty(): # make sure there are tags
		return is_listed
	elif !tags.is_empty():
		for t in tags: # loop through - remember t is the string not the count variable
			if t.get_slice_count(d) > 1: # verify that the deliminator is present
				if t.contains(item): # check for item
					is_listed = true
					return is_listed
	return is_listed

# search for a tag in ink, and return the slice after the ": " deliminator UNIQUE
func get_tag_slice(tags: Array, item: String) -> String:
	# deliminatior
	var d = ": "
	
	# text to the right of the deliminator
	var slice: String = "N/A"
	
	if tags.is_empty(): # make sure there are tags
		return slice
	elif !tags.is_empty():
		for t in tags: # loop through - remember t is the string not the count variable
			if t.get_slice_count(d) > 1: # verify that the deliminator is present
				if t.contains(item): # check for item
					slice = t.get_slice(d, 1) # get the value after the deliminator
					return slice
	return slice

# -------------------------------------------------------------------------- #
# BUTTONS!!
# -------------------------------------------------------------------------- #

# build the CHOICE buttons. this function is called within a loop!
func build_choice_buttons(choice, id: int) -> void:
	var cbutt: ChoiceButton = ChoiceButt.instantiate()
	choice_container.add_child(cbutt)
	cbutt.add_to_group("choice_buttons") # UNIQUE RESERVED - don't use this name for another group
	cbutt.set_text(choice.text)
	cbutt.button_id = id
	cbutt.pressed.connect(choice_button_press.bind(id))
	cbutt.pressed.connect(play_click.bind())
	cbutt.set_h_size_flags(4)
	cbutt.set_v_size_flags(1)

# clear the CHOICE buttons, or else they will just multiply forever and ever
func clear_choice_buttons() -> void:
	for button in get_tree().get_nodes_in_group("choice_buttons"):
		button.queue_free()

# a choice button has been pressed # blessed
func choice_button_press(id: int) -> void:
	_select_choice(id)

# clear and reset the story
func _on_reset_button_pressed() -> void:
	story_so_far = ""
	prog_array = []
	clear_choice_buttons()
	clear_tl_buttons()
	_ink_player.reset()
	_continue_story()

# hide or unhide the story so far
func _on_show_ssf_pressed() -> void:
	if ssf_label.visible == true:
		ssf_label.visible = false
	elif ssf_label.visible == false:
		ssf_label.visible = true

# build the TIMELINE buttons - this is called in the build_prog_array function. messy!
func build_tl_buttons(prog: Array) -> void:
	for p in prog:
		var tlbutt: ChoiceButton = ChoiceButt.instantiate() # it's not really a choice button but whatever. she's fine.
		time_line_choice_container.add_child(tlbutt)
		tlbutt.add_to_group("time_line_buttons") # UNIQUE RESERVED - don't use this name for another group
		tlbutt.set_text(p)
		tlbutt.button_id = int(p)
		tlbutt.pressed.connect(play_click.bind())
		tlbutt.pressed.connect(show_time_line_text.bind(p))
		tlbutt.set_h_size_flags(4)
		tlbutt.set_v_size_flags(1)

# hide or unhide the timeline panel
func _on_show_tl_pressed() -> void:
	if time_line_choice_panel.visible:
		time_line_choice_panel.visible = false
		clear_tl_buttons()
	elif !time_line_choice_panel.visible:
		time_line_choice_panel.visible = true
		# build the timeline buttons based on the prog array
		build_tl_buttons(prog_array)

# clear the TIMELINE buttons, or else they will just multiply forever and ever
func clear_tl_buttons() -> void:
	for button in get_tree().get_nodes_in_group("time_line_buttons"):
		button.queue_free()

func show_time_line_text(id: String) -> void: # do i want to take this as an int or a string???? hmmmm....

	# should i disable some buttons while timeline is open?
	var text = prog_dict[int(id)]["body"]
	
	if !time_line_text_panel.visible:
		time_line_text_panel.visible = true
		time_line_text.set_text("") # reset whatever was shown before
		time_line_text.set_text(text)
	elif time_line_text_panel.visible:
		time_line_text.set_text(text)
	
	print("the id is: " + id)

func _on_close_tl_pressed() -> void:
	if time_line_text_panel.visible:
		time_line_text_panel.visible = false
	pass # Replace with function body.


# -------------------------------------------------------------------------- #
# Game Settings and Progress
# -------------------------------------------------------------------------- #

# these are the game elements that will change based on the "setting" (ink tags) of the story
func build_setting(tags: Array) -> void:
	# remember to change bgi_path and bgm_path if needed
	
	# storing the tags in a dict UNIQUE (names of settings)
	var setting_dict: Dictionary = { 
		"setting" = "",
		"image" = "",
		"music" = ""
	} # why does this exist?
	
	if is_tag_listed(tags, "setting"):
		setting_dict["setting"] = get_tag_slice(tags, "setting")
		setting.set_text(setting_dict["setting"])
	if is_tag_listed(tags, "image"):
		setting_dict["image"] = get_tag_slice(tags, "image")
		bg_image.texture = load(bgi_path + setting_dict["image"])
	if is_tag_listed(tags, "music"):
		setting_dict["music"] = get_tag_slice(tags, "music")
		bg_music.stream = load(bgm_path + setting_dict["music"])
		bg_music.play()

# stores the player's progress in an array. "finish". UNIQUE
func build_prog_array(tags: Array):
	if is_tag_listed(tags, "finish"):
		if !prog_array.has(get_tag_slice(tags,"finish")): # make sure this section is not already included
			prog_array.append(get_tag_slice(tags, "finish"))
			prog_array.sort()
			_on_show_tl_pressed() # calling this twice forces the buttons to clear and reset based on the new sort
			_on_show_tl_pressed() # is this sloppy? maybe!

# this was the straw that broke the camel's back. i have no explination. UNIQUE
func build_prog_dict(tags: Array) -> void:
	if loc_list.has(current_loc):
		ch_body += text_box.get_text()
	
	if is_tag_listed(tags, "finish"):
		var new_prog: Dictionary = {
			"id:" = ch_id,
			"title" = ch_title,
			"body" = ch_body
			}
		prog_dict.set(ch_id, new_prog)
		ch_body = ""
	elif is_tag_listed(tags, "id"):
		ch_id = int(get_tag_slice(tags, "id"))
	elif is_tag_listed(tags, "title"):
		ch_title = get_tag_slice(tags, "title")

# -------------------------------------------------------------------------- #
# Sound (these could also fit with BUTTONS but alas)
# -------------------------------------------------------------------------- #

# attached the choice buttons and menu buttons to this
func play_click() -> void:
	click.play()

# mute the music and the sfx. probably need some error handling UNIQUE
func mute_music() -> void:
	if mute_music_butt.button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	elif !mute_music_butt.button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)

func mute_sfx() -> void:
	if mute_sfx_butt.button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	elif !mute_sfx_butt.button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)




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
