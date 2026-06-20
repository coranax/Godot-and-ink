extends Node
# this manages buttons and other UI elements

# some cute butts (choice buttons for story choices and the timeline)
var ChoiceButt: PackedScene = preload("res://scenes/choice_button.tscn")

@onready var ink_mgr = %InkManager
@onready var text_mgr = %TextManager
@onready var audio_mgr = %AudioManager

@onready var text_box: RichTextLabel = %TextBox
@onready var ssf_label: RichTextLabel = %StorySoFar
@onready var choice_container: VBoxContainer = %ChoiceContainer

@onready var time_line_text_panel: Panel = %TLTextPanel
@onready var time_line_text: RichTextLabel = %TimeLineText
@onready var time_line_choice_panel = %TLChoicePanel
@onready var time_line_choice_container = %TLChoiceContainer


func _ready() -> void:
	time_line_text_panel.visible = false
	time_line_choice_panel.visible = false
	
	# make sure menu buttons make a click sound. UNIQUE
	for mb in get_tree().get_nodes_in_group("menu_buttons"):
		mb.pressed.connect(audio_mgr.play_click.bind())


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Build Buttons
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

# build the CHOICE buttons. this function is called within a loop!
func build_choice_buttons(choice, id: int) -> void:
	var cbutt: ChoiceButton = ChoiceButt.instantiate()
	choice_container.add_child(cbutt)
	cbutt.add_to_group("choice_buttons") # UNIQUE RESERVED - don't use this name for another group
	cbutt.set_text(choice.text)
	cbutt.button_id = id
	cbutt.pressed.connect(_on_choice_button_press.bind(id))
	cbutt.pressed.connect(audio_mgr.play_click.bind())
	cbutt.set_h_size_flags(4)
	cbutt.set_v_size_flags(1)

# build the TIMELINE buttons - this is called in the build_prog_array function. messy!
func build_tl_buttons(prog: Array) -> void:
	for p in prog:
		var tlbutt: ChoiceButton = ChoiceButt.instantiate() # it's not really a choice button but whatever. she's fine.
		time_line_choice_container.add_child(tlbutt)
		tlbutt.add_to_group("time_line_buttons") # UNIQUE RESERVED - don't use this name for another group
		tlbutt.set_text(p)
		tlbutt.button_id = int(p)
		tlbutt.pressed.connect(_on_show_time_line_text.bind(p))
		tlbutt.pressed.connect(audio_mgr.play_click.bind())
		tlbutt.set_h_size_flags(4)
		tlbutt.set_v_size_flags(1)


# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# Clear Buttons
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

# clear the CHOICE buttons, or else they will just multiply forever and ever
func clear_choice_buttons() -> void:
	for button in get_tree().get_nodes_in_group("choice_buttons"):
		button.queue_free()

# clear the TIMELINE buttons, or else they will just multiply forever and ever
func clear_tl_buttons() -> void:
	for button in get_tree().get_nodes_in_group("time_line_buttons"):
		button.queue_free()

func refresh_tl_buttons(prog: Array) -> void:
	clear_tl_buttons()
	build_tl_buttons(prog)

# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #
# On Pressed Buttons
# -----*-----*-----*-----*-----*-----*-----*-----*-----*-----*-----*----- #

# -----* Instantiated buttons

# a choice button has been pressed # blessed
func _on_choice_button_press(id: int) -> void:
	ink_mgr.select_choice(id)
	text_box.scroll_to_line(0)

# displays the timeline text if one of the timeline buttons is pressed
func _on_show_time_line_text(id: String) -> void:
	# should i disable some buttons while timeline is open? no, not now
	var text = text_mgr.prog_dict[int(id)]["body"]
	
	if !time_line_text_panel.visible:
		time_line_text_panel.visible = true
		time_line_text.set_text("") # reset whatever was shown before
		time_line_text.set_text(text)
		time_line_text.scroll_to_line(0)
	elif time_line_text_panel.visible:
		if text == time_line_text.get_text():
			time_line_text_panel.visible = false
		else:
			time_line_text.set_text(text)
			time_line_text.scroll_to_line(0)

# -----* Static buttons

# clear and reset the story
func _on_reset_button_pressed() -> void:
	text_mgr.reset_progress()
	
	clear_choice_buttons()
	clear_tl_buttons()
	
	ssf_label.visible = false
	time_line_choice_panel.visible = false
	time_line_text_panel.visible = false
	
	ink_mgr.reset()

# hide or unhide the story so far
func _on_show_ssf_pressed() -> void:
	if ssf_label.visible == true:
		ssf_label.visible = false
	elif ssf_label.visible == false:
		ssf_label.visible = true

# hide or unhide the timeline panel
func _on_show_tl_pressed() -> void:
	if time_line_choice_panel.visible:
		time_line_choice_panel.visible = false
		clear_tl_buttons()
	elif !time_line_choice_panel.visible:
		time_line_choice_panel.visible = true
		# build the timeline buttons based on the prog array
		build_tl_buttons(text_mgr.prog_array)

# close the time line text box
func _on_close_tl_pressed() -> void:
	if time_line_text_panel.visible:
		time_line_text_panel.visible = false
	pass # Replace with function body.

# mute the music and sfx
func _on_mute_music_pressed() -> void:
	audio_mgr.mute_music()

func _on_mute_sfx_pressed() -> void:
	audio_mgr.mute_sfx()

# -----* Saving and Loading

#TODO >_>
var dict = {} # this is just for testing
func _on_save_pressed() -> void:
	print("# -----* SAVING BUTTON PRESSED :)")
	ink_mgr.save_ink()
	dict = text_mgr.save_text_prog()

func _on_load_pressed() -> void:
	print("# -----* LOADING BUTTON PRESSED :)")
	text_mgr.load_text_prog(dict)
	ink_mgr.load_ink()
