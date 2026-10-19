extends CharacterBody3D
class_name Player

const SPEED = 15.0
const JUMP_VELOCITY = 6.5

#TODO: setting to set it
@export var mouse_sensitivity: float = 0.3
var invertMouseY:=false

@onready var camera: Camera3D = $Camera3D
@onready var lazerCastRef: RayCast3D = %LazerCast
@onready var lazerMeshRef: Node3D = %LazerMeshPivot
@onready var lazerSFXRef: AudioStreamPlayer3D = %Fire
@onready var rightHandAnimRef: AnimationPlayer = %RightHandAnim
@onready var lazerEndRef: Node3D = %LazerEnd
@onready var cameraRef: Camera3D = %Camera3D

@export var checkpointRef:Marker3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_CAPTURED)
	PauseMenu.connect(&"mouseSettingsChanged", updateMouse)
	
func updateMouse()->void:
	mouse_sensitivity=PauseMenu.mouseSens
	invertMouseY=PauseMenu.InvertMouseY
	
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
		
	if event.is_action(&"ZoomIn"):
		zoom()
	elif event.is_action(&"ZoomOut"):
		zoom(false)
	elif event.is_action(&"ZoomRestore"):
		var newTween:=create_tween()
		newTween.set_ease(Tween.EASE_OUT)
		newTween.set_trans(Tween.TRANS_SPRING)
		newTween.tween_property(cameraRef, "fov", 75, 0.5)

func zoom(isIn:=true)->void:
	var newFov:float
	if isIn:
		newFov=cameraRef.fov-1
	else:
		newFov=cameraRef.fov+1
	cameraRef.fov=clampf(newFov, 10, 100)

var cameraXangle: float = 0.0
func _procCamera(event:InputEvent)->void:
	if event is InputEventMouseMotion:
		# Rotate left/right on the Y axis
		rotate_y(-deg_to_rad(event.relative.x * mouse_sensitivity))
		# Pitch up/down on the X axis with clamp
		cameraXangle += event.relative.y * mouse_sensitivity
		cameraXangle = clamp(cameraXangle, -90.0, 90.0)
		if not invertMouseY:
			camera.rotation.x = -deg_to_rad(cameraXangle)
		else:
			camera.rotation.x = deg_to_rad(cameraXangle)
		
var lazeredBody:WeakRef
func _lazerProc()->void:
	
	if Input.is_action_pressed(&"Shoot"):
		rightHandAnimRef.play(&"Fire")
		if lazerCastRef.is_colliding():
			lazerAnim()
			lazeredBody=weakref(lazerCastRef.get_collider())
			if isCanLazerBody():
				lazeredBody.get_ref().lazered()
		else:
			lazerAnim(false)
			if isCanLazerBody():
				lazeredBody.get_ref().lazered(false)
	elif Input.is_action_just_released(&"Shoot"):
		if isCanLazerBody():
			lazeredBody.get_ref().lazered(false)
		lazerAnim(false)

func lazerAnim(on:=true)->void:
	if not on:
		rightHandAnimRef.play(&"Idle")
		lazerSFXRef.stop()
		lazerMeshRef.visible=false
		lazerEndRef.visible=false
	else:
		rightHandAnimRef.play(&"Fire")
		lazerMeshRef.visible=true
		lazerEndRef.visible=true
		
		MusicSystem.playSfx(lazerSFXRef, 0.5, 0.8)
		var laserPoint:=lazerCastRef.get_collision_point()
		lazerMeshRef.look_at(laserPoint, Vector3(0,1,0))
		var distance:float=lazerMeshRef.global_position.distance_to(laserPoint)
		lazerMeshRef.scale.z=distance
		lazerMeshRef.scale.x=clamp(30/distance, 0.5, 5)
		lazerMeshRef.scale.y=clamp(30/distance, 0.5, 5)
		lazerEndRef.global_position=laserPoint

func isCanLazerBody()->bool:
	if lazeredBody and lazeredBody.get_ref() and lazeredBody.get_ref().has_method("lazered"):
		return true
	return false

func respawn()->void:
	global_position=checkpointRef.global_position
