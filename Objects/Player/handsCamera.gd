extends Camera3D

@export var playerCamera:Camera3D
func _process(_delta: float) -> void:
	global_transform=playerCamera.global_transform
	fov=playerCamera.fov
