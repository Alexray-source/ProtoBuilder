@tool
extends EditorPlugin

var custom_dock

func _enter_tree():
	custom_dock = preload("res://addons/my_custom_dock/my_dock.tscn").instantiate()
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, custom_dock)

func _exit_tree():
	remove_control_from_docks(custom_dock)
	custom_dock.free()
