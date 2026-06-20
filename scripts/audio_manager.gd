extends Node
# this manages all the audio

@onready var mute_music_butt: CheckButton = %MuteMusic
@onready var mute_sfx_butt: CheckButton = %MuteSFX

@onready var click: AudioStreamPlayer2D = %Click
@onready var fade_music: AudioStreamPlayer2D = %FadeMusic

func _ready() -> void:
	# you have to start the muisic or else the program will be very angry with you
	var music_tween = get_tree().create_tween()
	fade_music.play()
	fade_music.volume_db = -30
	music_tween.tween_property(fade_music, "volume_db", 1, 3)

# attached the choice buttons and menu buttons to this
func play_click() -> void:
	click.play()

# mute the music. UNIQUE
func mute_music() -> void:
	if mute_music_butt.button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	elif !mute_music_butt.button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)

# mute the sfx. UNIQUE
func mute_sfx() -> void:
	if mute_sfx_butt.button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	elif !mute_sfx_butt.button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)

# change the song, if it is different from the current song
func change_song(new_song: int) -> void:
	var old_song = fade_music.get_stream_playback().get_current_clip_index()
	if !new_song == old_song:
		fade_music.get_stream_playback().switch_to_clip(new_song)

# this will play the next song and loop through all the clips (i don't need this lol)
func advance_music() -> void:
	var i = fade_music.get_stream_playback().get_current_clip_index()
	if i < 3:
		i += 1
	else:
		i = 0
	fade_music.get_stream_playback().switch_to_clip(i)
