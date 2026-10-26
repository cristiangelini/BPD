extends GutTest

## The roof jailbreak, step 3 (fuga-techo.md): the sheets knot into a rope (loose knots, tightened by hand), the rope
## ties to the antenna and the cops climb down it into the back alley; a loose knot gives with two on it, a short rope
## ends in a jump, and a catch puts a new padlock on the skylights and the sheets back on the bunks.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const TEST_PATH := "user://test_partidas/fuga_techo_cuerda.json"

var level: JailbreakLevel
var guard: RoofGuard
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "roof"
	level.case_seed = 4242
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as RoofGuard
	guard.set_physics_process(false)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _ropes() -> Array:
	return get_tree().get_nodes_in_group("sheet_ropes").filter(func(n: Node) -> bool: return not n.is_queued_for_deletion())


func _sheets() -> Array:
	return get_tree().get_nodes_in_group("bed_sheets").filter(func(n: Node) -> bool: return not n.is_queued_for_deletion())


func _hold(item: Grabbable) -> void:
	cop.global_position = item.global_position + Vector3(0, 0.1, 1.0)
	cop.get_node("Grabber").grab(item)


func _rope(knots: Array) -> SheetRope:
	var rope := SheetRope.new()
	rope.knots = knots
	level.add_child(rope)
	rope.global_position = lot * Vector3(0, JailbreakLevel.ROOF_Y + 0.3, -7.0)
	return rope


func _on_roof(who: Cop) -> void:
	who.global_position = level.antenna.global_position + lot.basis * Vector3(0, 0.1, 0.8)


func test_sheets_knot_into_a_rope() -> void:
	_hold(level.get_node("BedSheet0"))
	assert_eq((level.get_node("BedSheet1") as BedSheet).prompt_key(cop), "PROMPT_KNOT")
	(level.get_node("BedSheet1") as BedSheet).use(cop)
	await wait_physics_frames(2)
	assert_eq(_ropes().size(), 1)
	var rope: SheetRope = _ropes()[0]
	assert_eq(rope.sheets(), 2)
	assert_eq(rope.knots, [false], "a loose knot")
	assert_eq(_sheets().size(), 2)
	_hold(rope)
	(level.get_node("BedSheet2") as BedSheet).use(cop)
	await wait_physics_frames(2)
	assert_eq(_ropes().size(), 1)
	assert_eq((_ropes()[0] as SheetRope).sheets(), 3, "and one more")


func test_tightening_a_knot() -> void:
	var rope := _rope([true, false])
	cop.get_node("Grabber").release()
	assert_eq(rope.prompt_key(cop), "PROMPT_TIGHTEN")
	for i in SheetRope.TIGHTEN_PUSHES - 1:
		rope.tighten(cop)
	assert_false(rope.is_tight())
	rope.tighten(cop)
	assert_true(rope.is_tight())


func test_tied_to_the_antenna_down_into_the_alley() -> void:
	var rope := _rope([true, true, true])
	_hold(rope)
	assert_eq(level.antenna.prompt_key(cop), "PROMPT_TIE_ANTENNA")
	level.antenna.use(cop)
	assert_eq(level.antenna.sheets, 4)
	assert_true(level.antenna.reaches_down())
	await wait_physics_frames(2)
	assert_eq(_ropes().size(), 0, "on the antenna now")
	_on_roof(cop)
	assert_eq(level.antenna.prompt_key(cop), "PROMPT_CLIMB_DOWN")
	level.antenna.use(cop)
	level._climb(JailbreakLevel.CLIMB_TIME + 0.1)
	var at := lot.affine_inverse() * cop.global_position
	assert_lt(at.y, 1.0, "on the ground")
	assert_lt(at.z, -StationRooms.HALF_Z, "in the back alley")


func test_a_loose_knot_gives_with_two_on_it() -> void:
	var rope := _rope([true, false, true])
	_hold(rope)
	level.antenna.use(cop)
	var partner: Cop = COP_SCENE.instantiate()
	partner.input_enabled = false
	level.add_child(partner)
	_on_roof(cop)
	_on_roof(partner)
	level.antenna.use(cop)
	level.antenna.use(partner)
	assert_eq(level.antenna.sheets, 2, "it gave at the loose knot")
	assert_false(level.antenna.reaches_down())
	for who: Cop in [cop, partner]:
		assert_lt((lot.affine_inverse() * who.global_position).y, 1.0, "fell into the alley")
		assert_true(who.is_staggered(), "dizzy")
	partner.free()


func test_a_short_rope_ends_in_a_jump() -> void:
	var rope := _rope([true])
	_hold(rope)
	level.antenna.use(cop)
	_on_roof(cop)
	level.antenna.use(cop)
	level._climb(JailbreakLevel.CLIMB_TIME + 0.1)
	assert_lt((lot.affine_inverse() * cop.global_position).y, 1.0)
	assert_almost_eq(cop._stagger_left, JailbreakLevel.DIZZY, 0.01, "dizzy")


func test_caught_new_padlocks_and_the_sheets_back() -> void:
	while not level.skylights[0].is_open():
		level.skylights[0].push()
	_hold(level.get_node("BedSheet0"))
	(level.get_node("BedSheet1") as BedSheet).use(cop)
	await wait_physics_frames(2)
	_hold(_rope([true, true]))
	level.antenna.use(cop)
	guard.catch()
	await wait_physics_frames(2)
	for skylight in level.skylights:
		assert_eq(skylight.pushes_left, CellSkylight.LOCKED_PUSHES, "a new padlock")
	assert_false(level.antenna.is_tied())
	assert_eq(_ropes().size(), 0)
	assert_eq(_sheets().size(), 4, "back on the bunks")
