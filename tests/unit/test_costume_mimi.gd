extends GutTest

## Mimí at the costume shop (allanamiento-disfraces.md, step 4): she hides among the mannequins on a spot drawn with
## the seed, passes for one of them, giggles every 20 s, and the cop who finds her hears what she saw, once per cop;
## 30 s later she hides on another spot.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop(seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_she_hides_on_a_spot_drawn_with_the_seed() -> void:
	var place := _shop()
	var mimi := place.niece
	assert_not_null(mimi)
	assert_eq(mimi.position, CostumeShop.MIMI_SPOTS[mimi.spot])
	var again := _shop()
	assert_eq(again.niece.spot, mimi.spot, "same seed, same spot")
	var spots := {}
	for seed in range(1, 40):
		spots[_shop(seed).niece.spot] = true
	assert_gt(spots.size(), 3, "the seed moves her around")


func test_her_spots_are_clear_of_the_mannequins_racks_and_aisles() -> void:
	for at: Vector3 in CostumeShop.MIMI_SPOTS:
		for mannequin: Vector3 in CostumeShop.MANNEQUINS:
			assert_gt(Vector2(at.x - mannequin.x, at.z - mannequin.z).length(), 0.7, "%s by a mannequin" % at)
		for rack: Vector3 in CostumeShop.RACKS:
			var area := Rect2(rack.x - CostumeShop.RACK_SIZE.x / 2 - 0.35, rack.z - CostumeShop.RACK_SIZE.z / 2 - 0.35,
				CostumeShop.RACK_SIZE.x + 0.7, CostumeShop.RACK_SIZE.z + 0.7)
			assert_false(area.has_point(Vector2(at.x, at.z)), "%s in a rack" % at)
		assert_lt(at.z, CostumeShop.AISLE_Z - 1.0, "%s off the front aisle" % at)


func test_hidden_she_passes_for_a_mannequin_and_giggles() -> void:
	var place := _shop()
	var mimi := place.niece
	var cop: Cop = place.get_node("Cop")
	assert_eq(mimi.prompt_key(cop), "PROMPT_GRAB", "the mannequins' prompt")
	var bubble: Label3D = mimi.get_node("Bubble")
	assert_false(bubble.visible)
	mimi._giggle_left = 0.05
	await wait_physics_frames(5)
	assert_true(bubble.visible)
	assert_eq(bubble.text, "MIMI_GIGGLE")


func test_the_cop_who_finds_her_hears_what_she_saw_once() -> void:
	var place := _shop()
	var mimi := place.niece
	var cop: Cop = place.get_node("Cop")
	mimi.clue = "LOC_by_stock_shelf"
	mimi.clue_speech = "MIMI_NOTHING"
	watch_signals(mimi)
	mimi.use(cop)
	assert_signal_emitted_with_parameters(mimi, "told", ["LOC_by_stock_shelf"])
	assert_true(mimi.is_found())
	assert_eq(mimi.prompt_key(cop), "PROMPT_TALK_MIMI")
	mimi.use(cop)
	assert_signal_emit_count(mimi, "told", 1, "once per cop")
	assert_eq((mimi.get_node("Bubble") as Label3D).text, "MIMI_AGAIN")


func test_trying_to_grab_her_finds_her_too() -> void:
	var place := _shop()
	var mimi := place.niece
	var cop: Cop = place.get_node("Cop")
	mimi._stand_on(0)
	await wait_physics_frames(2)
	cop.global_position = place.to_global(mimi.position + Vector3(-1.4, 0, 0))
	var her := place.to_global(mimi.position)
	cop.look_at(Vector3(her.x, cop.global_position.y, her.z))
	cop.get_node("Head").rotation.x = -0.5
	await wait_physics_frames(2)
	assert_false(cop.get_node("Grabber").try_grab(), "nothing in hand")
	assert_true(mimi.is_found())


func test_she_hides_again_on_another_spot() -> void:
	var place := _shop()
	var mimi := place.niece
	var first := mimi.spot
	mimi.find(place.get_node("Cop"))
	mimi._found_left = 0.05
	await wait_physics_frames(5)
	assert_false(mimi.is_found())
	assert_ne(mimi.spot, first)
	assert_eq(mimi.position, CostumeShop.MIMI_SPOTS[mimi.spot])
	for key: String in ["PROMPT_TALK_MIMI", "MIMI_GIGGLE", "MIMI_NOTHING", "MIMI_AGAIN"]:
		assert_ne(tr(key), key, key)
