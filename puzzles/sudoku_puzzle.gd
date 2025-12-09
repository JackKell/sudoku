class_name SudokuPuzzle
extends Resource

const BLOCK_WIDTH: int = 3
const CELL_COUNT: int = 81
const WIDTH: int = 9
const NULL_VALUE: int = -1

@export var values: Dictionary[Vector2i, int] = {}

static func coords_to_index(coords: Vector2i) -> int:
	return coords.x + coords.y * WIDTH
	
static func divmodi(dividend: int, divisor: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(dividend % divisor, dividend / divisor)

static func index_to_coords(cell_index: int) -> Vector2i:
	return divmodi(cell_index, WIDTH)
	
static func block_index_to_block_coords(block_index) -> Vector2i:
	return divmodi(block_index, BLOCK_WIDTH)

static func block_coords_to_block_index(block_coords: Vector2i) -> int:
	return block_coords.x + block_coords.y * BLOCK_WIDTH 

static func index_to_block_index(cell_index: int) -> int: 
	@warning_ignore("integer_division")
	var block_coords: Vector2i = index_to_coords(cell_index) / BLOCK_WIDTH
	return block_coords_to_block_index(block_coords)

static func column_indexes(column_index: int) -> Array[int]:
	var indexes: Array[int] = []
	for row_index in range(WIDTH): 
		indexes.append(column_index + row_index * WIDTH)
	return indexes

static func row_indexes(row_index: int) -> Array[int]:
	var indexes: Array[int] = []
	for column_index in range(WIDTH): 
		indexes.append(column_index + row_index * WIDTH)
	return indexes

static func block_indexes(block_index: int) -> Array[int]:
	var indexes: Array[int] = []
	var start_cell_coords: Vector2i = block_index_to_block_coords(block_index) * BLOCK_WIDTH
	for x in range(3):
		for y in range(3):
			var offset: Vector2i = Vector2i(x, y)
			var current_cell_coords: Vector2i = start_cell_coords + offset
			indexes.append(coords_to_index(current_cell_coords))
	return indexes
	
static func family_indexes(cell_index: int) -> Array[int]:
	var indexes: Array[int] = []
	var coords: Vector2i = index_to_coords(cell_index)
	var block_index: int = index_to_block_index(cell_index)
	for index in block_indexes(block_index):
		if index not in indexes:
			indexes.append(index)
	for index in row_indexes(coords.y):
		if index not in indexes:
			indexes.append(index)
	for index in column_indexes(coords.x):
		if index not in indexes:
			indexes.append(index)
	return indexes

static func is_valid_sudoku_array(array: Array[int]) -> bool:
	if array.size() != WIDTH:
		return false
	var seen_values: Array[int] = []
	for value in array:
		if seen_values.has(value):
			return false
		if value < 1 or value > 9:
			return false
		seen_values.append(value)
	return true

func get_columns() -> Array[Array]:
	var columns: Array[Array] = []
	for column_index: int in range(WIDTH):
		columns.append(get_column(column_index))
	return columns

func get_rows() -> Array[Array]:
	var rows: Array[Array] = []
	for row_index: int in range(WIDTH):
		rows.append(get_row(row_index))
	return rows
		
func get_blocks() -> Array[Array]:
	var blocks: Array[Array] = []
	for block_index: int in range(WIDTH):
		blocks.append(get_block(block_index))
	return blocks

var is_compelted: bool:
	get:
		for column: Array in get_columns():
			if !is_valid_sudoku_array(column):
				return false
		for row: Array in get_rows():
			if !is_valid_sudoku_array(row):
				return false
		for block: Array in get_blocks():
			if !is_valid_sudoku_array(block):
				return false
		return true
		
func get_column(column_index: int) -> Array[int]:
	var column: Array[int] = []
	for row_index in range(WIDTH):
		var value: int = values.get(Vector2i(column_index, row_index), NULL_VALUE)
		if value != NULL_VALUE:
			column.append(value)
	return column

func get_row(row_index: int) -> Array[int]:
	var row: Array[int] = []
	for column_index in range(WIDTH):
		var value: int = values.get(Vector2i(column_index, row_index), NULL_VALUE)
		if value != NULL_VALUE:
			row.append(value)
	return row
	
func get_block(block_index: int) -> Array[int]:
	var block: Array[int] = []
	for cell_index: int in block_indexes(block_index):
		var value = get_value_at_index(cell_index)
		if value != NULL_VALUE:
			block.append(value)
	return block
	
func get_family(cell_index: int) -> Array[int]:
	var family: Array[int] = []
	for index: int in family_indexes(cell_index):
		var value: int = get_value_at_index(index)
		if value != NULL_VALUE:
			family.append(value)
	return family

func clear_value_at_index(index: int) -> void:
	values.erase(index_to_coords(index))

func set_value_at_index(index: int, value: int) -> void:
	set_value_at_coords(index_to_coords(index), value)

func set_value_at_coords(coords: Vector2i, value: int) -> void:
	if value < 1 or value > 9:
		return
	values.set(coords, value)

func get_value_at_index(index: int) -> int:
	return get_value_at_coords(index_to_coords(index))

func get_value_at_coords(coords: Vector2i) -> int:
	return values.get(coords, NULL_VALUE)
