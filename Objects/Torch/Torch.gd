extends StaticBody3D

@onready var fireSFXRef: AudioStreamPlayer3D = %Fire
@onready var fireParticlesRef: GPUParticles3D = %FireParticles
@onready var LightRef: OmniLight3D = %OmniLight3D
@onready var collisionShapeRef: CollisionShape3D = %CollisionShape3D


func _ready() -> void:
	fireParticlesRef.emitting=false
	LightRef.visible=false
	
func lazered(_isLazered:=true)->void:
	LightRef.visible=true
	MusicSystem.playSfx(fireSFXRef)
	fireParticlesRef.emitting=true
	collisionShapeRef.disabled=true
	
func _on_fire_finished() -> void:
	MusicSystem.playSfx(fireSFXRef)
