@tool
extends Button

func _enter_tree():
	pressed.connect(on_button_pressed)

func on_button_pressed():
	print("You pressed me!")
