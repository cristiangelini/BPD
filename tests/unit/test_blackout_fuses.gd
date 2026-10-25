extends GutTest

## The blackout's fuse board, its three fuses and El Chispa (carcel-corte-de-luz.md, step 5).

const LEVEL := preload("res://scenes/levels/prison_blackout.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: BlackoutPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.blackout


func _at(x: float, z: float, y := 0.1) -> Vector3:
	return prison.global_transform * Vector3(x, y, z)


func _fuses() -> Array[Node]:
	return get_tree().get_nodes_in_group("blackout_fuses").filter(func(fuse: Node) -> bool:
		return prison.is_ancestor_of(fuse) and not fuse.is_queued_for_deletion())


func _hand(fuse: Fuse) -> void:
	cop.get_node("Grabber").grab(fuse)


func test_the_board_is_at_the_end_of_the_corridor() -> void:
	assert_not_null(prison.fuse_board)
	assert_true(prison.in_block(prison.fuse_board.global_position + Vector3(0, 0, 0.3)))
	assert_eq(prison.fuse_board.filled, 0)


func test_two_fuses_lie_around_one_in_the_kitchen() -> void:
	var fuses := _fuses()
	assert_eq(fuses.size(), 2)
	var in_kitchen := fuses.filter(func(fuse: Node3D) -> bool:
		var local := prison.global_transform.affine_inverse() * fuse.global_position
		return local.x > PrisonLevel.KITCHEN_X)
	assert_eq(in_kitchen.size(), 1)
	assert_false(prison.kitchen_door.locked, "the guards left the kitchen open")


func test_el_chispa_is_one_and_has_the_third() -> void:
	var chispas := plan.inmates.filter(func(inmate: BlackoutInmate) -> bool:
		return inmate.role == BlackoutInmate.Role.CHISPA)
	assert_eq(chispas.size(), 1)
	assert_eq(chispas[0], plan.chispa)
	assert_true(plan.chispa.has_fuse)
	assert_not_null(plan.chispa.get_node_or_null("Sparks"))
	assert_eq(plan.chispa.route[-1], BlackoutPlan.BOARD_SPOT, "he waits by the board")


func test_e_with_a_fuse_puts_it_in() -> void:
	var fuse: Fuse = _fuses()[0]
	_hand(fuse)
	assert_eq(prison.fuse_board.prompt_key(cop), "PROMPT_FUSE_IN")
	prison.fuse_board.use(cop)
	assert_eq(prison.fuse_board.filled, 1)
	assert_null(cop.get_node("Grabber").held)
	await wait_physics_frames(1)
	assert_eq(_fuses().size(), 1)


func test_e_without_a_fuse_says_whats_missing() -> void:
	assert_eq(prison.fuse_board.prompt_key(cop), "PROMPT_FUSE_BOARD")
	prison.fuse_board.use(cop)
	assert_eq(prison.fuse_board.filled, 0)


func test_cuffed_el_chispa_drops_his_fuse() -> void:
	plan.start()
	plan.chispa.cuffed(Handcuffs.SECONDS)
	assert_false(plan.chispa.has_fuse)
	await wait_physics_frames(1)
	assert_eq(_fuses().size(), 3)


func test_with_three_the_light_comes_back() -> void:
	plan.start()
	watch_signals(plan)
	var jailed: BlackoutInmate = plan.inmates.filter(func(inmate: BlackoutInmate) -> bool:
		return inmate.role == BlackoutInmate.Role.WANDER)[0]
	var middle := BlackoutPlan.cell_middle(2)
	jailed.global_position = _at(middle.x, middle.y)
	jailed.cuffed(Handcuffs.SECONDS)
	(OwnerEscort.of(jailed) as BlackoutEscort).board()
	for i in FuseBoard.SLOTS:
		prison.fuse_board.put_in()
	assert_true(plan.lights_on)
	assert_true(prison.lights_on)
	assert_signal_emitted(plan, "lights_came_back")
	assert_true(prison.cell_doors[2].locked, "the cell with someone in it locks")
	for inmate in plan.inmates:
		assert_true(inmate.surrendered, inmate.name)
	var was := plan.inmates[0].global_position
	await wait_seconds(0.5)
	assert_almost_eq(plan.inmates[0].global_position.distance_to(was), 0.0, 0.01, "they sit and stay")


func test_el_chispa_pulls_a_fuse_back_out() -> void:
	plan.start()
	plan.chispa.global_position = prison.global_transform * Vector3(BlackoutPlan.BOARD_SPOT.x, 0.1,
		BlackoutPlan.BOARD_SPOT.y)
	plan.chispa.head_for([BlackoutPlan.BOARD_SPOT] as Array[Vector2])
	prison.fuse_board.put_in()
	assert_eq(plan._pull_left, BlackoutPlan.PULL_DELAY)
	plan._pull_left = 0.05
	await wait_seconds(0.4)
	assert_eq(prison.fuse_board.filled, 0, "pulled")
	await wait_physics_frames(1)
	assert_eq(_fuses().size(), 3, "tossed somewhere in the dark")


func test_frozen_el_chispa_doesnt_pull() -> void:
	plan.start()
	plan.chispa.global_position = prison.global_transform * Vector3(BlackoutPlan.BOARD_SPOT.x, 0.1,
		BlackoutPlan.BOARD_SPOT.y)
	prison.fuse_board.put_in()
	plan._pull_left = 0.05
	plan.chispa.set_lit(true)
	await wait_physics_frames(3)
	assert_eq(prison.fuse_board.filled, 1)


func test_el_chispa_in_the_punishment_cell() -> void:
	plan.start()
	prison.punishment_door.set_open(true)
	var cell := PrisonLevel.PUNISHMENT
	plan.chispa.global_position = prison.global_transform * Vector3(cell.get_center().x, 0.1, cell.get_center().y)
	plan.chispa.cuffed(Handcuffs.SECONDS)
	var escort := OwnerEscort.of(plan.chispa) as BlackoutEscort
	escort.board()
	assert_eq(escort.cell, PrisonLevel.PUNISHMENT_CELL)
	assert_false(plan.chispa_punished(), "the door is still open")
	prison.punishment_door.use(cop)
	assert_true(plan.chispa_punished())


func test_the_routes_to_the_board() -> void:
	for cell in PrisonLevel.CELLS * 2:
		assert_eq(BlackoutPlan.board_route(cell)[-1], BlackoutPlan.BOARD_SPOT)
	assert_eq(plan.route_to_board(_at(2.0, 3.0))[-1], BlackoutPlan.BOARD_SPOT)
	assert_eq(plan.route_to_board(_at(-1.0, -10.0)).size(), 2, "from the corridor, straight down it")


func test_the_lines_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key in ["PROMPT_HOLDING_FUSE", "PROMPT_FUSE_IN", "PROMPT_FUSE_BOARD", "HINT_FUSE_BOARD", "FUSE_BOARD_SIGN",
			"HINT_LIGHTS_BACK", "BLACKOUT_SURRENDER", "CHISPA_CUFFED", "CHISPA_GOES", "CHISPA_PULLS"]:
		assert_ne(tr(key), key)
