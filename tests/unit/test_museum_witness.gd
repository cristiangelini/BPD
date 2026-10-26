extends GutTest

## The museum's witness and alibi clues (escena-museo.md, step 4c): the living statue who talks for a coin and takes
## offense, and the bathroom that tells who lied unless a cop used the toilet first (LivingStatue, StatueCoin,
## BathroomSpot).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A museum case whose clues have `kind` (or don't, with `has` false).
func _case(kind: String, has := true) -> CrimeSceneCase:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(GuardTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.museum.clues)
		if plan.clues.has(kind) == has:
			var museum := Museum.new()
			museum.case_seed = seed_value
			add_child_autofree(museum)
			var case := CrimeSceneCase.new()
			case.case_seed = seed_value
			case.place = museum
			add_child_autofree(case)
			case.start()
			return case
	return null


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0, 100)
	return cop


func test_the_statue_talks_only_with_a_coin_in_the_hat() -> void:
	var case := _case("witness")
	var statue := (case.place as Museum).statue
	statue.use(_cop())
	assert_eq(statue.said(), "STATUE_STILL")
	assert_does_not_have(case.clues_found, "witness")
	statue.tip(_cop())
	assert_has(case.clues_found, "witness")
	assert_eq(statue.said(), "STATUE_SAW_GLASSES" if case.culprit().glasses else "STATUE_SAW_NO_GLASSES")
	assert_eq(case.clue_line("witness"),
		tr("CLUE_MUSEUM_witness_glasses" if case.culprit().glasses else "CLUE_MUSEUM_witness_no_glasses"))


func test_cuffed_the_statue_is_offended_for_good() -> void:
	var case := _case("witness")
	var museum := case.place as Museum
	museum.statue.cuffed(3.0)
	assert_true(museum.witness_offended())
	assert_has(case.ruined, "witness")
	museum.statue.tip(_cop())
	assert_eq(museum.statue.said(), "STATUE_OFFENDED")


func test_the_ticket_desk_has_coins_for_the_hat() -> void:
	var case := _case("witness", false)
	var museum := case.place as Museum
	var coins := museum.find_children("Coin*", "StatueCoin", false, false)
	assert_eq(coins.size(), Museum.COINS)
	museum.statue.tip(_cop())
	assert_eq(museum.statue.said(), "STATUE_NOTHING", "he saw nothing in this case")


func test_the_sink_shows_the_bathroom_as_it_was() -> void:
	var case := _case("alibi")
	var museum := case.place as Museum
	var sink := museum.get_node("Bathroom_sink") as BathroomSpot
	assert_eq(sink.prompt_key(null), "PROMPT_BATHROOM_sink")
	sink.use(_cop())
	assert_has(case.clues_found, "alibi")
	var line := case.clue_line("alibi")
	for detail in museum.bathroom_details:
		assert_string_contains(line, tr("ALIBI_SHORT_" + detail))


func test_using_the_toilet_first_loses_the_alibi() -> void:
	var case := _case("alibi")
	var museum := case.place as Museum
	(museum.get_node("Bathroom_toilet") as BathroomSpot).use(_cop())
	assert_has(case.ruined, "alibi")
	(museum.get_node("Bathroom_sink") as BathroomSpot).use(_cop())
	assert_does_not_have(case.clues_found, "alibi")
