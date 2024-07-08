@tool
extends MeshInstance3D

@export var main_mat : Material
@export var my_custom_value : float

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	main_mat = StandardMaterial3D.new()
	main_mat.albedo_color = Color.LIGHT_GREEN
	
	mesh = BoxMesh.new()
	mesh.size = Vector3(5,5,5)
	mesh.material = main_mat
