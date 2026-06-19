extends Node
# this manager handles text, graphics, and UI elements


var ChoiceButt: PackedScene = preload("res://scenes/choice_button.tscn")


@onready var story_player = %InkManager
@onready var buttons = %ButtonManager
@onready var audio = %SoundManager

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
@onready var fade_music: AudioStreamPlayer2D = %FadeMusic
@onready var click: AudioStreamPlayer2D = %Click
@onready var mute_music_butt: CheckButton = $"../MCPanel/MenuContainer/MuteMusic"
@onready var mute_sfx_butt: CheckButton = $"../MCPanel/MenuContainer/MuteSFX"
# waow that's a lot. 

# record the players progress in various ways
var story_so_far: String = "" # this is mainly just for display text
var prog_array: Array = []

var prog_dict: Dictionary
var ch_id: int = 0
var ch_title: String = ""
var ch_body: String

var current_loc # UNIQUE
var loc_list: Array = ["ch0101", "ch0102", "ch0103", "ch0201", "ch0202", "ch0203", "ch0301", "ch0302", "ch0303"]

# these two may vary per project but it must be done. UNIQUE
const bgi_path: String = "res://art/"
const bgm_path: String = "res://music/"

# this is a silly, hacked, solution to get the choice buttons loaded ONCE to start
var need_butts: bool = true # it can't go in the ready func bc the story won't be loaded yet


func _ready():
	story_player.var_array = ["current_loc"]
	
	# get the story so far scrolling situated
	ssf_label.set_scroll_follow(true)
	ssf_label.visible = false
	time_line_text_panel.visible = false
	time_line_choice_panel.visible = false
	
	# you have to start the player or else the program will be very angry with you
	var music_tween = get_tree().create_tween()
	fade_music.play()
	fade_music.volume_db = -30
	music_tween.tween_property(fade_music, "volume_db", 1, 3)
	
	# make sure menu buttons make a click sound. UNIQUE
	for mb in get_tree().get_nodes_in_group("menu_buttons"):
		mb.pressed.connect(play_click.bind())


# -------------------------------------------------------------------------- #
# Story and ink stuff
# -------------------------------------------------------------------------- #

func set_text_box(text: String)-> void:
	text_box.set_text(text)

func set_ssf(text: String)-> void:
	ssf_label.set_text(text)


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
	story_player.select_choice(id)
	text_box.scroll_to_line(0)


# clear and reset the story
func _on_reset_button_pressed() -> void:
	set_ssf("")
	prog_array = []
	
	clear_choice_buttons()
	clear_tl_buttons()
	
	ssf_label.visible = false
	time_line_choice_panel.visible = false
	time_line_text_panel.visible = false
	
	story_player.reset()

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

# displays the timeline text if one of the timeline buttons is pressed
func show_time_line_text(id: String) -> void:
	# should i disable some buttons while timeline is open?
	var text = prog_dict[int(id)]["body"]
	
	if !time_line_text_panel.visible:
		time_line_text_panel.visible = true
		time_line_text.set_text("") # reset whatever was shown before
		time_line_text.set_text(text)
	elif time_line_text_panel.visible:
		if text == time_line_text.get_text():
			time_line_text_panel.visible = false
		else:
			time_line_text.set_text(text)

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
	# this would be for if you didn't want to use the fading music for whatever reason
	#if is_tag_listed(tags, "oldsound"):
		#setting_dict["oldsound"] = get_tag_slice(tags, "oldsound")
		#bg_music.stream = load(bgm_path + setting_dict["oldsound"])
		#bg_music.play()
	if is_tag_listed(tags, "music"):
		setting_dict["music"] = get_tag_slice(tags, "music")
		var new_song = int(setting_dict["music"])
		var old_song = fade_music.get_stream_playback().get_current_clip_index()
		if !new_song == old_song:
			fade_music.get_stream_playback().switch_to_clip(new_song)

# stores the player's progress in an array. "finish". UNIQUE
func build_prog_array(tags: Array):
	if is_tag_listed(tags, "finish"):
		if !prog_array.has(get_tag_slice(tags,"finish")): # make sure this section is not already included
			prog_array.append(get_tag_slice(tags, "finish"))
			prog_array.sort()
			_on_show_tl_pressed() # calling this twice forces the buttons to clear and reset based on the new sort
			_on_show_tl_pressed() # is this sloppy? maybe!

# this is called when there are choices since that is where the finish tag is. UNIQUE
func build_prog_dict(tags: Array) -> void:
	current_loc = str(story_player.changed_var_dict["current_loc"])

	if loc_list.has(current_loc):
		ch_body += text_box.get_text()
	
	if is_tag_listed(tags, "id"):
		ch_id = int(get_tag_slice(tags, "id"))
		
	if is_tag_listed(tags, "title"):
		ch_title = get_tag_slice(tags, "title")
	
	if is_tag_listed(tags, "finish"):
		var new_prog: Dictionary = {
			"id:" = ch_id,
			"title" = ch_title,
			"body" = ch_body
			}
		prog_dict.set(ch_id, new_prog)
		ch_body = ""

# -------------------------------------------------------------------------- #
# Sound (these could also fit with BUTTONS but alas)
# -------------------------------------------------------------------------- #

# this will play the next song and loop through all the clips (i don't need this lol)
func advance_music() -> void:
	var i = fade_music.get_stream_playback().get_current_clip_index()
	if i < 3:
		i += 1
	else:
		i = 0
	fade_music.get_stream_playback().switch_to_clip(i)

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
# Saving and Loading
# -------------------------------------------------------------------------- #

func _on_save_pressed() -> void:
	pass # Replace with function body.


func _on_load_pressed() -> void:
	pass # Replace with function body.
