@tool
extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(on_button_pressed)

func on_button_pressed():
	print("You've pressed the button inside of a graph!")
