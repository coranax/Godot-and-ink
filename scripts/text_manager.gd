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

# saves the settings so they can be recalled when a save game is loaded UNIQUE
var sett_dict: Dictionary = {
	"setting" = "",
	"image" = "",
	"music" = ""
}

# record the players progress in various ways
var prog_array: Array = []
var prog_dict: Dictionary = {}
# for the dict
var ch_id: int = 0
var ch_title: String = ""
var ch_body: String = ""

# list of location arrays taken from ink UNIQUE
var loc_list: Array = ["ch0101", "ch0102", "ch0103", "ch0201", "ch0202", "ch0203", "ch0301", "ch0302", "ch0303"]

# this will vary per project but it must be done. UNIQUE
const bgi_path: String = "res://art/"

# for saving the game tex and other info used here NOTE it's a json
#var s_file: String = "res://story/saves/text.json" # for testing?
var s_file: String = "user://text.json" # for prod?

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
func set_ssf_label(text: String)-> void:
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
		sett_dict["setting"] = get_tag_slice(tags, "setting")
	if is_tag_listed(tags, "image"):
		set_bg_image(get_tag_slice(tags, "image"))
		sett_dict["image"] = get_tag_slice(tags, "image")
	if is_tag_listed(tags, "music"):
		audio_mgr.change_song(int(get_tag_slice(tags, "music")))
		sett_dict["music"] = get_tag_slice(tags, "music")

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
			button_mgr.refresh_tl_buttons(prog_array)

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
# Saving and Loading
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# these functions are strictly game engine side, and will need to work in tandem with saving and loading the ink file

# gathers the current settings and progress and stores in a dictionary
func save_text_prog() -> void:
	print("# -----* SAVING prog/text/etc")
	var f = FileAccess.open(s_file, FileAccess.WRITE)
	
	var state_dict: Dictionary = {
		"sett_dict" = {},
		"prog_array" = [],
		"proc_dict" = {},
		"text_box" = "",
		"ssf_label" = ""
	}
	
	# important to DUPLICATE arrays and dictionaries. deep = true because some are nested
	state_dict["sett_dict"] = sett_dict.duplicate(true)
	state_dict["prog_array"] = prog_array.duplicate(true)
	state_dict["proc_dict"] = prog_dict.duplicate(true)
	
	state_dict["text_box"] = text_box.get_text()
	state_dict["ssf_label"] = ssf_label.get_text()
	
	var json = JSON.stringify(state_dict)
	f.store_string(json)
	f.close()

# sets the settings and progress from a given dictionary (hopefully the one from when you saved) ;)
func load_text_prog() -> void:
	print("# -----* LOADING prog/text/etc")
	
	if !FileAccess.file_exists(s_file):
		push_error("File Not Found! :(")
	else:
		var f = FileAccess.open(s_file, FileAccess.READ)
		var json = f.get_as_text()
		var old_state = JSON.parse_string(json)
		
		# reapply settings
		sett_dict = old_state["sett_dict"].duplicate(true)
		set_setting_label(sett_dict["setting"])
		set_bg_image(sett_dict["image"])
		audio_mgr.change_song(int(sett_dict["music"]))
		
		# reapply progress array. buttons need refreshed
		prog_array = old_state["prog_array"].duplicate(true)
		button_mgr.refresh_tl_buttons(prog_array)
		
		# reapply progress dictionary
		prog_dict = old_state["proc_dict"].duplicate(true)
		
		# set text boxes
		set_text_box(old_state["text_box"])
		set_ssf_label(old_state["ssf_label"])
		
		# realign ssf in ink manager
		ink_mgr.story_so_far = old_state["ssf_label"] # i don't love this but... it works
		
		f.close()


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Reset
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

# reset the settings and progress trackers
func reset_progress() -> void:
	prog_array = []
	prog_dict = {}
	sett_dict= {
		"setting" = "",
		"image" = "",
		"music" = ""
	}
