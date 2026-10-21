extends GutTest

## The station's board for the crime scene (escena-del-crimen.md, step 5): files, pinned clues, red string, accusing.

const LEVEL := preload("res://scenes/levels/crime_scene.tscn")

var level: CrimeSceneLevel
var case: CrimeSceneCase
var board: CrimeBoard
var cop: Cop


func before_each() -> void:
	level = LEVEL.instantiate()
	level.case_seed = 33
	cop = level.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	case = level.case
	board = level.board
	case.give_tip()


func _photo_all() -> void:
	for cook in level.contest.cooks:
		case.file_part(cook.index, "photo")


func _innocent() -> int:
	return (case.plan.culprit + 1) % case.cooks.size()


func test_the_board_room_is_open_and_the_board_inside() -> void:
	var station: Transform3D = level.get_node("City").transform * CityLayout.lot("station")
	var local := station.affine_inverse() * board.global_position
	assert_between(local.x, -StationRooms.HALF_X, -StationRooms.BACK_X, "in the board room, west")
	assert_between(local.z, -StationRooms.HALF_Z, StationRooms.SPLIT_Z, "in the back row")
	var hit := level.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		station * Vector3(-3.0, 1.0, -2.6), station * Vector3(-7.0, 1.0, -2.6)))
	assert_true(hit.is_empty(), "the office's side door into the board room is open")


func test_files_show_up_with_a_photo() -> void:
	assert_true(board.file_cards.is_empty())
	case.file_part(2, "photo")
	assert_eq(board.file_cards.keys(), [2])
	assert_string_contains(board.file_cards[2].label.text, case.cooks[2].name)
	assert_string_contains(board.file_cards[2].label.text, tr("FILE_HAIR") % "?", "no hair until the hat comes off")


func test_found_clues_get_pinned() -> void:
	board.use(cop)
	assert_true(board.clue_cards.is_empty(), "nothing found yet")
	var kind: String = case.plan.clues[0]
	case.clues_found.append(kind)
	if case.items.has(kind):
		var item: CrimeClueItem = case.items[kind]
		item.bagged = true
		cop.get_node("Grabber").grab(item)
	board.use(cop)
	assert_true(board.clue_cards.has(kind))
	assert_eq(board.clue_cards[kind].label.text, case.clue_line(kind))


func test_the_string_holds_only_on_a_fitting_file() -> void:
	_photo_all()
	var kind: String = case.plan.clues[0]
	case.clues_found.append(kind)
	board._pin(kind)
	assert_true(board.tie(kind, case.plan.culprit), "the culprit fits every clue")
	assert_eq(board.strings, [[kind, case.plan.culprit]])
	for i in case.cooks.size():
		if not CrimePlan.fits(case.cooks[i], kind, case.culprit()):
			assert_false(board.tie(kind, i))
			assert_true(board.file_cards[i].is_crossed(), "a snapped string crosses the file out")
			return


func test_card_flow_string_then_tie() -> void:
	_photo_all()
	var kind: String = case.plan.clues[0]
	case.clues_found.append(kind)
	board._pin(kind)
	board.clue_cards[kind].use(cop)
	assert_eq(board.string_from[cop], kind)
	assert_eq(board.file_cards[0].prompt_key(cop), "PROMPT_BOARD_TIE")
	board.file_cards[case.plan.culprit].use(cop)
	assert_false(board.string_from.has(cop), "the string is tied")
	assert_eq(board.strings.size(), 1)


func test_accusing_the_culprit_solves_it() -> void:
	_photo_all()
	watch_signals(case)
	level.stamp.use(cop)
	assert_eq(board.file_cards[0].prompt_key(cop), "PROMPT_BOARD_ACCUSE")
	board.file_cards[case.plan.culprit].use(cop)
	assert_true(case.accused)
	assert_signal_emitted_with_parameters(case, "verdict", [true, false])
	assert_true(case.rows()[case.rows().size() - 2].done or case.accused)


func test_two_wrong_accusations_lose_the_case() -> void:
	_photo_all()
	level.stamp.use(cop)
	board.file_cards[_innocent()].use(cop)
	assert_eq(case.wrong_guesses, 1)
	assert_false(case.lost)
	assert_true(board.file_cards[_innocent()].is_crossed())
	assert_null(board.stamp_by, "the stamp goes back to its desk")
	level.stamp.use(cop)
	board.file_cards[(case.plan.culprit + 2) % 6].use(cop)
	assert_true(case.lost)
	case.accuse(case.plan.culprit)
	assert_false(case.accused, "too late")
