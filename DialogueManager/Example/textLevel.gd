extends Node2D

const isContinue=true
const notFinish=false

func _ready() -> void:
	#TranslationServer.set_locale("uk")
	PopupManager.popUp(tr("hello"))
	PopupManager.popUp(tr("This is [color=yellow]popUps[img height=1em]res://icon.svg[/img]"))
	PopupManager.popUp(tr("very looooooooooooooooong pop ups"), 20)
	PopupManager.popUp(tr("bye!"))
	
	const char1=&"Mi"
	const char2=&"Re"
	var char3:=tr("Persik")
	
	await DM.startDialogue()
	DM.addCharToDial(char1, true, DM.charPositions.center)
	DM.changePortr(char1, "Happy")
	await DM.dialogue(tr("Helloooooooooooooooooooooooooooo"), char1)
	DM.moveChar(char1, DM.charPositions.left)
	DM.changePortr(char1, "Normal")
	await DM.dialogue(tr("Blablaaaaaaaaaaaaaaaaaaaaaaaaa"), char1)
	DM.showChar(char1, false)
	await DM.dialogue(tr("Blablaaaaaaaaaaaaaaaaaaaaaaaaa"), char1)
	DM.showChar(char1, true)
	#Pause messages
	DM.addCharToDial(char2, true, DM.charPositions.right)
	await DM.dialogue(tr("Part one of message \n"), char2, not isContinue, notFinish)
	DM.changePortr(char2, "Angry")
	await DM.dialogue(tr("Part two of message"), char2, isContinue)
	DM.changePortr(char2, "Normal")	
	#choices
	var choice:=await DM.showChoice([DM.buttonState.new(tr("One")), DM.buttonState.new(tr("Two"))])
	await DM.dialogue(tr("You choosed: ")+var_to_str(choice))
	
	#loops
	var loopChoice:=1
	await DM.dialogue(tr("I am in timeloop??? "), char2)
	DM.SaveHistory=false
	while loopChoice==1:
		loopChoice=await DM.showChoice(\
		[DM.buttonState.new(tr("LETS LOOOP")), DM.buttonState.new(tr("Nah, I'm done"))])
		if loopChoice==1:
				DM.changePortr(char1, "Happy")
				DM.changePortr(char2, "Angry")
				DM.flipChar(char2)
				await DM.dialogue(tr("[shake] Aw dang it[/shake]\n"), "", isContinue)
	DM.unflipChar(char2)
	DM.changePortr(char1, "Normal")
	DM.changePortr(char2, "Normal")
	DM.SaveHistory=true
	
	#choice with conditions
	await DM.dialogue(tr("Choice with conditions"), char1)
	var choiceOne:=DM.buttonState.new(tr("1. ChoiceHidden1 (hide:first choice == 1)"))
	choiceOne.hidden= choice==1
	var choiceTwo:=DM.buttonState.new(tr("2. ChoiceLocked (lock:Escaped loop)"))
	choiceTwo.locked= loopChoice==2
	await DM.showChoice([choiceOne, choiceTwo, DM.buttonState.new(tr("3. Normal"))])
	
	await DM.dialogue(tr("End of dialogue"))
	await DM.endDialogue()
	
	await DM.startDialogue()
	await DM.dialogue(tr("Test of second dialogue"), char3)
	await DM.endDialogue()
