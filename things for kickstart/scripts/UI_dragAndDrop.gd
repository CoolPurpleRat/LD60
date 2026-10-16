extends Node
#can be toogled on any control element
#can be used for example for iventory system
#taken from https://qaqelol.itch.io/gui

#receiver example
#extends TextureRect
#
## Only accept specific type of data from drop
#func _can_drop_data(at_pos:Vector2, data:Variant)->bool:
	#if data is Color or data is Texture or data is String:
		#return true
	#return false
#
## Use dropped data to change the look of this node
#func _drop_data(at_pos: Vector2, data: Variant) -> void:
#
	#if data is String:
		#if data == "small": scale = Vector2(0.8, 0.8)
		#elif data == "big": scale = Vector2(1.2, 1.2)
	#
	#elif data is Texture: texture = data
	#elif data is Color: modulate = data
#

#sender example
#extends ColorRect
#func _get_drag_data(at_position: Vector2) -> Variant:
	#var preview = self.duplicate() # copy of node
	#
	## make sure preview is ontop of everything else
	#preview.top_level = true 
	#preview.z_index = 100    
	#
	## set the dragging preview
	#set_drag_preview(preview)
	#
	## Give the ColorRect's color as the drag data
	#return color
