@tool
extends Node
class_name ProtoBuilder

@export var saved_objects : Array[PackedScene]
@export var objects_holder : Node3D

@export var current_obj : PackedScene:
	set(value):
		current_obj = value
		object_changed.emit(current_obj)

var target_rotation : Basis
var rotation_increment : float = 45
@export var target_scale : Vector3

signal object_changed()

func add_object_to_list(object):
	if object.instantiate() is Node3D:
		saved_objects.append(object)
	else:
		print("Added object is not a Node3D or a subclass of it! Object not added.")

func spawn_object(object, target_transform, parent):
	var spawned_object = object.instantiate() as Node3D
	spawned_object.transform = target_transform
	parent.add_child(spawned_object)
	spawned_object.owner = get_tree().edited_scene_root
