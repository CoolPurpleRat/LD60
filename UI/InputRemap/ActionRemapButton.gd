extends AnimatedButton

#Originally from oficial demo
#Added normal name, mouse, gamepad, modificators(shift, Ctrl)

##What action does this key remap
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var action: StringName = "ui_up"

func _ready()->void:
	super()
	assert(InputMap.has_action(action))
	set_process_input(false)
	display_cleanText()

func _toggled(is_button_pressed:bool)->void:
	set_process_input(is_button_pressed)
	if is_button_pressed:
		text = "<press a key>"
		release_focus()
	else:
		display_cleanText()

func _input(event:InputEvent)->void:
	#Ignore mouse move, because its insta skip
	if event is InputEventMouseMotion:
		return
	if event.is_pressed():
		remap_action_to(event)
		button_pressed = false
		#Eat input
		get_viewport().set_input_as_handled()
		grab_focus.call_deferred()

func remap_action_to(event:InputEvent)->void:
	# We first change the event in this game instance.
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	# And then save it to the keymaps file
	KeyPersistence.keymaps[action].clear()
	KeyPersistence.keymaps[action].append(event) # =
	KeyPersistence.save_keymap()
	text = event.as_text()

func display_cleanText() -> void:
	var keysText: Array[String] = []

	for event in InputMap.action_get_events(action):
		var cleanText: String = ""

		#Keybord key with Alt, Ctrl etc.
		if event is InputEventWithModifiers:
			if event.physical_keycode != KEY_NONE:
				cleanText = OS.get_keycode_string(event.physical_keycode)
			else:
				cleanText = OS.get_keycode_string(event.keycode)
			if event.alt_pressed:
				cleanText="Alt+"+cleanText
			if event.shift_pressed:
				cleanText="Shift+"+cleanText
			if event.meta_pressed:
				cleanText="Win+"+cleanText
			if event.is_command_or_control_pressed():
				cleanText="Ctrl/Cmd+"+cleanText
			
			cleanText=cleanText.replace("Kp", "NUM")
			cleanText=cleanText.replace("Left", "←")
			cleanText=cleanText.replace("Right", "→")
			cleanText=cleanText.replace("Down", "↓")
			cleanText=cleanText.replace("Up", "↑")
			cleanText=cleanText.replace("Multiply", "*")
			cleanText=cleanText.replace("Subtract", "/")
			cleanText=cleanText.replace("Equal","=")
			cleanText=cleanText.replace("Minus","-")
			cleanText=cleanText.replace("Enter","↵")
		elif event is InputEventMouseButton:
			cleanText=event.as_text()
		elif event is InputEventJoypadButton:
			cleanText="🎮"
			match event.button_index:
				JOY_BUTTON_A:cleanText+="face↓"
				JOY_BUTTON_B:cleanText+="face→"
				JOY_BUTTON_X:cleanText+="face←"
				JOY_BUTTON_Y:cleanText+="face↑"
				JOY_BUTTON_BACK:cleanText+="Back/Select"
				JOY_BUTTON_GUIDE:cleanText+="Home/Guide"
				JOY_BUTTON_START:cleanText+="Start/Menu"
				JOY_BUTTON_LEFT_STICK:cleanText+="LStick"
				JOY_BUTTON_RIGHT_STICK:cleanText+="RStick"
				JOY_BUTTON_LEFT_SHOULDER:cleanText+="LShoulder"
				JOY_BUTTON_RIGHT_SHOULDER:cleanText+="RShoulder"
				JOY_BUTTON_DPAD_UP:cleanText+="D-pad ↑"
				JOY_BUTTON_DPAD_DOWN:cleanText+="D-pad ↓"
				JOY_BUTTON_DPAD_LEFT:cleanText+="D-pad ←"
				JOY_BUTTON_DPAD_RIGHT:cleanText+="D-pad →"
				JOY_BUTTON_MISC1:cleanText+="Share"
				JOY_BUTTON_PADDLE1:cleanText+="XPaddle1"
				JOY_BUTTON_PADDLE2:cleanText+="XPaddle2"
				JOY_BUTTON_PADDLE3:cleanText+="XPaddle3"
				JOY_BUTTON_PADDLE4:cleanText+="XPaddle4"
				JOY_BUTTON_TOUCHPAD:cleanText+="Touchpad"
				_:
					cleanText="🎮"+str(event.button_index)
		elif event is InputEventJoypadMotion:
			#For gamepad sticks
			match event.axis:
				JOY_AXIS_LEFT_X:
					cleanText="L🕹️"
					if event.axis_value<0:
						cleanText+="←"
					else:
						cleanText+="→"
				JOY_AXIS_LEFT_Y:
					cleanText="L🕹️"
					if event.axis_value<0:
						cleanText+="↑"
					else:
						cleanText+="↓"
				JOY_AXIS_RIGHT_X:
					cleanText="R🕹️"
					if event.axis_value<0:
						cleanText+="←"
					else:
						cleanText+="→"
				JOY_AXIS_RIGHT_Y:
					cleanText="R🕹️"
					if event.axis_value<0:
						cleanText+="↑"
					else:
						cleanText+="↓"
				JOY_AXIS_TRIGGER_LEFT:
					cleanText="🎮LeftTrigger"
				JOY_AXIS_TRIGGER_RIGHT:
					cleanText="🎮RightTrigger"

		if not cleanText.is_empty():
			keysText.append(cleanText)
	text = "\n".join(keysText)
