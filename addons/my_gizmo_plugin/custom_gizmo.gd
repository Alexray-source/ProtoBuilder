extends EditorNode3DGizmoPlugin

const my_cube = preload("res://addons/my_gizmo_plugin/my_cube.gd")

func _init():
	create_material("main", Color(0,0,1))
	create_handle_material("handles")

func _has_gizmo(for_node_3d):
	return for_node_3d is my_cube

func _get_gizmo_name():
	return "MyCube Gizmo"

func _redraw(gizmo):
	gizmo.clear()
	
	var node = gizmo.get_node_3d()
	
	var lines = PackedVector3Array()
	lines.push_back(Vector3(0,1,0))
	lines.push_back(Vector3(0, node.my_custom_value, 0))
	
	var handles = PackedVector3Array()
	handles.push_back(Vector3(0,1,0))
	handles.push_back(Vector3(0, node.my_custom_value, 0))
	
	gizmo.add_lines(lines, get_material("main", gizmo), false)
	gizmo.add_handles(handles, get_material("handles", gizmo), [])
