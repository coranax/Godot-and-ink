extends Node
# this manager handles text, graphics, and UI elements

# other management
@onready var ink_mgr = %InkManager
@onready var button_mgr = %ButtonManager
@onready var audio_mgr = %AudioManager

# my variables uwu
@onready var bg_image: TextureRect = %BgImage
@onready var setting_label: RichTextLabel = %Setting

@onready var text_box: RichTextLabel = %TextBox
@onready var ssf_label: RichTextLabel = %StorySoFar

@onready var time_line_text: RichTextLabel = %TimeLineText

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
	ink_mgr.var_array = ["current_loc"] # what variables the ink manager should watch for UNIQUE
	
	# get the story so far scrolling situated
	ssf_label.set_scroll_follow(true)
	ssf_label.visible = false
	
	# set these things transparent to start so the tweens will feel smoother
	text_box.set("theme_override_colors/default_color", Color(1,1,1,0))
	setting_label.set("theme_override_colors/default_color", Color(1,1,1,0))
	bg_image.set("self_modulate", Color(1,1,1,0))


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Text Boxes
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

# sets the main story text box. text will fade in, if the user button mashes it will break the effct but so it goes
func set_text_box(text: String)-> void:
	text_box.set("theme_override_colors/default_color", Color(1,1,1,0))
	var tween = get_tree().create_tween()
	text_box.set_text(text)
	tween.tween_property(text_box, "theme_override_colors/default_color", Color(1,1,1,1), 0.5)

# sets the story so far label
func set_ssf(text: String)-> void:
	ssf_label.set_text(text)

# sets the setting (title of sub section... probably needs a rename) label
func set_setting_label(text: String) -> void:
	setting_label.set("theme_override_colors/default_color", Color(1,1,1,0))
	var tween = get_tree().create_tween()
	setting_label.set_text(text)
	tween.tween_property(setting_label, "theme_override_colors/default_color", Color(1,1,1,1), 0.5)


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Tag Checkers
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

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
# Game Settings
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

# these are the game elements that will change based on the "setting" (ink tags) of the story UNIQUE
func build_setting(tags: Array) -> void:
	if is_tag_listed(tags, "setting"):
		set_setting_label(get_tag_slice(tags, "setting"))
	if is_tag_listed(tags, "image"):
		set_bg_image(get_tag_slice(tags, "image"))
	if is_tag_listed(tags, "music"):
		audio_mgr.change_song(int(get_tag_slice(tags, "music")))

# makes the background image fade out then fade in with the new one.
func set_bg_image(file: String) -> void:
	# remember to change bgi_path (above) if needed
	var tween_out = get_tree().create_tween()
	await tween_out.tween_property(bg_image, "self_modulate", Color(1,1,1,0), .5).finished
	# i could probably figure out cross fade but it feels not worth it. i don't hate this.
	var tween_in = get_tree().create_tween()
	bg_image.texture = load(bgi_path + file)
	tween_in.tween_property(bg_image, "self_modulate", Color(1,1,1,1), 1)


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Progress
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

# stores the player's progress in an array when it hits "finish" UNIQUE
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
