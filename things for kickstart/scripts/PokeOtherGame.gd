extends Label

#Only works on Windows

var DBSsave:Dictionary
var progressSavePath :="user://progress.save" ##де збереження


func _ready() -> void:
	if not OS.get_name()=="Android":
		var searchPath:String=ProjectSettings.globalize_path(progressSavePath)
		searchPath=searchPath.get_base_dir().get_base_dir() #До сейвов
		searchPath+="/Data Breach-SHINOBI/progress.save"
		print_debug(searchPath)
		if FileAccess.file_exists(searchPath):
			var file := FileAccess.open(searchPath, FileAccess.READ)
			DBSsave=file.get_var()
			if DBSsave.is_empty():
				return
			if DBSsave.has("unlockedLvlsName"):
				var DBSsaveLvls:Array[String]=DBSsave["unlockedLvlsName"]
				text=DBSsaveLvls[0]
	else:
		var searchPath:String=ProjectSettings.globalize_path(progressSavePath)
		searchPath=searchPath.get_base_dir().get_base_dir().get_base_dir()
		searchPath+="/com.example.databreachshinobi/files/progress.save"
		print(searchPath)
		if FileAccess.file_exists(searchPath):
			print("Found!")
		if FileAccess.file_exists(searchPath):
			print("Found!")
		#print(searchPath)
