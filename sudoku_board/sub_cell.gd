@tool
class_name PencilCell
extends Control

@export var digit: String
@onready var label: Label = $Value

func _ready() -> void:
	label.text = str(digit)
