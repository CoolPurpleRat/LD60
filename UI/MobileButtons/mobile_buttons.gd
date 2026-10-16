extends CanvasLayer

@onready var opacityControlRef: Control = %OpacityControl
var buttonOpacity:float

func _ready() -> void:
	buttonFlash()

func setVisibility(isVisible:bool=false)->void:
	visible=isVisible
	if isVisible:
		buttonFlash()

func buttonFlash()->void:
	var tweenButtonsFlash:Tween= get_tree().create_tween()
	opacityControlRef.modulate=Color(1.0, 1.0, 1.0, 1.0)
	tweenButtonsFlash.tween_property(opacityControlRef, "modulate", Color(1, 1, 1, buttonOpacity), 3)

func setOpacity(howMuch:float=1.0)->void:
	buttonOpacity=howMuch
	opacityControlRef.modulate=Color(1.0, 1.0, 1.0, howMuch)

func getOpacity()->float:
	return opacityControlRef.modulate.a
