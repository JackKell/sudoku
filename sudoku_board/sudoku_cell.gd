@tool
class_name SudokuCell
extends Control

var value: int
var index: int:
	get:
		return _index
	set(value):
		_index = value
		_coords = SudokuPuzzle.index_to_coords(_index)
var coords: Vector2i:
	get:
		return _coords
	set(value):
		_coords = value
		_index = SudokuPuzzle.coords_to_index(_coords)
var _index: int
var _coords: Vector2i
var _sub_cells: Array[PencilCell] = []

@onready var _background: ColorRect = $Background
@onready var _sub_cells_grid: GridContainer = $SubCells
@onready var _value_label: Label = $ValueLabel

func _ready() -> void:
	reset()

func reset() -> void:
	_value_label.visible = false
	for sub_cell: PencilCell in _sub_cells_grid.get_children():
		_sub_cells.append(sub_cell)
	_sub_cells_grid.visible = true
	hide_all_pencil_marks()

func set_value(new_value: int) -> void:
	value = new_value
	_value_label.text = str(new_value)
	_value_label.visible = true
	_sub_cells_grid.visible = false

func clear_value() -> void:
	_value_label.text = ""
	value = -1
	_value_label.visible = false
	_sub_cells_grid.visible = true

func set_background_color(color: Color) -> void:
	_background.color = color
	
func set_value_color(color: Color) -> void:
	_value_label.set("theme_override_colors/font_color", color)

func pencil_value(new_pencil_value: int) -> void:
	var sub_cell_index: int = new_pencil_value - 1
	var sub_cell: PencilCell = _sub_cells.get(sub_cell_index)
	sub_cell.label.visible = !sub_cell.label.visible
	_sub_cells_grid.visible = true
	_value_label.visible = false

func hide_all_pencil_marks() -> void:
	for pencil_cell: PencilCell in _sub_cells:
		pencil_cell.label.visible = false
