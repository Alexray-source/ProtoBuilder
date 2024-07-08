@tool
extends EditorPlugin

const protobuilder_node_class = preload("res://addons/protobuilder/builder_node.gd")

var resource_previewer = EditorInterface.get_resource_previewer()

var builder_dock : ProtoBuilderInspector
var protobuilder_node : ProtoBuilder

var visual_obj : Node3D

var holding_shift := false

func _enter_tree():
	add_custom_type("ProtoBuilder", "Node3D", preload("res://addons/protobuilder/builder_node.gd"), preload("res://icon.svg"))
	EditorInterface.get_selection().selection_changed.connect(node_selection_changed)

func remove_dock():
	if builder_dock != null:
		remove_control_from_docks(builder_dock)
		builder_dock.free()
		builder_dock = null
		print("Deslected builder node!")

#Returns true if our currently selected objects class is "ProtoBuilder"
#This enables the _forward_3d_gui_input methods (and other ones as well, but I don't use those here)
func _handles(object):
	if object != null and object is ProtoBuilder:
		protobuilder_node = object
		protobuilder_node.object_changed.connect(change_preview_mesh)
		return true
	else:
		return false

func change_preview_mesh(packed_scene):
	if visual_obj:
		visual_obj.queue_free()
		visual_obj = null
		visual_obj = packed_scene.instantiate() as Node3D
	else:
		return
	
	#Prevent the raycast draw mode from intersecting with the preview mesh
	if visual_obj is CollisionObject3D:
		visual_obj.set_collision_layer_value(1, false)
	
	get_tree().edited_scene_root.add_child(visual_obj)
	for child in visual_obj.get_children():
		if child is MeshInstance3D:
			child.transparency = 0.5
		elif child is CollisionObject3D:
			child.set_collision_layer_value(1, false)

#This method handles the visual preview of the selected object
func refresh_preview(camera : Camera3D):
	var mouse_pos = camera.get_viewport().get_mouse_position()
	var dropPlane  = Plane(Vector3(0, 1, 0), 0)
		
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * camera.far
	
	if to == null:
		return
	
	var cursor_plane_pos = dropPlane.intersects_ray(from, to)
	
	if builder_dock.grid_enabled:
		cursor_plane_pos = snapped(cursor_plane_pos, Vector3(1,1,1))
	
	var space_state = EditorInterface.get_edited_scene_root().get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var results = space_state.intersect_ray(query)
	
	if visual_obj != null:
		var target_transform
		if results:
			var returned_obj = results.collider
			var end_pos = results.position + (camera.project_ray_normal(mouse_pos) * -0.1)
			
			if end_pos == null:
				return
			
			if builder_dock.grid_enabled:
				end_pos = snapped(end_pos, Vector3(1,1,1))
			
			target_transform = Transform3D(protobuilder_node.target_rotation, end_pos)
			target_transform = target_transform.scaled_local(protobuilder_node.target_scale)
		else:
			target_transform = Transform3D(protobuilder_node.target_rotation, cursor_plane_pos)
			target_transform = target_transform.scaled_local(protobuilder_node.target_scale)
		visual_obj.transform = target_transform

