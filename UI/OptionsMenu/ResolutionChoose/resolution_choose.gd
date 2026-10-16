extends HBoxContainer

@export var windowResolution:=DisplayServer.screen_get_size()
signal resolutionChange

@onready var xSpinRef: SpinBox = $"X spin"
@onready var ySpinRef: SpinBox = $"Y spin"


func _ready() -> void:
	xSpinRef.value=windowResolution.x
	ySpinRef.value=windowResolution.y
	if OS.has_feature("mobile"):
		visible=false

func _on_x_spin_value_changed(value: int) -> void:
	windowResolution.x=value

func _on_y_spin_value_changed(value: int) -> void:
	windowResolution.y=value

func _on_button_pressed() -> void:
	emit_signal("resolutionChange", windowResolution)
