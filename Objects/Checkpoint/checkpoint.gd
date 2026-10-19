extends Marker3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	var playerRef:=body as Player
	playerRef.checkpointRef=self
