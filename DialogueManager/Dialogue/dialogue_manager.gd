@icon("res://DialogueManager/SpeachBubble.png")
class_name DialogueManager
extends Control

##WARNING DM commands, except char commands, must start with await, and every text with tr()
##example of usage:
##startDialogue()
##await DM.dialogue(tr("Hello"))
##await endDialogue()

signal _progressDialogue()
#region References
#region Characters & positions
@onready var _leftPos: Control = %LeftPos
@onready var _centerPos: Control = %CenterPos
@onready var _rightPos: Control = %RightPos
@onready var _farLeftPos: Control = %FarLeftPos
@onready var _farRightPos: Control = %FarRightPos
#endregion

#region chat dialogue parts
@onready var _charNameDisplayRef: RichTextLabel = %CharacterNameDisplay
@onready var _dialogueTextRef: RichTextLabel = %DialogueText
@onready var _chatHistoryRef: RichTextLabel = %ChatHistory
@onready var _progressDialogueButtonRef: Button = %ProgressDialogue
@onready var _choicesRef: GridContainer = %Choices
@onready var _choiceButtonRef: AnimatedButton = %ChoiceButton
@onready var _dialogueAnimRef: AnimationPlayer = %DialogueAnim
#endregion

#region autoprogress
@onready var _autoProgressTimerRef: Timer = %AutoProgressTimer
@onready var _autoProgressBarRef: TextureProgressBar = %AutoProgressBar
#endregion

#region SFX
@onready var defaultSfxRef: AudioStreamPlayer = %DefaultSFX
@onready var playDefaultSFXRef: Timer = %PlayDefaultSound
#endregion

#endregion References

#region Text control
var skipAllText:=false ##Automaticaly skips all dialogue, untill animation or choice
var textSpeed:=1 ##How fast text displayed
const _PerCharTime:=0.1 ##How long 1 character typed
var SaveHistory:=true ##Save text to box on top of chat
var autoProgress:=false ##After text finished, wait a little and auto progress

#endregion

#region Characters
@onready var charArchive:Dictionary[StringName, DialogueCharacter]={
	&"Mi":%Mi,
	&"Re":%Re}
	
var translatedNames:Dictionary[StringName, String]={
	&"Mi":tr("Mi"),
	&"Re":tr("Re")
	}
	
var charsInDialogue:Dictionary[StringName, DialogueCharacter]
enum charPositions{center, left, right, farLeft, farRight}
#endregion

func _ready() -> void:
	visible=false
	
func _process(_delta: float) -> void:
	#auto progress animation
	if not _autoProgressTimerRef.is_stopped():
		_autoProgressBarRef.visible=true
		_autoProgressBarRef.value=_autoProgressTimerRef.time_left/_autoProgressTimerRef.wait_time
	else:
		_autoProgressBarRef.visible=false

#var _previousFOwner:Control ##For focus debug
###Focus debug
#func debugFocus()->void:
	#await get_viewport().gui_focus_changed
	#var currentFOwner:Control=get_viewport().gui_get_focus_owner()
	#if not currentFOwner:
		#return
	#if not _previousFOwner:
		#_previousFOwner=currentFOwner
	#if _previousFOwner!=currentFOwner:
		#_previousFOwner.modulate=Color(1.0, 1.0, 1.0, 1.0)
		#_previousFOwner=currentFOwner
	#currentFOwner.modulate=Color(1.0, 0.0, 0.0, 1.0)

##Resets and clears parameters
func _resetDialogue()->void:
	skipAllText=false
	
	_charNameDisplayRef.text=""
	_dialogueTextRef.text=""
	_chatHistoryRef.text=""
	
	_chatHistoryRef.scroll_active=false
	_choicesRef.visible=false
	setTweeners()
	
#region chat commands
##Set everything to default and show dialogue window
func startDialogue()->void:
	_resetDialogue()
	visible=true
	
	if not charsInDialogue.is_empty():
		for character:DialogueCharacter in charsInDialogue.values():
			character.modulate=Color(0.0, 0.0, 0.0, 0.0)
		charsInDialogue.clear()
	_dialogueAnimRef.play(&"Start")
	await _dialogueAnimRef.animation_finished
	
var _previousCharName:StringName
##Show dialogue. isContinue means its part of bigger dialogue. if not isFinish its dont record history
func dialogue(someText:String, charName:StringName="", isContinue:=false, isFinish:=true)->void:
	_progressDialogueButtonRef.grab_focus()
		
	var charRef:DialogueCharacter
	if isContinue and not _previousCharName.is_empty():
		charName=_previousCharName
	_previousCharName=charName
	if charName in charsInDialogue:
		charRef=charsInDialogue[charName]
		charName=translatedNames[charName]
		
	#Update name display
	if not charName.is_empty():	
		_charNameDisplayRef.text=charName
		_charNameDisplayRef.visible=true
	else:
		_charNameDisplayRef.visible=false
	
	if not charRef:
		playDefaultSFXRef.start()
	
