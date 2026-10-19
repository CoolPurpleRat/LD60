extends Area3D

func _on_body_entered(body: Node3D) -> void:
	var playerRef:=body as Player
	playerRef.respawn()
