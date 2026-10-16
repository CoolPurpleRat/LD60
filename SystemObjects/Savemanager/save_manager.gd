extends Node

var progressSavePath :="user://progress.save" ##де збереження

var toSave:Dictionary

#func _ready() -> void:
	#loadProgress()

##Збереження прогресу
#func progressSave()->void:
	#var file := FileAccess.open(progressSavePath, FileAccess.WRITE)
	#toSave["savedLvl"]=savedLvl
	#toSave["unlockedLvlsName"]=unlockedLvlsNames
	#toSave["savedCheckpointLocation"]=savedCheckpointLocation
	#file.store_var(toSave)

###Загрузка прогресу
#func loadProgress()->void:
	#if FileAccess.file_exists(progressSavePath):
		#var file := FileAccess.open(progressSavePath, FileAccess.READ)
		#toSave=file.get_var()
		#if toSave.has("savedLvl"):savedLvl=toSave["savedLvl"]
		#if toSave.has("unlockedLvlsName"):unlockedLvlsNames=toSave["unlockedLvlsName"]
		#if toSave.has("savedCheckpointLocation"):savedCheckpointLocation=toSave["savedCheckpointLocation"]
	#else:
		#pass

##Видалення прогресу
func deleteProgress()->void:
	if FileAccess.file_exists(progressSavePath):
		DirAccess.remove_absolute(progressSavePath)
