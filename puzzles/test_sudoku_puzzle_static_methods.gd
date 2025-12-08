extends Node


func _ready() -> void:
	x()

static func test(expected: Variant, actual: Variant) -> void:
	prints(expected, actual, expected == actual)

static func test_index_to_block_index():
	test(SudokuPuzzle.index_to_block_index(10), 0)
	test(SudokuPuzzle.index_to_block_index(0), 0)
	test(SudokuPuzzle.index_to_block_index(4), 1)
	test(SudokuPuzzle.index_to_block_index(80), 8)
	test(SudokuPuzzle.index_to_block_index(70), 8)
	test(SudokuPuzzle.index_to_block_index(27), 3)
	
static func x():
	var values: Array[int] = SudokuPuzzle.block_indexes(1)
	values.sort()
	
