@tool
extends Node3D
class_name vine

signal vineDied

@export_tool_button("Redraw vines") var redrawVines:Callable=redrawVinesFunDebug
@export var points:Array[Marker3D]:
	set(value):
		points=value
		if Engine.is_editor_hint():
			redrawVinesFunDebug()
@export_range(0.1, 60, 0.1, "or_greater") var regrowTime:float=1
@export_range(0.0, 5, 0.1, "or_greater") var vineWidth:float=0.3:
	set(value):
		vineWidth=value
		if vineDrawRef:
			vineDrawRef.base_radius=value

var activePoints:Array[Marker3D]
var vineHurtCols:Array[vineHurtCol]

@onready var regrowTimerRef: Timer = %RegrowTimer

@onready var vineDrawRef:vineDrawer = %VineDraw
@onready var path:Path3D= %Path3D
const vineHurtColRes = preload("uid://dlpabhcdpbk8w")

var lastPointId:int=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		redrawVinesFunDebug()
		return
	for point in points:
		path.curve.add_point(point.global_position)
	activePoints=points.duplicate()
	vineDrawRef.base_radius=vineWidth
	redrawVinesFun()

	for pointId in points.size():	
		var vineHurtColIns:vineHurtCol=vineHurtColRes.instantiate()
		add_child(vineHurtColIns)
		if pointId==points.size()-1:
			vineHurtColIns.canDie=true
		vineHurtColIns.global_position=points[pointId].global_position
		vineHurtColIns.dead.connect(pointDied.bind(pointId))
		vineHurtColIns.hurt.connect(pointHurt)
		vineHurtColIns.canRegrow.connect(pointNotHurt)
		vineHurtCols.append(vineHurtColIns)
	regrowTimerRef.wait_time=regrowTime

##redraw in game
func redrawVinesFun()->void:
	path.curve.clear_points()
	for point in activePoints:
		path.curve.add_point(point.global_position)
	vineDrawRef._generate_vine()

##redraw in editor
func redrawVinesFunDebug()->void:
	if points.size()<2:
		push_warning(get_path(), " has no points")
	if not path:
		return
	path.curve.clear_points()
	activePoints=points.duplicate()
	for point in activePoints:
		path.curve.add_point(point.global_position)
	vineDrawRef._generate_vine()

func pointDied(pointId:int)->void:
	if pointId==1:
		emit_signal("vineDied")
		regrowTimerRef.stop()
		visible=false
	else:
		lastPointId=pointId-1
		activePoints.remove_at(activePoints.size()-1)
		redrawVinesFun()
		vineHurtCols[pointId-1].canDie=true
		vineHurtCols[pointId-1].collisionRef.set_deferred("disabled", false)
	regrowTimerRef.start()

func pointHurt()->void:
	regrowTimerRef.stop()

func pointNotHurt()->void:
	regrowTimerRef.start()

func _on_regrow_timer_timeout() -> void:
	if activePoints.size()==points.size():
		regrowTimerRef.stop()
		return
	activePoints.append(points[activePoints.size()])
	vineHurtCols[activePoints.size()-1].canDie=true
	vineHurtCols[activePoints.size()-1].collisionRef.set_deferred("disabled", false)
	vineHurtCols[activePoints.size()-2].canDie=false

	redrawVinesFun()
