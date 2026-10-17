extends StaticBody3D
class_name vineHurtCol

signal dead
signal canRegrow
signal hurt

@onready var fireTimer: Timer = %FireTimer
@onready var unhurtTimer: Timer = %UnhurtTimer
@onready var parent:vine=get_parent()
@onready var ouchPartcRef: GPUParticles3D = %OuchPartc

var canDie:=false

func _ready() -> void:
	ouchPartcRef.global_rotation=Vector3.ZERO

func lazered(isLazered:=true)->void:
	if not canDie:
		return
	if isLazered:
		unhurtTimer.stop()
		emit_signal(&"hurt")
		if fireTimer.is_stopped():
			fireTimer.start()
		fireTimer.paused=false
		ouchPartcRef.emitting=true
	else:
		ouchPartcRef.emitting=false
		fireTimer.paused=true
		unhurtTimer.start()

func _on_fire_timer_timeout() -> void:
	unhurtTimer.stop()
	ouchPartcRef.emitting=false
	canDie=false
	emit_signal(&"dead")

func _on_unhurt_timer_timeout() -> void:
	fireTimer.stop()
	emit_signal(&"canRegrow")
