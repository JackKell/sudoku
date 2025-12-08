extends Control

const TEXT_RESOURCE_EXTENSTION = ".tres"
const PUZZLE_DIRECTORY = "res://puzzles/"
const FILE_EXIST_MESSAGE = "File name already exists!"

@onready var sudoku_board: SudokuBoard = $SudokuBoard

@onready var delete_button: Button = %DeleteButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var files_list: ItemList = %FilesList
@onready var filename_text_edit: TextEdit = %FilenameTextEdit
@onready var filename_text_edit_helper_text: Label = %FilenameTextEditHelperText

var _existing_filenames: Array[String] = []

func _ready() -> void:
	delete_button.pressed.connect(_on_delete_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	filename_text_edit.text_changed.connect(_on_filename_text_edit_changed)
	load_button.pressed.connect(_on_load_puzzle_button_pressed)
	files_list.item_selected.connect(_on_files_list_item_selected)
	var dir = DirAccess.open(PUZZLE_DIRECTORY)
	dir.list_dir_begin()
	for file: String in dir.get_files():
		if (file.ends_with(TEXT_RESOURCE_EXTENSTION)):
			var path = dir.get_current_dir().path_join(file)
			var filename = file.trim_suffix(TEXT_RESOURCE_EXTENSTION)
			_existing_filenames.append(filename)
			files_list.add_item(filename)
			var index = files_list.item_count - 1
			files_list.set_item_metadata(index, path)
	dir.list_dir_end()

func _on_files_list_item_selected(index: int) -> void:
	if index == -1:
		load_button.disabled = true
		delete_button.disabled = true
	else:
		load_button.disabled = false
		delete_button.disabled = false

func _on_load_puzzle_button_pressed() -> void:
	var selected_item_index: int = files_list.get_selected_items().get(0)
	var path = files_list.get_item_metadata(selected_item_index)
	var filename = files_list.get_item_text(selected_item_index)
	filename_text_edit.text = filename
	filename_text_edit.text_changed.emit()
	var puzzle: SudokuPuzzle = ResourceLoader.load(path)
	if puzzle:
		_update_board(puzzle)
	else:
		print("error happened!!!!", path)

func _update_board(puzzle: SudokuPuzzle) -> void:
	sudoku_board.clear_marks()
	for index in range(SudokuPuzzle.CELL_COUNT):
		var value = puzzle.get_value_at_index(index)
		if value != SudokuPuzzle.NULL_VALUE:
			sudoku_board.set_value_at_index(index, value)

func _get_filename() -> String:
	return filename_text_edit.text.strip_edges()

func _on_filename_text_edit_changed() -> void:
	var filename: String = _get_filename()
	if filename.is_empty():
		save_button.disabled = true
		filename_text_edit_helper_text.text = ""
		return
	save_button.disabled = false
	filename_text_edit_helper_text.text = ""

func _on_save_button_pressed() -> void:
	var puzzle: SudokuPuzzle = _get_puzzle_state_from_board()
	var filename: String = _get_filename()
	var path: String = PUZZLE_DIRECTORY.path_join(filename) + TEXT_RESOURCE_EXTENSTION
	var error = ResourceSaver.save(puzzle, path)
	if error == OK and !_existing_filenames.has(filename):
		_existing_filenames.append(filename)
		files_list.add_item(filename)
		var index = files_list.item_count - 1
		files_list.set_item_metadata(index, path)

func _get_puzzle_state_from_board() -> SudokuPuzzle:
	var puzzle: SudokuPuzzle = SudokuPuzzle.new()
	for index: int in range(SudokuPuzzle.CELL_COUNT):
		puzzle.set_value_at_index(index, sudoku_board.get_value_at_index(index))
	return puzzle

func _on_delete_button_pressed() -> void:
	var selected_item_index: int = files_list.get_selected_items().get(0)
	var path = files_list.get_item_metadata(selected_item_index)
	var filename = files_list.get_item_text(selected_item_index)
	DirAccess.remove_absolute(path)
	_existing_filenames.remove_at(_existing_filenames.find(filename))
	files_list.remove_item(selected_item_index)
