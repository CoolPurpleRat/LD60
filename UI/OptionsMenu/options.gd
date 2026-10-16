extends Control

var saveOptionsPath:="user://options.save"
static var ToSave:Dictionary

var masterBus:=AudioServer.get_bus_index("Master")
var musicBus:=AudioServer.get_bus_index("Music")
var sfxBus:=AudioServer.get_bus_index("SFX")
@onready var tabContainerRef:TabContainer=%TabContainer

enum Tabs{Audio, Video, PCInput, MobInput, Game}

func _ready() -> void:
	if not ToSave:
		loadOptions()
	setButtonsValues()
	tabContainerRef.current_tab=0
	#Якщо на мобільці
	if OS.has_feature("mobile"):
		tabContainerRef.set_tab_hidden(Tabs.PCInput, true)
	else:
		tabContainerRef.set_tab_hidden(Tabs.MobInput, true)
	#if (not ToSave):
		#TranslationServer.set_locale("en")
	visible=false


#region Екран
func _on_full_screen_b_item_selected(index: int) -> void:
	match index:
		#Повний екран
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		#У вікні
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		#Екзклюзівний повний
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_resolution_choose_resolution_change(resolution:Vector2i) -> void:
	DisplayServer.window_set_size(resolution)

func _on_v_syns_drop_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		3:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
#endregion

#region звук
func _on_turn_off_sound_b_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(masterBus,toggled_on)

func changeAudioVolume(bus:int, value:float)->void:
	AudioServer.set_bus_volume_linear(bus, value)
	%AudioTest.volume_linear=AudioServer.get_bus_volume_linear(bus)
	%AudioTest.play()


#endregion

##region Збереження і загрузка
#func _on_delete_progress_b_pressed() -> void:
	#SaveManager.deleteProgress()

func saveOptions()->void:
	var file := FileAccess.open(saveOptionsPath, FileAccess.WRITE)
	ToSave["fullScreen"]=DisplayServer.window_get_mode()
	ToSave["ScreenResolution"]=DisplayServer.window_get_size()
	ToSave["Vsyns"]=DisplayServer.window_get_vsync_mode()
	ToSave["AudioOff"]=AudioServer.is_bus_mute(masterBus)
	ToSave["MasterAudio"]=AudioServer.get_bus_volume_linear(masterBus)
	ToSave["MusicAudio"]=AudioServer.get_bus_volume_linear(musicBus)
	ToSave["SFXAudio"]=AudioServer.get_bus_volume_linear(sfxBus)
	
	#ToSave["MobileButtonsOpacity"]=MobileButtons.getOpacity()
	#ToSave["Language"]=TranslationServer.get_locale()
	file.store_var(ToSave)
	file.close()

func loadOptions()->void:
	if not FileAccess.file_exists(saveOptionsPath):
		return

	var file := FileAccess.open(saveOptionsPath, FileAccess.READ)
	ToSave=file.get_var()
	if ToSave.has("MasterAudio"):AudioServer.set_bus_volume_linear(masterBus, ToSave["MasterAudio"])
	if ToSave.has("MusicAudio"):AudioServer.set_bus_volume_linear(musicBus, ToSave["MusicAudio"])
	if ToSave.has("SFXAudio"):AudioServer.set_bus_volume_linear(sfxBus, ToSave["SFXAudio"])
	if ToSave.has("AudioOff"):AudioServer.set_bus_mute(0, ToSave["AudioOff"])
	#if ToSave.has("MobileButtonsOpacity"):MobileButtons.buttonOpacity=ToSave["MobileButtonsOpacity"]
	#if ToSave.has("Language"):TranslationServer.set_locale(ToSave["Language"])
	#Display operations are heavy. Its reduce function in ~2x time
	if ToSave.has("fullScreen"):DisplayServer.call_deferred("window_set_mode", ToSave["fullScreen"])
	if ToSave.has("ScreenResolution"):DisplayServer.call_deferred("window_set_size", ToSave["ScreenResolution"])
	if ToSave.has("Vsyns"):DisplayServer.call_deferred("window_set_vsync_mode", ToSave["Vsyns"])
	file.close()

func _on_hidden() -> void:
	saveOptions()

func setButtonsValues()->void:
	setBut("AudioOff", %TurnOffSound_b, "button_pressed")
	setBut("fullScreen", %FullScreen_B, "selected")
	setBut("VSyns", %VSyns_drop, "selected")
	setBut("MasterAudio", %Sound_Slider, "value")	
	setBut("MusicAudio", %Music_Slider, "value")	
	setBut("SFXAudio", %SFX_Slider, "value")	
	setBut("ScreenResolution", %ResolutionChoose, "windowResolution")
	await get_tree().physics_frame
	#if ToSave.has("MobileButtonsOpacity"):%ScreenTouchVisibility_Slider.value=ToSave["MobileButtonsOpacity"]
#endregion

func _onVisibilityChanged() -> void:
	if visible and tabContainerRef:
		tabContainerRef.get_tab_bar().grab_focus.call_deferred()
	if visible:
		setButtonsValues()

#region Button pressed

#func _on_screen_touch_visibility_slider_value_changed(value: float) -> void:
	#MobileButtons.setOpacity(value)

func _onDeleteConfigBPressed() -> void:
	if FileAccess.file_exists("user://keymaps.dat"):
		DirAccess.remove_absolute("user://keymaps.dat")
	if FileAccess.file_exists(saveOptionsPath):
		DirAccess.remove_absolute(saveOptionsPath)
	get_tree().quit.call_deferred()

#func _onLanguageSwitchPressed() -> void:
	#if TranslationServer.get_locale()=="uk":
		#TranslationServer.set_locale("en")
	#else:
		#TranslationServer.set_locale("uk")

func _onSoundSliderDragEnded(value_changed: bool) -> void:
	if value_changed:
		changeAudioVolume(masterBus, %Sound_Slider.value)

func _onMusicSliderDragEnded(value_changed: bool) -> void:
	if value_changed:
		changeAudioVolume(musicBus, %Music_Slider.value)

func _onSfxSliderDragEnded(value_changed: bool) -> void:
	if value_changed:
		changeAudioVolume(sfxBus, %SFX_Slider.value)

func _onTabContainerTabClicked(_tab: int) -> void:
	MusicSystem.buttonSFX()
#endregion

##Saves property from object to ToSave
func saveOpt(fromObj:Variant, propertyName:StringName, withName:StringName="")->void:
	var saveName:=withName if not withName.is_empty() else propertyName
	ToSave[saveName]=fromObj.get(propertyName)

##Sets button's value
func setBut(optName:StringName, toObj:Control, property:StringName)->void:
	if optName in ToSave:
		toObj.set(property, ToSave[optName])