#update dialogue window
	var oldTextLength:float
	if isContinue:oldTextLength=_dialogueTextRef.text.length()
	else:_dialogueTextRef.text=""
	_dialogueTextRef.text+=someText
	
#skip animation
	if skipAllText:
		if isFinish:addToChatHistory(_dialogueTextRef.text, charName)
		return
		
#text animation
	_dialogueTextRef.visible_ratio=0.0
	if isContinue:
		_dialogueTextRef.visible_ratio=(oldTextLength)/_dialogueTextRef.text.length()	
	var textTweener:=create_tween()
	textTweener.set_ease(_tweenEasing).set_trans(_tweenTransition)
	if charRef:charRef.talkAnim(true)
	if isContinue:
		textTweener.tween_property(_dialogueTextRef, "visible_ratio", 1, \
			textSpeed*(_dialogueTextRef.text.length()-oldTextLength)*_PerCharTime*textSpeed)
	else:
		textTweener.tween_property(_dialogueTextRef, "visible_ratio", 1, \
			textSpeed*_dialogueTextRef.text.length()*_PerCharTime*textSpeed)
#On animation end
	textTweener.finished.connect(
		func()->void:
			playDefaultSFXRef.stop()
			if charRef:
				charRef.talkAnim(false)
			if autoProgress:
				_autoProgressTimerRef.start(_dialogueTextRef.text.length()*_PerCharTime*2))
#Animation end or force stop
	await _progressDialogue
#Stop animation
	if charRef:charRef.talkAnim(false)
	playDefaultSFXRef.stop()
#If force stop
	if _dialogueTextRef.visible_ratio<1:
		textTweener.stop()
		_dialogueTextRef.visible_ratio=1
		await _progressDialogue
#end	
	if isFinish:addToChatHistory(_dialogueTextRef.text, charName)

var _tweenEasing:=Tween.EaseType.EASE_IN
var _tweenTransition:=Tween.TransitionType.TRANS_LINEAR
##Sets how dialogue text revealed or character moved.
func setTweeners(easing:=Tween.EaseType.EASE_IN, transition:=Tween.TransitionType.TRANS_LINEAR)->void:
	_tweenEasing=easing
	_tweenTransition=transition

#region Character portrait commands
##Change portrait of character.	
func changePortr(CharName:StringName, portrait:StringName)->void:
	if not CharName in charsInDialogue:
		push_error("There is no character with that name in dialogue:"+CharName)
		return
	var charRef:DialogueCharacter=charsInDialogue[CharName]
	charRef.changePortrait(portrait)

##Add character to dialogue
func addCharToDial(CharName:StringName, showAlready:bool, charPos:charPositions)->void:
	if not CharName in charArchive:
		push_error("MD dont has "+CharName +" in archive")
		return
	if CharName in charsInDialogue:
		push_warning("Character "+CharName+" already in dialogue")
		return
	var CharRef:DialogueCharacter=charArchive[CharName]
	charsInDialogue[CharName]=CharRef
	CharRef.unflip()
	
	if showAlready: 
		showChar(CharName, showAlready)
	else:
		CharRef.modulate=Color(0, 0, 0, 0)
	
	match charPos:
		charPositions.center:CharRef.global_position=_centerPos.global_position
		charPositions.left:CharRef.global_position=_leftPos.global_position
		charPositions.right:CharRef.global_position=_rightPos.global_position
		charPositions.farLeft:CharRef.global_position=_farLeftPos.global_position
		charPositions.farRight:CharRef.global_position=_farRightPos.global_position

##Move character to one of charPositions
func moveChar(CharName:StringName, charPos:charPositions, animDur:=0.5)->void:
	if not CharName in charsInDialogue:
		push_error("There is no character with that name in dialogue:"+CharName)
		return
	
	var charRef:DialogueCharacter=charsInDialogue[CharName]
	var posTweener:=create_tween()
	posTweener.set_ease(_tweenEasing).set_trans(_tweenTransition)
	var newPos:Vector2
	match charPos:
		charPositions.center:newPos=_centerPos.global_position
		charPositions.left:newPos=_leftPos.global_position
		charPositions.right:newPos=_rightPos.global_position
		charPositions.farLeft:newPos=_farLeftPos.global_position
		charPositions.farRight:newPos=_farRightPos.global_position
	posTweener.tween_property(charRef, "global_position", newPos, animDur)

