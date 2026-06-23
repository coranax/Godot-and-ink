@tool

extends RichTextEffect
class_name CustTextEffect

var bbcode = "test"

func _process_custom_fx(char_fx: CharFXTransform):
	
	var speed = char_fx.env.get("speed", 5.0)
	var span = char_fx.env.get("span", 10.0)

	var alpha = sin(char_fx.elapsed_time * speed + (char_fx.range.x / span)) * 0.5 + 0.5
	char_fx.color.b = alpha
	char_fx.color.g = 1-alpha
	

	
	return true
