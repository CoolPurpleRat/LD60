extends Panel

@export var games:Array[showGameResource]

@onready var gameTitleRef: Label = %GameTitle
@onready var gameButtonRef: TextureButton = %GameButton
@onready var cycleScreenshotTimerRef: Timer = %CycleScreenshotTimer
@onready var cycleGameTimerRef: Timer = %CycleGameTimer

@onready var screenshotListRef: HBoxContainer = %ScreenshotList
@onready var screenshotButtonTemplateRef: Button = %ScreenshotButtonTemplate

var gameURL:String
var currentScreenshot:int
var screenshotButtonListWRef:Array[WeakRef]
var currentGame:int=0

const screenshotNonactiveTime=1.0
const screenshotActiveTime=3.0

func _ready() -> void:
	setGame()	

##Change title and screenshots
func setGame()->void:
	#set game
	gameTitleRef.text=games[currentGame].Title
	gameButtonRef.texture_normal=games[currentGame].screenshots[0]
	gameURL=games[currentGame].url
	currentScreenshot=0
	
	#delete previous buttons
	for child in screenshotListRef.get_children():
		child.queue_free()
	screenshotButtonListWRef.clear()
	
	#create new buttons
	var count:int=0
	for screenshot in games[currentGame].screenshots:
		var newButton:=screenshotButtonTemplateRef.duplicate(15)
		screenshotListRef.add_child(newButton)
		newButton.visible=true
		newButton.id=count
		screenshotButtonListWRef.append(weakref(newButton))
		count+=1
		newButton.connect("pressedButton", screenshotListButtonPress)
	
	screenshotButtonListWRef[0].get_ref().setActive()
		
#region buttons
		
##Open game URL
func _on_game_button_pressed() -> void:
	OS.shell_open(gameURL)

##Switch to new game
func _on_next_game_pressed() -> void:
	currentGame+=1
	if currentGame>=games.size():
		currentGame=0
	setGame()
	cycleScreenshotTimerRef.start()

##Switch to previous game
func _on_previous_game_pressed() -> void:
	currentGame-=1
	if currentGame<=0:
		currentGame=games.size()-1
	setGame()
	cycleScreenshotTimerRef.start()

##Open specific screenshot and stop listing
func screenshotListButtonPress(id:int)->void:
	screenshotButtonListWRef[currentScreenshot].get_ref().setActive(false)
	
	currentScreenshot=id
	gameButtonRef.texture_normal=games[currentGame].screenshots[currentScreenshot]
	screenshotButtonListWRef[currentScreenshot].get_ref().setActive(true)
	cycleScreenshotTimerRef.stop()
#endregion

#region timers
##Go to next screenshot every 1-0.5 sec
func _on_cycle_screenshot_timer_timeout() -> void:
	screenshotButtonListWRef[currentScreenshot].get_ref().setActive(false)
	if (currentScreenshot+1)<games[currentGame].screenshots.size():
		currentScreenshot+=1
	else:
		currentScreenshot=0
	gameButtonRef.texture_normal=games[currentGame].screenshots[currentScreenshot]
	screenshotButtonListWRef[currentScreenshot].get_ref().setActive(true)

##Go to next game every 5 sec
func _on_cycle_game_timer_timeout() -> void:
	currentGame+=1
	if currentGame>=games.size():
		currentGame=0
	setGame()
#endregion

##List screenshots slower
func _on_mouse_entered() -> void:
	cycleScreenshotTimerRef.wait_time=screenshotActiveTime
	cycleGameTimerRef.stop()

##List screenshots slower
func _on_mouse_exited() -> void:
	cycleScreenshotTimerRef.wait_time=screenshotNonactiveTime
	cycleGameTimerRef.start()
	cycleScreenshotTimerRef.start()
