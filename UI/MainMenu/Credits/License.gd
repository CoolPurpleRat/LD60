@tool
extends FoldableContainer

@export_tool_button("Load text") var loadTextB:Callable=updateText
@onready var licenseTextRef: RichTextLabel = %LicenseText
@export_file_path("*.txt") var LicenseFilePath: String

signal opened(position:Vector2)

##Keep a reference to the thread so it doesn't get garbage collected
var loadThread: Thread

##Background loading
func _load_file_async(path: String) -> void:
	var license_file := FileAccess.open(path, FileAccess.READ)
	if license_file == null:
		printerr("Failed to open file. Error code: ", FileAccess.get_open_error())
		return

	var loaded_text := license_file.get_as_text()
	license_file.close()
	call_deferred("_update_ui", loaded_text)

func _update_ui(text: String) -> void:
	licenseTextRef.text = text

	if loadThread and loadThread.is_started():
		loadThread.wait_to_finish()

func updateText() -> void:
	if visible:
		licenseTextRef.custom_minimum_size=Vector2(0, DisplayServer.window_get_size().y/2)
		if LicenseFilePath.is_empty() or not FileAccess.file_exists(LicenseFilePath):
			printerr(name, "File does not exist or path is empty: ", LicenseFilePath)
			return

		#Initialize and start the background thread
		loadThread = Thread.new()
		# we use .callable() to point to our background function, passing the path as an argument
		loadThread.start(_load_file_async.bind(LicenseFilePath))

func _onFoldingChanged(_is_folded: bool) -> void:
	MusicSystem.buttonSFX()
	##Focus and scroll to text
	if not _is_folded:
		licenseTextRef.grab_focus.call_deferred()
		emit_signal("opened", position)
