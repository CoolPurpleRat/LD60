extends Node

#region Refs
##Audio for all buttons in group UIButton
@onready var uiBSoundRef: AudioStreamPlayer = %UIButtonSound

@onready var MusicPlayerRef:AudioStreamPlaybackInteractive=%MusicPlayer.get_stream_playback()
#endregion

#region Play music
##List with all music
const musicList:Dictionary={
	MENU="Menu"}

##Curently playing music
var playingMusic:StringName=" "
##Last level 
var lvlName:StringName

##Play music with no duplication
func playMusic(nameMusic:StringName)->void:
	if not musicList.has(nameMusic):
		push_error(nameMusic, " not found! MusicSystem")
		return
	if (not nameMusic==playingMusic):
		MusicPlayerRef.switch_to_clip_by_name(nameMusic)
		playingMusic=nameMusic
		lvlName=""

##If level uses alternative tracks, and you dont want to switch constantly
func playMusicWithAlt(nameMusic:StringName, userName:StringName=" ")->void:
	if not musicList.has(nameMusic):
		push_error(nameMusic, " not found! MusicSystem")
		return
	if (not nameMusic==playingMusic) and (not userName==lvlName):
		MusicPlayerRef.switch_to_clip_by_name(nameMusic)
		playingMusic=nameMusic
		lvlName=userName

#endregion


##Plays sfx with slight pitch variation
func playSfx(ref:Variant, minRange:float=0.5, maxRange:float=1)->void:
	if not ref.playing:
		ref.pitch_scale=randf_range(minRange, maxRange)
		ref.play()

#region UI buttons SFX
##Add sfx to buttons
func _ready() -> void:
	getButtons()
	get_tree().connect("scene_changed", getButtons)

##Get all UI buttons from group
func getButtons()->void:
	var buttons: Array = get_tree().get_nodes_in_group("UIButton")
	for inst:Control in buttons:
		if inst.has_signal("pressed"):
			if not inst.is_connected("pressed", buttonSFX):
				inst.connect("pressed", buttonSFX)
		else:
			push_error(inst.get_path(), inst.name, "dont has PRESSED signal for UI button sound")

##Default sfx for all UI buttons
func buttonSFX()->void:
	playSfx(uiBSoundRef, 1.2, 1.5)
#endregion
