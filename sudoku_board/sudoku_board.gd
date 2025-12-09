@tool
class_name SudokuBoard
extends Control

@export_category("Styling")
@export var default_color = Color(1.0, 1.0, 1.0, 1.0)
@export var hovered_secondary_color = Color(0.835, 0.835, 0.835, 1.0)
@export var hovered_primary_color = Color(0.497, 0.497, 0.497, 1.0)
@export var puzzle_color: Color = Color(0.107, 0.0, 0.722, 1.0)
@export var solution_color: Color = Color(0.0, 0.0, 0.0, 1.0)
@export var major_boarder_color: Color = Color(0.014, 0.014, 0.014, 1.0)
@export var minor_boarder_color: Color = Color(0.501, 0.501, 0.501, 1.0)
@export var minor_border_width: int = 3
@export var major_border_width: int = 6

@onready var cells_grid: GridContainer = $CellsGrid

var _cells: Array[SudokuCell] = []

var _locked_cells: Array[SudokuCell] = []
var _hovered_cell: SudokuCell

func _ready() -> void:
	var cell_index: int = 0
	for cell: SudokuCell in cells_grid.get_children():
		cell.index = cell_index
		cell_index += 1
		cell.mouse_entered.connect(_on_cell_mouse_entered.bind(cell))
		cell.mouse_exited.connect(_on_cell_mouse_exited.bind(cell))
		_cells.append(cell)
		cell.set_value_color(solution_color)

func _draw() -> void:
	var cell_size = size.x / SudokuPuzzle.WIDTH
	for i in [1, 2, 4, 5, 7, 8]:
		draw_line(Vector2(cell_size * i, 0), Vector2(cell_size * i, size.y), minor_boarder_color, minor_border_width)
		draw_line(Vector2(0, cell_size * i), Vector2(size.x, cell_size * i), minor_boarder_color, minor_border_width)
	for i in [3, 6]:
		draw_line(Vector2(cell_size * i, 0), Vector2(cell_size * i, size.y), major_boarder_color, major_border_width)
		draw_line(Vector2(0, cell_size * i), Vector2(size.x, cell_size * i), major_boarder_color, major_border_width)
	draw_rect(Rect2(Vector2.ZERO, size),  major_boarder_color, false, major_border_width)

func mark(value: int) -> void:
	if _hovered_cell == null:
		return
	if _locked_cells.has(_hovered_cell):
		return
	if _hovered_cell.value == value:
		_hovered_cell.clear_value()
	else:
		_hovered_cell.set_value(value)

func pencil(value: int) -> void: 
	if _hovered_cell == null:
		return
	if _locked_cells.has(_hovered_cell):
		return
	if _hovered_cell.value == value:
		_hovered_cell.clear_value()
	else:
		_hovered_cell.pencil_value(value, !_hovered_cell.get_pencil_visible(value))

func set_value_at_index(index: int, value: int) -> void:
	var cell: SudokuCell = _cells.get(index)
	if _locked_cells.has(cell):
		return
	cell.set_value(value)

func set_value_at_coords(coords: Vector2i, value: int) -> void:
	set_value_at_index(SudokuPuzzle.coords_to_index(coords), value)

func set_pencil_at_coords(coords: Vector2i, value: int, vis: bool) -> void:
	set_pencil_at_index(SudokuPuzzle.coords_to_index(coords), value, vis)

func set_pencil_at_index(index: int, value: int, vis: bool) -> void:
	var cell: SudokuCell = _cells.get(index)
	if _locked_cells.has(cell):
		return
	cell.pencil_value(value, vis)
		
func clear_hovered() -> void:
	if _hovered_cell == null:
		return
	if _locked_cells.has(_hovered_cell):
		return
	_hovered_cell.clear_value()

func get_value_at_index(index: int) -> int:
	return _cells.get(index).value

func clear_marks() -> void:
	for cell: SudokuCell in _cells:
		if _locked_cells.has(cell):
			continue
		cell.clear_value()

func load_puzzle(puzzle: SudokuPuzzle) -> void:
	for cell: SudokuCell in _cells:
		cell.clear_value()
		cell.set_value_color(solution_color)
	_locked_cells.clear()
	for coords: Vector2i in puzzle.values:
		var value: int = puzzle.values.get(coords)
		var index: int = SudokuPuzzle.coords_to_index(coords)
		var cell: SudokuCell = _cells.get(index)
		cell.set_value(value)
		cell.set_value_color(puzzle_color)
		_locked_cells.append(cell)

func _get_column(column_index: int) -> Array[SudokuCell]:
	var column: Array[SudokuCell] = []
	column.assign(SudokuPuzzle.column_indexes(column_index).map(_map_index_to_cell))
	return column

func _get_block(block_index: int) -> Array[SudokuCell]:
	var block: Array[SudokuCell] = []
	block.assign(SudokuPuzzle.block_indexes(block_index).map(_map_index_to_cell))
	return block

func _get_row(row_index: int) -> Array[SudokuCell]:
	var row: Array[SudokuCell] = []
	row.assign(SudokuPuzzle.row_indexes(row_index).map(_map_index_to_cell))
	return row

func _map_index_to_cell(index: int) -> SudokuCell:
	return _cells.get(index)
	
func _get_family(cell_index: int) -> Array[SudokuCell]:
	var family: Array[SudokuCell] = []
	family.assign(SudokuPuzzle.family_indexes(cell_index).map(_map_index_to_cell))
	return family

func _on_cell_mouse_entered(cell: SudokuCell) -> void:
	grab_focus()
	if _hovered_cell != null:
		_clear_highlighting(_hovered_cell)
		_hovered_cell.set_background_color(default_color)
	_hovered_cell = cell
	for family_cell in _get_family(cell.index):
		family_cell.set_background_color(hovered_secondary_color)
	cell.set_background_color(hovered_primary_color)

func _on_cell_mouse_exited(cell: SudokuCell) -> void:
	if _hovered_cell == cell:
		_clear_highlighting(_hovered_cell)
		_hovered_cell = null
	
func _clear_highlighting(cell: SudokuCell):
	for family_cell in _get_family(cell.index):
		family_cell.set_background_color(default_color)
