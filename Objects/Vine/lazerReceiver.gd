extends StaticBody3D
class_name vineHurtCol

signal dead
signal canRegrow
signal hurt

@onready var fireTimer: Timer = %FireTimer
@onready var unhurtTimer: Timer = %UnhurtTimer
@onready var parent:vine=get_parent()
@onready var ouchPartcRef: GPUParticles3D = %FireParticles
@onready var fireSFXRef: AudioStreamPlayer3D = %Fire
@export var collisionRef: CollisionShape3D

var canDie:=false:
	set(value):
		canDie=value
		if value:
			collisionRef.scale=Vector3.ONE
		else:
			collisionRef.scale=Vector3.ONE*2
func _ready() -> void:
	ouchPartcRef.global_rotation=Vector3.ZERO
	if canDie:
		collisionRef.scale=Vector3.ONE
	else:
		collisionRef.scale=Vector3.ONE*1.4
	

func lazered(isLazered:=true)->void:
	if not canDie:
		return
	if isLazered:
		MusicSystem.playSfx(fireSFXRef)
		unhurtTimer.stop()
		emit_signal(&"hurt")
		if fireTimer.is_stopped():
			fireTimer.start()
		fireTimer.paused=false
		ouchPartcRef.emitting=true
	else:
		fireTimer.paused=true
		unhurtTimer.start()

func _on_fire_timer_timeout() -> void:
	unhurtTimer.stop()
	ouchPartcRef.emitting=false
	canDie=false
	fireSFXRef.stop()
	emit_signal(&"dead")
	collisionRef.set_deferred("disabled", true)

func _on_unhurt_timer_timeout() -> void:
	ouchPartcRef.emitting=false
	fireTimer.stop()
	emit_signal(&"canRegrow")


func _on_fire_finished() -> void:
	if not fireTimer.is_stopped() or unhurtTimer.is_stopped():
		MusicSystem.playSfx(fireSFXRef)
