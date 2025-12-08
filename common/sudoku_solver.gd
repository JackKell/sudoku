class_name SudokuSolver
extends Node

@export var puzzle: SudokuPuzzle

var _solution: SudokuPuzzle

func _ready() -> void:
	solve(puzzle)

func solve(p: SudokuPuzzle):
	if puzzle == null:
		return
	_solution = puzzle.duplicate()
	for i in range(81):
		_solution.set_value_at_index(i, 1)
		await get_tree().create_timer(0.01).timeout
