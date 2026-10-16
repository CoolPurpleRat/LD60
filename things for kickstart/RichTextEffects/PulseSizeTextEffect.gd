@tool
extends RichTextEffect
class_name pulseSizeTE

# By coolPurpleRat https://bsky.app/profile/coolpurplerat.bsky.social
# CC0

var bbcode:Variant="pulseSize"

func _process_custom_fx(char_fx:CharFXTransform)->bool:
	##BBCODE variables
	##Appended scale
	var textIncrease:float=char_fx.env.get("textIncrease", 0.5)
	##Where text move
	var offset:Vector2=Vector2(char_fx.env.get("offsetX", -100), char_fx.env.get("offsetY", -70))
	var progress:float=abs(sin(char_fx.elapsed_time))
	
	var textSizeVec:Vector2=Vector2.ONE + Vector2.ONE*progress*textIncrease
	char_fx.transform=char_fx.transform.scaled(textSizeVec)
	 
	var textOffset:Vector2=offset*progress/textIncrease
	char_fx.transform=char_fx.transform.translated(textOffset)
	return true
