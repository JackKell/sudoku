extends Control

@export var current_puzzle: SudokuPuzzle
@export var puzzles: Array[SudokuPuzzle]

@onready var clear_all_marks_button: Button = %ClearAllMarksButton
@onready var sudoku_board: SudokuBoard = %SudokuBoard
@onready var toggle_mode_button: Button = %ToggleModeButton
@onready var current_mode_label: Label = %CurrentModeLabel
@onready var puzzle_list: ItemList = %PuzzleList
@onready var sudoku_board_controller: SudokuBoardController = $SudokuBoardController

func _ready() -> void:
	for puzzle in puzzles:
		puzzle_list.add_item(puzzle.resource_path)
	clear_all_marks_button.pressed.connect(sudoku_board.clear_marks)
	toggle_mode_button.pressed.connect(_on_toggle_mode_button_pressed)
	sudoku_board.load_puzzle(current_puzzle)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mode"):
		_toggle_mode()

func _on_toggle_mode_button_pressed() -> void:
	_toggle_mode()

func _toggle_mode():
	if sudoku_board_controller.is_marking:
		sudoku_board_controller.set_to_pencil_mode()
		current_mode_label.text = "Penciling"
	else:
		sudoku_board_controller.set_to_marking_mode()
		current_mode_label.text = "Marking"
