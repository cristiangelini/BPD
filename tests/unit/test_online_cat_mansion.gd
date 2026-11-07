extends GutTest

## The Monedero mansion online (escena-gato.md, step 7; docs/diseno/online.md): it's drawn among the crime scenes, and
## the guests' mansion follows the host's nephews (beanie, sleeves), Don Plumas, the señora's patience, the broken
## vases and the cats.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/cat_mansion.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: CatMansionLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 21
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _mansion(net: Node) -> CatMansion:
	return (OnlinePcs.level(net) as CatMansionLevel).mansion


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as CatMansionLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as CatMansionLevel).case.tip_given, 5.0)
	return pcs


func test_the_mansion_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "cat_mansion")
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("cat_mansion"), "Play draws it")


func test_the_nephews_the_parrot_and_the_vases_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _mansion(pcs[0])
	var guest := _mansion(pcs[1])
	assert_true(guest.case.follower)
	host.nephews[2].ask_beanie()
	host.nephews[2].roll_up_sleeves()
	host.parrot.feed()
	host.vases[3].shatter()
	await wait_until(func() -> bool: return guest.vases[3].broken, 5.0)
	await wait_until(func() -> bool: return not guest.nephews[2].beanie_on, 5.0)
	var nephew := guest.nephews[2]
	assert_true(nephew.sleeves_up)
	assert_false(nephew.part("beanie").visible, "his hair shows")
	assert_false(nephew.part("cuff_left").visible, "his sleeves are up")
	assert_true(guest.parrot.fed)


func test_the_patience_and_the_cats_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _mansion(pcs[0])
	var guest := _mansion(pcs[1])
	host.patience.lose("armchair")
	host.patience.lose("wrong_cat", true)
	var cat := host.cats[1]
	cat.global_position = host.to_global(CatMansion.FOUNTAIN_AT + Vector3(1, 0.1, 0))
	await wait_until(func() -> bool: return guest.patience.value == host.patience.value, 5.0)
	assert_eq(guest.patience.value, CatPatience.FULL - CatPatience.COSTS.armchair - CatPatience.COSTS.wrong_cat)
	await wait_until(func() -> bool:
		return guest.cats[1].global_position.distance_to(host.cats[1].global_position) < 0.5, 5.0)
	assert_true(guest.cats[1].follower, "she follows the host's cat")
