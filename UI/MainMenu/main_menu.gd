extends Control

#region References
@onready var continueBRef: Button = %"Continue b"
@onready var menuSwitcherRef: TabContainer = %MenuSwitcher
#endregion
enum menuTabs{MAIN, OPTIONS, CREDITS}

var loadingLevelPath:String="res://Levels/Map.tscn"
func preloadLevel(newLevelPath:String)->void:
	ResourceLoader.load_threaded_request(newLevelPath)
	loadingLevelPath=newLevelPath

func _ready() -> void:
	menuSwitcherRef.current_tab=menuTabs.MAIN
	preloadLevel(loadingLevelPath)
	#MusicSystem.playMusic(MusicSystem.MENU)
	#MobileButtons.setVisibility(false)

	#Hide exit, because OS handle it.
	if OS.has_feature("web") or OS.has_feature("mobile"):
		%"Exit b".visible=false
	startFocus.call_deferred()

#region Focus
##When first menu tab visible, set their focus on first element
#func _onLvlChooseBVisibilityChanged() -> void:
	#startFocus.call_deferred()

##Set focus on starting element for controller/keybord navigation
func startFocus()->void:
	#if continueBRef.visible:
	#	continueBRef.grab_focus()
	#elif lvlChooseBRef.visible:
		#lvlChooseBRef.grab_focus()
	pass
#endregion

#region Buttons
##Exit game
func _on_exit_b_pressed() -> void:
	get_tree().quit()

func _on_options_b_pressed() -> void:
	menuSwitcherRef.current_tab=menuTabs.OPTIONS

func _on_credits_b_pressed() -> void:
	menuSwitcherRef.current_tab=menuTabs.CREDITS
#endregion


func _on_play_pressed() -> void:
	#get_tree().change_scene_to_packed(MAP)
	##Заміна на пред загрузку
	var Level:PackedScene=ResourceLoader.load_threaded_get(loadingLevelPath) as PackedScene
	if Level:
		get_tree().change_scene_to_packed.call_deferred(Level)
		loadingLevelPath = ""
		return
	###Стара загрузка
	get_tree().change_scene_to_file.call_deferred(loadingLevelPath)
	
func _on_l_dbutton_pressed() -> void:
	OS.shell_open("https://ldjam.com/users/coolpurplerat/")
