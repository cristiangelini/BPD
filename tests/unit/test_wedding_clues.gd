extends GutTest

## The wedding's clues (escena-boda.md, step 4b): WeddingClues puts the case's 4 of 6 where they go, each found and
## ruined its own way (the ring box's prints, the footprint in the rice the waiter sweeps, the hair in the frosting and
## the bite that cutting the cake loses, the video's red button), and grandma Chola, who only talks once she hears.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _wedding_case(seed_value: int) -> Array:
	var hall := WeddingHall.new()
	hall.case_seed = seed_value
	add_child_autofree(hall)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = hall
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [hall, case, cop]


## A seed whose plan has all these clues.
func _seed_with(kinds: Array[String]) -> int:
	for seed_value in range(1, 500):
		var plan := CrimePlan.draw(WeddingTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.wedding.clues)
		if kinds.all(func(kind: String) -> bool: return plan.clues.has(kind)):
			return seed_value
	return -1


func test_the_clues_go_where_they_go() -> void:
	for seed_value in [2, 11, 23]:
		var made := _wedding_case(seed_value)
		var hall: WeddingHall = made[0]
		var case: CrimeSceneCase = made[1]
		var clues := case.plan.clues
		assert_eq(clues.size(), 4)
		assert_eq(hall.clues.ring_box.has_prints, clues.has("prints"))
		assert_eq(hall.has_node("RicePrint"), clues.has("footprint"))
		assert_eq(hall.has_node("Clue_hair"), clues.has("hair"))
		assert_eq(hall.has_node("CakeBite"), clues.has("bite"))
		assert_eq(hall.clues.video.has_recording, clues.has("recording"))
		assert_eq(hall.grandma.knows, clues.has("witness"))
		for kind: String in CrimeSceneCase.VARIANTS.wedding.clues:
			var line := case.clue_line(kind)
			assert_false(line.begins_with("CLUE_"), "%s has its line" % kind)
			assert_ne(tr("CLUE_CRIME_WEDDING_RUINED_" + kind), "CLUE_CRIME_WEDDING_RUINED_" + kind)
			assert_ne(tr("HINT_CRIME_WEDDING_RUINED_" + kind), "HINT_CRIME_WEDDING_RUINED_" + kind)


func test_the_ring_box_keeps_prints_until_touched() -> void:
	var made := _wedding_case(_seed_with(["prints"]))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var box := hall.clues.ring_box
	assert_eq(box.prompt_key(cop), "PROMPT_RING_BOX")
	box.use(cop)
	assert_true(case.ruined.has("prints"), "touched first, the prints are lost")
	assert_eq(box.dusted(cop), "PRINTS_RING_BOX_SMUDGED")
	made = _wedding_case(_seed_with(["prints"]))
	assert_eq((made[0] as WeddingHall).clues.ring_box.dusted(made[2]), "PRINTS_RING_BOX")
	assert_true((made[1] as CrimeSceneCase).clues_found.has("prints"))


func test_cutting_the_cake_loses_the_hair_and_the_bite() -> void:
	var made := _wedding_case(_seed_with(["hair", "bite"]))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var bite: CakeBite = hall.get_node("CakeBite")
	assert_eq(bite.photo_clues().size(), 1, "the bite can be photographed")
	hall.search("cake", cop)
	assert_true(case.ruined.has("hair"))
	assert_true(case.ruined.has("bite"))
	assert_eq(bite.photo_clues().size(), 0, "nothing left to photograph")


func test_a_photo_of_the_bite_saves_it() -> void:
	var made := _wedding_case(_seed_with(["bite"]))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var bite: CakeBite = hall.get_node("CakeBite")
	bite.add_clue(bite.photo_clues().keys()[0])
	assert_true(case.clues_found.has("bite"))
	hall.search("cake", made[2])
	assert_false(case.ruined.has("bite"), "found before the cut, it stays found")


func test_the_waiter_sweeps_the_footprint() -> void:
	var made := _wedding_case(_seed_with(["footprint"]))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	case.elapsed = WeddingClues.SWEEP_AT
	await wait_physics_frames(2)
	assert_true(hall.clues.swept)
	assert_false(hall.get_node("Rice").visible, "the rice is gone")
	assert_true(case.ruined.has("footprint"))


func test_the_video_plays_or_gets_deleted() -> void:
	var made := _wedding_case(_seed_with(["recording"]))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	hall.clues.video.play(cop)
	assert_true(case.clues_found.has("recording"))
	made = _wedding_case(_seed_with(["recording"]))
	(made[0] as WeddingHall).clues.video.delete(made[2])
	assert_true((made[1] as CrimeSceneCase).ruined.has("recording"))


func test_grandma_talks_once_she_hears() -> void:
	var made := _wedding_case(_seed_with(["witness"]))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var grandma := hall.grandma
	grandma.use(cop)
	assert_eq(grandma.said(), "WEDDING_GRANDMA_LINE_0", "deaf")
	cop.global_position = grandma.global_position + Vector3(20, 0, 0)
	hall.shouted_by(cop)
	assert_false(grandma.hearing, "too far to hear the shout")
	cop.global_position = grandma.global_position + Vector3(2, 0, 0)
	hall.shouted_by(cop)
	assert_true(grandma.hearing, "a shout up close")
	assert_false(hall.witness_offended(), "the shout doesn't offend her")
	assert_true(case.clues_found.has("witness"))
	assert_string_contains(grandma.said(), tr("COLOGNE_" + str(case.culprit().cologne)))


func test_the_ear_trumpet_or_the_cuffs() -> void:
	var made := _wedding_case(_seed_with(["witness"]))
	var hall: WeddingHall = made[0]
	assert_true(hall.ear_trumpet is EarTrumpet, "her trumpet can be picked up")
	hall.grandma.hear()
	assert_true((made[1] as CrimeSceneCase).clues_found.has("witness"))
	made = _wedding_case(_seed_with(["witness"]))
	hall = made[0]
	hall.grandma.cuffed(1.0)
	assert_true(hall.witness_offended())
	assert_true((made[1] as CrimeSceneCase).ruined.has("witness"))
	hall.grandma.hear()
	assert_false(hall.grandma.hearing, "offended, she won't listen")
