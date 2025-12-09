class_name SudokuSolver
extends Node

const STEP_DURATION: float = 1
const ALL: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9]

@export var puzzle: SudokuPuzzle
@export var board: SudokuBoard

func _ready() -> void:
	solve(puzzle)

func solve(p: SudokuPuzzle):
	if puzzle == null:
		return
	var solution: SudokuPuzzle = p.duplicate()
	var possibilities: Dictionary[Vector2i, Array] = {}
	for coords: Vector2i in solution.values:
		var value: int = solution.get_value_at_coords(coords)
		board.set_value_at_coords(coords, value)
	
	const VALUE: float = 1
	
	await pause(3)
	for x in range(SudokuPuzzle.WIDTH):
		for y in range(SudokuPuzzle.WIDTH):
			var coords: Vector2i = Vector2i(x, y)
			if solution.values.has(coords):
				continue
			possibilities.set(coords, ALL.duplicate())
			for value: int in ALL:
				board.set_pencil_at_coords(coords, value, true)
		await pause(0.5)
	
	reduce_possibilities(solution, possibilities)
	for i in range(10):
		naked_singles(solution, possibilities)
		hidden_single(solution, possibilities)
		if solution.is_compelted:
			break
		await pause(VALUE)

func reduce_possibilities(solution: SudokuPuzzle, possibilities: Dictionary[Vector2i, Array]) -> void:
	for coords: Vector2i in possibilities:
		reduce_cell_possibilites(solution, possibilities, coords)

func reduce_cell_possibilites(solution: SudokuPuzzle, possibilities: Dictionary[Vector2i, Array], coords: Vector2i) -> void:
	var index: int = SudokuPuzzle.coords_to_index(coords)
	var candidates: Array = possibilities.get(coords, [])
	for value: int in solution.get_family(index):
		if candidates.has(value):
			candidates.erase(value)
			board.set_pencil_at_coords(coords, value, false)

func reduce_family_possibilities(solution: SudokuPuzzle, possibilities: Dictionary[Vector2i, Array], coords: Vector2i) -> void:
	var value: int = solution.get_value_at_coords(coords)
	var given_index: int = SudokuPuzzle.coords_to_index(coords)
	possibilities.erase(coords)
	for cell_index: int in SudokuPuzzle.family_indexes(given_index):
		var cell_coords: Vector2i = SudokuPuzzle.index_to_coords(cell_index)
		if possibilities.has(cell_coords):
			var cell_possibilities: Array = possibilities.get(cell_coords)
			cell_possibilities.erase(value)
			board.set_pencil_at_coords(cell_coords, value, false)

func naked_singles(solution: SudokuPuzzle, possibilities: Dictionary[Vector2i, Array]) -> void:
	for coords: Vector2i in possibilities:
		var candidates: Array = possibilities.get(coords)
		if candidates.size() == 1:
			set_value(coords, candidates.pop_back(), solution, possibilities)

func find_hidden_singles_in_collection(
	solution: SudokuPuzzle, 
	possibilities: Dictionary[Vector2i, Array], 
	collection: Array[int]
):
	var seen_candidates: Array[int] = []
	var hidden_singles_coords: Dictionary[int, Vector2i] = {}
	for cell_index: int in collection:
		var coords = SudokuPuzzle.index_to_coords(cell_index)
		if possibilities.has(coords):
			for candidate in possibilities.get(coords):
				if seen_candidates.has(candidate):
					hidden_singles_coords.erase(candidate)
				else: 
					seen_candidates.append(candidate)
					hidden_singles_coords.set(candidate, coords)
	for value: int in hidden_singles_coords:
		var coords: Vector2i = hidden_singles_coords.get(value)
		set_value(coords, value, solution, possibilities)

func hidden_single(solution: SudokuPuzzle, possibilities: Dictionary[Vector2i, Array]) -> void:
	for index in range(SudokuPuzzle.WIDTH):
		find_hidden_singles_in_collection(solution, possibilities, SudokuPuzzle.row_indexes(index))
		find_hidden_singles_in_collection(solution, possibilities, SudokuPuzzle.column_indexes(index))
		find_hidden_singles_in_collection(solution, possibilities, SudokuPuzzle.block_indexes(index))
	
func set_value(
	coords: Vector2i, 
	value: int, 
	solution: SudokuPuzzle, 
	possibilities: Dictionary[Vector2i, Array]) -> void:
	solution.set_value_at_coords(coords, value)
	board.set_value_at_coords(coords, value)
	reduce_family_possibilities(solution, possibilities, coords)

func row_possibilites(row_index: int, possibilities: Dictionary[Vector2i, Array]) -> Array[Array]:
	var r: Array[Array] = []
	for column_index in range(SudokuPuzzle.WIDTH):
		var coords = Vector2i(column_index, row_index)
		if possibilities.has(coords):
			r.append([column_index, possibilities.get(coords)])
	return r

func column_possibilites(column_index: int, possibilities: Dictionary[Vector2i, Array]) -> Array[Array]:
	var r: Array[Array] = []
	for row_index in range(SudokuPuzzle.WIDTH):
		var coords = Vector2i(column_index, row_index)
		if possibilities.has(coords):
			r.append(possibilities.get(coords))
	return r

func count_possibilities(candidate_lists: Array[Array]) -> Dictionary[int, int]:
	var result: Dictionary[int, int] = {}
	for candidate_list in candidate_lists:
		for candidate in candidate_list:
			result.set(candidate, result.get_or_add(candidate, 0) + 1)
	return result

func pause(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
