class_name SudokuBoardController
extends Node

@export var sudoku_board: SudokuBoard

enum Mode {
	MARKING,
	PENCILING,
}

var is_marking: bool:
	get:
		return _mode == Mode.MARKING

var _mode: Mode = Mode.MARKING

func set_to_pencil_mode() -> void: 
	_mode = Mode.PENCILING

func set_to_marking_mode() -> void: 
	_mode = Mode.MARKING


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("clear"):
		sudoku_board.clear_hovered()
	elif event.is_action_pressed("key_1"):
		input_value(1)
	elif event.is_action_pressed("key_2"):
		input_value(2)
	elif event.is_action_pressed("key_3"):
		input_value(3)
	elif event.is_action_pressed("key_4"):
		input_value(4)
	elif event.is_action_pressed("key_5"):
		input_value(5)
	elif event.is_action_pressed("key_6"):
		input_value(6)
	elif event.is_action_pressed("key_7"):
		input_value(7)
	elif event.is_action_pressed("key_8"):
		input_value(8)
	elif event.is_action_pressed("key_9"):
		input_value(9)

func input_value(value: int):
	match _mode:
		Mode.PENCILING:
			sudoku_board.pencil(value)
		Mode.MARKING:
			sudoku_board.mark(value)
