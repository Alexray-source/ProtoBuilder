@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("MyButton", "Button", preload("my_button.gd"), preload("my_button_icon.svg"))


func _exit_tree():
	remove_custom_type("MyButton")
