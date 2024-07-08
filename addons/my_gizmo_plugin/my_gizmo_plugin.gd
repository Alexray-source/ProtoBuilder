@tool
extends EditorPlugin

const custom_gizmo = preload("res://addons/my_gizmo_plugin/custom_gizmo.gd")

var my_gizmo = custom_gizmo.new()

func _enter_tree():
	add_custom_type("MyCube", "MeshInstance3D", preload("my_cube.gd"), preload("res://icon.svg"))
	add_node_3d_gizmo_plugin(my_gizmo)


func _exit_tree():
	remove_custom_type("MyCube")
	remove_node_3d_gizmo_plugin(my_gizmo)
