extends CanvasLayer

const MainMenuRef:String="res://UI/MainMenu/MainMenu.tscn"
@onready var menuSwitcherRef: TabContainer = %MenuSwitcher


func _ready() -> void:
	visible=false

func _on_continue_b_pressed() -> void:
	get_tree().paused=false
	visible=false
	#MobileButtons.setVisibility(true)

func setActive()->void:
	get_tree().paused=true
	visible=true
	#MobileButtons.setVisibility(false)

#func _on_restart_b_pressed() -> void:
	#get_tree().paused=false
	#visible=false
	#LevelManager.restartLevel()
	#MobileButtons.setVisibility(true)

func _on_exit_to_menu_b_pressed() -> void:
	get_tree().paused=false
	visible=false
	#LevelManager.toMainMenu()
	get_tree().change_scene_to_file.call_deferred(MainMenuRef)

func _onContinueBVisibilityChanged() -> void:
	if visible:
		%"Continue b".grab_focus.call_deferred()


func _on_options_b_pressed() -> void:
	menuSwitcherRef.current_tab=1
