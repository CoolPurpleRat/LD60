extends Button

#func _ready() -> void:
	#if SaveManager.savedLvl:
		#if ResourceLoader.exists(SaveManager.savedLvl):
			#visible=true
			#LevelManager.preloadLevel(SaveManager.savedLvl)
		#else:
			#push_error(SaveManager.savedLvl, "\nВказаний лвл не існує!")
	#else:
		#visible=false
#
#func _on_pressed() -> void:
	#if SaveManager.savedLvl:
		#LevelManager.loadLevel(SaveManager.savedLvl)
		#
###Hide continue when Progress deleted
#func checkUnlock()->void:
	#if SaveManager.savedLvl:
		#if ResourceLoader.exists(SaveManager.savedLvl):
			#visible=true
			#LevelManager.preloadLevel(SaveManager.savedLvl)
		#else:
			#push_error(SaveManager.savedLvl, "\nВказаний лвл не існує!")
	#else:
		#visible=false