func _forward_3d_gui_input(camera : Camera3D, event):
	#Shortcut bindings rotation
	if protobuilder_node == null or remove_dock == null:
		return EditorPlugin.AFTER_GUI_INPUT_PASS
	
	if event is InputEventKey:
		if event.keycode == KEY_R and event.is_pressed():
			protobuilder_node.target_rotation = protobuilder_node.target_rotation.rotated(Vector3(0,1,0), deg_to_rad(protobuilder_node.rotation_increment))
			refresh_preview(camera)
			return EditorPlugin.AFTER_GUI_INPUT_CUSTOM
		elif event.keycode == KEY_SHIFT:
			if event.is_pressed():
				holding_shift = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				print("Holding shift")
			elif event.is_released():
				holding_shift = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				print("Released shift")
	
	if event is InputEventMouseMotion:
		if holding_shift:
			protobuilder_node.target_scale = protobuilder_node.target_scale + Vector3(event.velocity.y*0.0001,event.velocity.y*0.0001,event.velocity.y*0.0001)
			print(protobuilder_node.target_scale)
			builder_dock.size_container.VectorValue = protobuilder_node.target_scale
			refresh_preview(camera)
			return EditorPlugin.AFTER_GUI_INPUT_CUSTOM
		
		refresh_preview(camera)
		return EditorPlugin.AFTER_GUI_INPUT_CUSTOM
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			print("mouse clicked!")
			
			var mouse_pos = camera.get_viewport().get_mouse_position()
			
			var dropPlane  = Plane(Vector3(0, 1, 0), 0)
			
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * camera.far
			var cursor_plane_pos = dropPlane.intersects_ray(from, to)
			
			if builder_dock.grid_enabled:
				cursor_plane_pos = snapped(cursor_plane_pos, Vector3(1,1,1))
			
			var space_state = EditorInterface.get_edited_scene_root().get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var results = space_state.intersect_ray(query)
			
			if protobuilder_node.current_obj == null:
				return EditorPlugin.AFTER_GUI_INPUT_STOP

			if builder_dock.draw_mode == true:
				
				var target_transform : Transform3D
				if results:
					var returned_obj = results.collider
					var end_pos = results.position + (camera.project_ray_normal(mouse_pos) * -0.1)
					
					if builder_dock.grid_enabled:
						end_pos = snapped(end_pos, Vector3(1,1,1))
					
					target_transform = Transform3D(protobuilder_node.target_rotation, end_pos)
					target_transform = target_transform.scaled_local(protobuilder_node.target_scale)
				else:
					target_transform = Transform3D(protobuilder_node.target_rotation, cursor_plane_pos)
					target_transform = target_transform.scaled_local(protobuilder_node.target_scale)
				print(target_transform.basis.get_scale())
				protobuilder_node.spawn_object(protobuilder_node.current_obj, target_transform, protobuilder_node.objects_holder)
			else:
				if results:
					var returned_obj = results.collider
					print(returned_obj)
					returned_obj.queue_free()
			#Prevent editor from continuing any further input actions. We do this so we can use the left click for our plugin. (otherwise it will deslect or select another object in the scene)
			return EditorPlugin.AFTER_GUI_INPUT_STOP
			
		#elif event.is_pressed() and holding_shift:
			#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				#print("scrolling up and holding shift")
				##protobuilder_node.target_scale += Vector3(0.1,0.1,0.1)
				#protobuilder_node.target_scale = protobuilder_node.target_scale + Vector3(0.1,0.1,0.1)
				#builder_dock.size_container.VectorValue = protobuilder_node.target_scale
				#return EditorPlugin.AFTER_GUI_INPUT_STOP
			#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				#protobuilder_node.target_scale = protobuilder_node.target_scale - Vector3(0.1,0.1,0.1)
				#builder_dock.size_container.VectorValue = protobuilder_node.target_scale
				#return EditorPlugin.AFTER_GUI_INPUT_STOP

func node_selection_changed():
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	
	if selected_nodes.size() > 0 and selected_nodes[0] is protobuilder_node_class and builder_dock == null:
		print("Selected builder node!")
		builder_dock = preload("res://addons/protobuilder/settings_dock.tscn").instantiate()
		builder_dock.protobuilder_node = selected_nodes[0]
		builder_dock.resource_previewer = resource_previewer
		add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, builder_dock)
		
		builder_dock.init_gui()
		
		visual_obj = MeshInstance3D.new()
		visual_obj.mesh = BoxMesh.new()
		get_tree().edited_scene_root.add_child(visual_obj)
	elif selected_nodes.size() < 1 or not selected_nodes[0] is protobuilder_node_class:
		remove_dock()
		if visual_obj:
			visual_obj.queue_free()
			visual_obj = null

func _exit_tree():
	remove_dock()
	remove_custom_type("ProtoBuilder")
