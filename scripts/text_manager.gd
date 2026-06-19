extends Node
# this manager handles text, graphics, and UI elements


var ChoiceButt: PackedScene = preload("res://scenes/choice_button.tscn")

# other management
@onready var ink_mgr = %InkManager
@onready var button_mgr = %ButtonManager
@onready var audio_mgr = %AudioManager

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

@onready var fade_music: AudioStreamPlayer2D = %FadeMusic
# waow that's a lot. 

# record the players progress in various ways
var story_so_far: String = "" # this is mainly just for display text
var prog_array: Array = []

# for the timeline text. these need to be public as they are built at different times.
var prog_dict: Dictionary
var ch_id: int = 0
var ch_title: String = ""
var ch_body: String

# list of location arrays taken from ink UNIQUE
var loc_list: Array = ["ch0101", "ch0102", "ch0103", "ch0201", "ch0202", "ch0203", "ch0301", "ch0302", "ch0303"]

# this will vary per project but it must be done. UNIQUE
const bgi_path: String = "res://art/"

# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Ready
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

func _ready():
	ink_mgr.var_array = ["current_loc"]
	
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
		mb.pressed.connect(audio_mgr.play_click.bind())


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Story and ink stuff
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

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




# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Game Settings and Progress
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

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
		var new_song = int(setting_dict["music"])
		audio_mgr.change_song(new_song)

# stores the player's progress in an array. "finish". UNIQUE
func build_prog_array(tags: Array):
	if is_tag_listed(tags, "finish"):
		if !prog_array.has(get_tag_slice(tags,"finish")): # make sure this section is not already included
			prog_array.append(get_tag_slice(tags, "finish"))
			prog_array.sort()
			button_mgr._on_show_tl_pressed() # calling this twice forces the buttons to clear and reset based on the new sort
			button_mgr._on_show_tl_pressed() # is this sloppy? maybe!

# this is called when there are choices since that is where the finish tag is. UNIQUE
func build_prog_dict(tags: Array) -> void:
	var current_loc = str(ink_mgr.changed_var_dict["current_loc"])

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

# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Sound (these could also fit with BUTTONS but alas)
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

# this will play the next song and loop through all the clips (i don't need this lol)
func advance_music() -> void:
	var i = fade_music.get_stream_playback().get_current_clip_index()
	if i < 3:
		i += 1
	else:
		i = 0
	fade_music.get_stream_playback().switch_to_clip(i)
