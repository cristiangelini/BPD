extends GutTest

## The bakery's second story, the sneezing flour (docs/diseno/panaderia.md, "Polvo para estornudar").

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")
const TICK := 1.0 / 60.0


func _bakery(story := "sneeze", case_seed := 5) -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.story_id = story
	bakery.case_seed = case_seed
	bakery.get_node("Cop").input_enabled = false
	bakery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(bakery)
	bakery._customer_wait = 999.0
	return bakery


func test_the_story_is_drawn_with_the_seed_or_picked_by_argument() -> void:
	var drawn := {}
	for case_seed in range(1, 10):
		drawn[Bakery.pick_story(case_seed, [])] = true
	assert_eq(drawn.size(), Bakery.STORIES.size(), "every story comes up")
	assert_eq(Bakery.pick_story(2, ["--story=sneeze"]), "sneeze")
	assert_eq(Bakery.pick_story(2, ["--story=bingo"]), Bakery.pick_story(2, []), "the grandpa's stories don't count")


func test_one_of_the_five_sacks_is_the_pepper_sack() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	assert_eq(bakery.sacks.size(), Bakery.SACKS.size())
	var peppered := bakery.sacks.filter(func(sack: RigidBody3D) -> bool: return sack is Evidence)
	assert_eq(peppered.size(), 1)
	assert_eq(bakery.main, peppered[0])
	assert_null(bakery.ring, "no ring in this story")
	assert_has(bakery.raid.suspicions, "sneeze")
	assert_eq(bakery.extras.size(), 2)


func test_in_the_ring_story_every_sack_is_plain_flour() -> void:
	var bakery := _bakery("ring")
	await wait_physics_frames(2)
	assert_eq(bakery.sacks.filter(func(sack: RigidBody3D) -> bool: return sack is Evidence).size(), 0)


func test_near_the_pepper_sack_a_cop_sneezes_and_drops_what_they_hold() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var cop: Cop = bakery.get_node("Cop")
	var grabber: Grabber = cop.get_node("Grabber")
	var loaf := bakery.loaves[0]
	grabber.held = loaf
	loaf.hold(grabber.get_instance_id(), loaf.global_position)
	cop.global_position = Vector3(0, 0.1, -3.0)
	bakery.rig.sneezes(SneezeRig.SNEEZE_EVERY + SneezeRig.SNEEZE_JITTER + 0.1)
	assert_not_null(grabber.held, "too far from the sack to sneeze")
	cop.global_position = bakery.main.global_position + Vector3(0, 0, 1.5)
	bakery.rig.sneezes(TICK)
	bakery.rig.sneezes(SneezeRig.SNEEZE_EVERY + SneezeRig.SNEEZE_JITTER + 0.1)
	assert_null(grabber.held, "the sneeze makes the cop let go")
	assert_false(loaf.is_held())


func test_the_pepper_sack_needs_two_cops_to_lift() -> void:
	var bakery := _bakery()
	await wait_physics_frames(30)
	var sack := bakery.main
	var floor_y := sack.global_position.y
	var above := sack.global_position + Vector3.UP
	sack.hold(1, above)
	await wait_seconds(1.0)
	assert_lt(sack.global_position.y - floor_y, 0.3, "one cop can't lift it")
	sack.hold(2, above)
	await wait_seconds(1.0)
	assert_gt(sack.global_position.y - floor_y, 0.6, "two cops lift it")
	sack.let_go(1)
	sack.let_go(2)


func test_the_pepper_sack_in_the_trunk_solves_the_case() -> void:
	var bakery := _bakery()
	await wait_physics_frames(10)
	var sack := bakery.main
	sack.global_position = bakery.car.to_global(Vector3(0, 0.8, -1.7))
	await wait_physics_frames(20)
	assert_true(bakery.car.is_delivered(sack))
	assert_true(bakery.raid.mark(bakery.raid.suspicions.find("sneeze")))
	bakery.car.enter(bakery.get_node("Cop"))
	assert_true(bakery.raid.case_solved)
