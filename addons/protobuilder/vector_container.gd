@tool
extends HBoxContainer
class_name VectorContainer

signal value_updated(value)

@export var ContainerName = "Vector"
	#set(value):
		#ContainerName = value
		#setLabel(value)

@export var VectorValue : Vector3:
	set(value):
		VectorValue = value
		updateSpinBoxes()

var NameLabel : Label
var xField : SpinBox
var yField : SpinBox
var zField : SpinBox

# Called when the node enters the scene tree for the first time.
func _ready():
	NameLabel = $Label as Label
	xField = $xRot as SpinBox
	yField = $yRot as SpinBox
	zField = $zRot as SpinBox
	
	xField.value_changed.connect(updateVectorValue)
	yField.value_changed.connect(updateVectorValue)
	zField.value_changed.connect(updateVectorValue)
	
	print(xField)
	updateSpinBoxes()
	setLabel(ContainerName)

func updateVectorValue(spinner_value):
	VectorValue = Vector3(xField.value, yField.value, zField.value)
	print("Vector Container: Updated value")
	value_updated.emit(VectorValue)

func updateSpinBoxes():
	#if xField and yField and zField:
		print("Spin boxes updated!")
		xField.set_value_no_signal(VectorValue.x)
		yField.set_value_no_signal(VectorValue.y)
		zField.set_value_no_signal(VectorValue.z)
		value_updated.emit(VectorValue)

func setLabel(value):
	if NameLabel:
		NameLabel.text = value
