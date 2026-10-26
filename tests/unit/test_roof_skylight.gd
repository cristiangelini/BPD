extends GutTest

## The roof jailbreak, step 1 (fuga-techo.md): drawn in eighths, the night guard who keeps the key on his belt, and in
## each cell the bunk's two sheets, a spare mattress and the skylight: too high from the floor, reached on the mattress
## or on a crouched partner's shoulders, pushed open with creaks the guard hears, and through it up onto the storage
## room over the cells and back down.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const TEST_PATH := "user://test_partidas/fuga_techo_claraboya.json"

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


func _under(skylight: CellSkylight, height: float) -> void:
	var at := JailbreakLevel.SKYLIGHTS[skylight.cell]
	cop.global_position = lot * Vector3(at.x, height, at.z)


func test_drawn_in_eighths() -> void:
	assert_true(JailbreakLevel.VARIANTS.has("roof"))
	assert_true(JailbreakLevel.VARIANTS.size() >= 8)
	assert_eq(JailbreakLevel.pick_variant(1, PackedStringArray(["--jailbreak=roof"])), "roof")


func test_the_night() -> void:
	assert_true(guard.key_on_belt)
	assert_eq(guard.prompt_key(cop), "", "nothing to take from him")
	assert_eq(level.skylights.size(), 2)
	assert_eq(get_tree().get_nodes_in_group("bed_sheets").size(), 4, "two sheets per bunk")
	assert_eq(get_tree().get_nodes_in_group("cell_mattresses").size(), 2)
	var loose := level.skylights.filter(func(s: CellSkylight) -> bool:
		return s.pushes_left == CellSkylight.LOOSE_PUSHES)
	assert_eq(loose.size(), 1, "the seed's loose one")


func test_too_high_from_the_floor() -> void:
	var skylight := level.skylights[0]
	_under(skylight, 0.05)
	assert_false(skylight.reaches(cop))
	assert_eq(skylight.prompt_key(cop), "PROMPT_SKYLIGHT_TOO_HIGH")
	var before := skylight.pushes_left
	skylight.use(cop)
	assert_eq(skylight.pushes_left, before)


func test_on_a_crouched_partners_shoulders() -> void:
	var partner: Cop = COP_SCENE.instantiate()
	partner.input_enabled = false
	level.add_child(partner)
	var at := JailbreakLevel.SKYLIGHTS[0]
	partner.global_position = lot * Vector3(at.x, 0.05, at.z + 0.6)
	partner.set_crouching(true)
	cop.boost_on(partner)
	assert_true(level.skylights[0].reaches(cop), "high enough on its shoulders")
	partner.free()


func test_pushing_it_creaks_and_opens_it() -> void:
	var skylight := level.skylights[0]
	_under(skylight, 0.8)
	assert_eq(skylight.prompt_key(cop), "PROMPT_SKYLIGHT_PUSH")
	var pushes := skylight.pushes_left
	for i in pushes:
		skylight.push()
		assert_true(guard.said().begins_with("ROOF_GUARD_CREAK"), "he hears it creak")
	assert_almost_eq(guard.suspicion, pushes * RoofGuard.CREAK_SUSPICION, 0.01)
	assert_true(skylight.is_open())
	assert_eq(skylight.prompt_key(cop), "PROMPT_SKYLIGHT_UP")


func test_up_through_it_and_back_down() -> void:
	var skylight := level.skylights[1]
	while not skylight.is_open():
		skylight.push()
	_under(skylight, 0.8)
	skylight.use(cop)
	assert_gt(cop.global_position.y - lot.origin.y, StationRooms.CEILING, "up on the storage room")
	assert_true(level.outside_cells(cop.global_position), "out of the cells")
	await wait_physics_frames(10)
	assert_gt(cop.global_position.y - lot.origin.y, StationRooms.CEILING, "standing on it")
	assert_eq(skylight.prompt_key(cop), "PROMPT_SKYLIGHT_DOWN")
	skylight.use(cop)
	assert_lt(cop.global_position.y - lot.origin.y, 1.0, "back down")
	assert_false(level.outside_cells(cop.global_position), "in the cell")


func test_the_mattress_on_the_bunk_is_high_enough() -> void:
	var mattress: CellMattress = level.get_node("CellMattress0")
	mattress.global_transform = lot * Transform3D(Basis(Vector3.UP, PI / 2), Vector3(8.3, 0.75, 1.6))
	await wait_physics_frames(40)
	_under(level.skylights[0], 0.0)
	cop.global_position = lot * Vector3(8.3, 1.4, 1.6)
	await wait_physics_frames(40)
	assert_true(level.skylights[0].reaches(cop), "on the mattress on the bunk (%.2f m)" % (cop.global_position.y - lot.origin.y))
