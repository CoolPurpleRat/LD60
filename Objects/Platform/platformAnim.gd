extends Node3D

@export var uppointRef: Marker3D
@onready var vineRef: Node3D = %Rope

func _physics_process(_delta: float) -> void:
	if not uppointRef:
		return
	var lookDirection:=vineRef.global_transform.looking_at(uppointRef.global_position)
	vineRef.global_transform=vineRef.global_transform.interpolate_with(lookDirection, 0.05)
