extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

#TODO: setting to set it
@export var mouse_sensitivity: float = 0.3

@onready var camera: Camera3D = $Camera3D
@onready var lazerCastRef: RayCast3D = %LazerCast
@onready var lazerMeshRef: Node3D = %LazerMeshPivot
@onready var lazerSFXRef: AudioStreamPlayer3D = %Fire


func _ready() -> void:
	Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(&"Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector(&"MoveLeft", &"MoveRight", &"MoveUp", &"MoveDown")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_lazerProc()

func _input(event: InputEvent) -> void:
	_procCamera(event)
	if event.is_action(&"Pause"):
		Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_VISIBLE)
		PauseMenu.setActive()

var cameraXangle: float = 0.0
func _procCamera(event:InputEvent)->void:
	if event is InputEventMouseMotion:
		# Rotate left/right on the Y axis
		rotate_y(-deg_to_rad(event.relative.x * mouse_sensitivity))
		# Pitch up/down on the X axis with clamp
		cameraXangle += event.relative.y * mouse_sensitivity
		cameraXangle = clamp(cameraXangle, -90.0, 90.0)
		camera.rotation.x = -deg_to_rad(cameraXangle)
		
var lazeredBody:WeakRef
func _lazerProc()->void:
	
	if Input.is_action_pressed(&"Shoot"):
		if lazerCastRef.is_colliding():
			MusicSystem.playSfx(lazerSFXRef, 0.5, 0.8)
			var laserPoint:=lazerCastRef.get_collision_point()
			lazerMeshRef.visible=true
			lazerMeshRef.look_at(laserPoint, Vector3(0,1,0))
			lazerMeshRef.scale.z=global_position.distance_to(laserPoint)
			
			lazeredBody=weakref(lazerCastRef.get_collider())
			if isCanLazerBody():
				lazeredBody.get_ref().lazered()
		else:
			if isCanLazerBody():
				lazeredBody.get_ref().lazered(false)
			lazerSFXRef.stop()
			lazerMeshRef.visible=false
	elif Input.is_action_just_released(&"Shoot"):
		if isCanLazerBody():
			lazeredBody.get_ref().lazered(false)
		lazerSFXRef.stop()
		lazerMeshRef.visible=false

func isCanLazerBody()->bool:
	if lazeredBody and lazeredBody.get_ref() and lazeredBody.get_ref().has_method("lazered"):
		return true
	return false
