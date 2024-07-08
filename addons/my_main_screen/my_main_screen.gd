@tool
extends EditorPlugin

const graph_panel = preload("res://addons/my_main_screen/graph_scene.tscn")

var panel_instance

func _enter_tree():
	panel_instance = graph_panel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(panel_instance)
	_make_visible(false)


func _exit_tree():
	if panel_instance:
		panel_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if panel_instance:
		panel_instance.visible = visible

func _get_plugin_name():
	return "Main Screen Plugin"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