##Change character visibility
func showChar(CharName:StringName, isShow:=true)->void:
	if not CharName in charsInDialogue:
		push_error("There is no character with that name in dialogue:"+CharName)
		return
		
	var charRef:DialogueCharacter=charsInDialogue[CharName]
	var charColorTween:=create_tween()
	if isShow:
		charRef.modulate=Color(0.0, 0.0, 0.0, 0.0)
		charColorTween.tween_property(charRef, "modulate", Color.WHITE, 0.2)
	else:
		charRef.modulate=Color.WHITE
		charColorTween.tween_property(charRef, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2)

##Flip on X
func flipChar(CharName:StringName)->void:
	if not CharName in charsInDialogue:
		push_error("There is no character with that name in dialogue:"+CharName)
		return
	var charRef:DialogueCharacter=charsInDialogue[CharName]
	charRef.flipChar()

##Unflip if flipped
func unflipChar(CharName:StringName)->void:
	if not CharName in charsInDialogue:
		push_error("There is no character with that name in dialogue:"+CharName)
		return
	var charRef:DialogueCharacter=charsInDialogue[CharName]
	charRef.unflip()
#endregion

##Adds text to box on top of chat
func addToChatHistory(someText:String, charName:String="")->void:
	if not SaveHistory:
		return
	if not charName.is_empty():
		_chatHistoryRef.text+=tr(charName)+":"+someText+"\n"
	else:
		_chatHistoryRef.text+=someText+"\n"
	if _chatHistoryRef.get_line_count()>9:
		_chatHistoryRef.scroll_active=true


#region Choice buttons
##Player choosed something
signal _choice()
var _choiceNumb:=-1
##Choice button state, which can be locked or hidded
class buttonState:
	var name:="choice 0"
	var hidden:=false
	var locked:=false
	func _init(userName:String) -> void:
		name=userName
##On choice button pressed
func _ChoicePressed(id:int) -> void:
	_choiceNumb=id
	_choice.emit()
	
##Creates buttons with choices.
func showChoice(choices:Array[buttonState])->int:
	skipAllText=false
	for child in _choicesRef.get_children():
		child.queue_free()
	
	#spawn buttons
	var counter:=1
	var previousButtonRef:Button=null
	var grabbedFocus:=false
	for button in choices:
		var buttonRef:=_choiceButtonRef.duplicate()
		_choicesRef.add_child(buttonRef)
		buttonRef.text=button.name
		if button.hidden:
			buttonRef.visible=false
		if button.locked:
			buttonRef.disabled=true

		if not (button.hidden or button.locked) and not grabbedFocus:
			buttonRef.grab_focus()
			grabbedFocus=true
		#Setting focus
		if counter==1:
			buttonRef.focus_neighbor_top=_progressDialogueButtonRef.get_path()
			
			_progressDialogueButtonRef.focus_next=buttonRef.get_path()
			_progressDialogueButtonRef.focus_neighbor_right=buttonRef.get_path()
			_progressDialogueButtonRef.focus_neighbor_bottom=buttonRef.get_path()
		if is_instance_valid(previousButtonRef):
			previousButtonRef.focus_next=buttonRef.get_path()
			previousButtonRef.focus_neighbor_bottom=buttonRef.get_path()
			previousButtonRef.focus_neighbor_right=buttonRef.get_path()

			buttonRef.focus_neighbor_top=previousButtonRef.get_path()
			buttonRef.focus_neighbor_left=previousButtonRef.get_path()
		
		buttonRef.pressed.connect(_ChoicePressed.bind(counter))
		previousButtonRef=buttonRef
		counter+=1
		
	_choicesRef.visible=true
	await _choice
	
	#reset focus
	_progressDialogueButtonRef.focus_next=_chatHistoryRef.get_path()
	_progressDialogueButtonRef.focus_neighbor_right=_chatHistoryRef.get_path()
	_progressDialogueButtonRef.focus_neighbor_bottom=_chatHistoryRef.get_path()
	
	if SaveHistory:
		addToChatHistory(tr("You choosed: ")+choices[_choiceNumb-1].name)
	_choicesRef.visible=false
	return _choiceNumb
#endregion

##Closses Dialogue manager
func endDialogue()->void:
	if skipAllText:
		await _progressDialogueButtonRef.pressed
	for characterName:StringName in charsInDialogue.keys():
		showChar(characterName, false)
	await get_tree().create_timer(0.2).timeout #Await when all characters hidden 
	visible=false
#endregion

#region buttons
func _on_skip_all_text_pressed() -> void:
	skipAllText=true
	_progressDialogue.emit() #end animation
	_progressDialogue.emit() #skip text

func _on_auto_progress_b_toggled(toggled_on: bool) -> void:
	autoProgress=toggled_on
	if not toggled_on:
		_autoProgressTimerRef.stop()

func _on_progress_dialogue_pressed() -> void:
	_progressDialogue.emit()
#endregion

#region Timers
func _on_auto_progress_timer_timeout() -> void:
	_progressDialogue.emit()

func _on_play_default_sound_timeout() -> void:defaultSfxRef.play()
#endregion
