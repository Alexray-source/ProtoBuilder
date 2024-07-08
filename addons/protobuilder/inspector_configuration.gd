@tool
extends Control
class_name ProtoBuilderInspector

var resource_previewer : EditorResourcePreview

var draw_btn : Button
var erase_btn : Button
var add_obj_btn: Button

var grid_check_box : CheckBox

var rot_container : VectorContainer
var size_container : VectorContainer

var rot_increment_box : SpinBox

var draw_mode : bool = true
var grid_enabled : bool = false
var file_dialog : FileDialog

var grid_container : GridContainer
var protobuilder_node : ProtoBuilder

const preset_grid_btn = preload("res://addons/protobuilder/scene_presets/grid_btn.tscn")
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	draw_btn = get_node("%DrawBtn") as Button
	erase_btn = get_node("%EraseBtn") as Button
	add_obj_btn = get_node("%AddObjectBtn") as Button
	
	grid_check_box = get_node("%GridCheckBox") as CheckBox
	
	grid_container = get_node("%GridContainer") as GridContainer
	rot_container = get_node("%RotationContainer") as VectorContainer
	size_container = get_node("%SizeContainer") as VectorContainer
	
	rot_increment_box = get_node("%RotationIncrementBox") as SpinBox

func init_gui():
	rot_container.VectorValue = protobuilder_node.target_rotation.get_euler()
	size_container.VectorValue = protobuilder_node.target_scale
	rot_increment_box.value = protobuilder_node.rotation_increment
	draw_mode_change(true, true)
	
	draw_btn.toggled.connect(draw_mode_change.bind(true))
	erase_btn.toggled.connect(draw_mode_change.bind(false))
	add_obj_btn.pressed.connect(add_obj_dialog)
	
	grid_check_box.toggled.connect(grid_mode_change)
	
	rot_container.value_updated.connect(rotation_updated)
	size_container.value_updated.connect(scale_updated)
	
	rot_increment_box.value_changed.connect(rotation_increment_updated)
	refresh_grid(resource_previewer)

func refresh_grid(resource_previewer : EditorResourcePreview):
	for btn in grid_container.get_children():
		if not btn == add_obj_btn:
			btn.queue_free()
	
	for item in protobuilder_node.saved_objects:
		var objScene : PackedScene = item
	
		
		var created_btn = preset_grid_btn.instantiate()
		
		resource_previewer.queue_resource_preview(objScene.resource_path, self, "_on_resource_preview", created_btn)
		
		created_btn.text = objScene.resource_path.get_file().trim_suffix(".tres")
		created_btn.pressed.connect(select_obj.bind(objScene))
		
		var btn_menu = created_btn.get_node("MenuButton") as MenuButton
		var popup = btn_menu.get_popup() as PopupMenu
		
		popup.id_pressed.connect(menu_actions.bind(item))
		grid_container.add_child(created_btn)
	
	#keep the "add object" button at the end
	grid_container.move_child(add_obj_btn, -1)

func _on_resource_preview(path, preview, preview_thumb, created_btn):
	print(path)
	print(preview)
	print(created_btn)
	if preview:
		created_btn.icon = preview
	else:
		print("Failed to set a thumbnail for inserted object")

func menu_actions(popup_menu_id : int, item : PackedScene):
	#remove object from stored list
	if popup_menu_id == 0:
		var item_index = protobuilder_node.saved_objects.find(item)
		protobuilder_node.saved_objects.remove_at(item_index)
		protobuilder_node.current_obj = null
		refresh_grid(resource_previewer)
	elif popup_menu_id == 1:
		for child in protobuilder_node.objects_holder.get_children():
			print(item.resource_path)
			print(scene_file_path)
			if child.scene_file_path == item.resource_path:
				child.queue_free()

func select_obj(objScene):
	protobuilder_node.current_obj = objScene

func draw_mode_change(button_toggle_state , can_draw):
	draw_mode = can_draw
	if can_draw == true:
		erase_btn.set_pressed_no_signal(not button_toggle_state)
		erase_btn.disabled = false
		draw_btn.disabled = true
		print("drawing mode enabled")
	else:
		draw_btn.set_pressed_no_signal(not button_toggle_state)
		draw_btn.disabled = false
		erase_btn.disabled = true
		print("erase mode enabled")

func grid_mode_change(toggle_state):
	grid_enabled = toggle_state

func add_obj_dialog():
	file_dialog = get_node("%FileDialog")
	#file_dialog.access = 0
	#file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.file_selected.connect(obj_to_add_selected)
	print("Triggered file select")
	file_dialog.show()

func obj_to_add_selected(pathToObj):
	protobuilder_node.add_object_to_list(load(pathToObj))
	refresh_grid(resource_previewer)

func rotation_updated(value):
	print("Protobuilder: Rotation updated")
	var value_in_rad = Vector3(deg_to_rad(value.x), deg_to_rad(value.y), deg_to_rad(value.z))
	protobuilder_node.target_rotation = Basis.from_euler(value_in_rad)

func scale_updated(value):
	print("Protobuilder: Scales updated")
	protobuilder_node.target_scale = value

func rotation_increment_updated(value):
	protobuilder_node.rotation_increment = value
