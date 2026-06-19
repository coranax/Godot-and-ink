extends Node

@onready var mute_music_butt: CheckButton = %MuteMusic
@onready var mute_sfx_butt: CheckButton = %MuteSFX

@onready var click: AudioStreamPlayer2D = %Click
@onready var fade_music: AudioStreamPlayer2D = %FadeMusic

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

func change_song(new_song: int) -> void:
	var old_song = fade_music.get_stream_playback().get_current_clip_index()
	if !new_song == old_song:
		fade_music.get_stream_playback().switch_to_clip(new_song)
