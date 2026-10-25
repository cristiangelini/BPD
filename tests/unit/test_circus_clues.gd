extends GutTest

## The circus's clues and how each gets ruined (escena-circo.md, step 6b): Galleta's fish bucket, the footprint in the
## sawdust, the hair in the pool and its tap, the bitten fish and the ringmaster's camera (FishBucket, FlourPrint,
## CrimeClueItem's circus look, PoolTap, RingmasterCamera).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A circus case whose clues have `kind` (or don't, with `has` false).
func _case(kind: String, has := true) -> CrimeSceneCase:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(ClownTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.circus.clues)
		if plan.clues.has(kind) == has:
			var circus := Circus.new()
			circus.case_seed = seed_value
			add_child_autofree(circus)
			var case := CrimeSceneCase.new()
			case.case_seed = seed_value
			case.place = circus
			add_child_autofree(case)
			case.start()
			return case
	return null


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0, 100)
	return cop


func test_the_circus_lines_say_what_each_clue_tells() -> void:
	var case := _case("recording")
	var who := case.culprit()
	assert_eq(case.clue_line("footprint"), tr("CLUE_CIRCUS_footprint") % who.shoe)
	assert_eq(case.clue_line("recording"), tr("CLUE_CIRCUS_recording") % tr("HONK_" + str(who.honk)))
	assert_eq(case.clue_line("witness"),
		tr("CLUE_CIRCUS_witness_glasses" if who.glasses else "CLUE_CIRCUS_witness_no_glasses"))
	assert_eq(case.clue_line("prints"), tr("CLUE_CIRCUS_prints"))


func test_the_bucket_has_the_culprits_prints() -> void:
	var case := _case("prints")
	var bucket := (case.place as Circus).fish_bucket
	assert_true(bucket.has_prints)
	assert_eq(bucket.dusted(null), "PRINTS_FISH")
	assert_has(case.clues_found, "prints")


func test_grabbing_the_bucket_first_covers_the_prints() -> void:
	var case := _case("prints")
	var bucket := (case.place as Circus).fish_bucket
	bucket.use(_cop())
	assert_has(case.ruined, "prints")
	assert_eq(bucket.dusted(null), "PRINTS_FISH_SMUDGED")
	assert_does_not_have(case.clues_found, "prints")


func test_the_footprint_is_in_the_sawdust() -> void:
	var case := _case("footprint")
	var circus := case.place as Circus
	var footprint := circus.get_node("SawdustPrint") as FlourPrint
	assert_eq(case.flour_print, footprint)
	assert_eq(footprint.shoe, case.culprit().shoe)
	assert_ne(footprint.dust, FlourPrint.FLOUR, "sawdust, not flour")
	footprint.wipe()
	assert_has(case.ruined, "footprint")


func test_the_hair_lies_in_the_pool_and_gets_bagged() -> void:
	var case := _case("hair")
	var circus := case.place as Circus
	var hair: CrimeClueItem = case.items.hair
	assert_eq(hair.look, "circus")
	assert_false(hair.is_food(), "nobody eats a hair")
	var off := hair.position - Circus.POOL_AT
	assert_lt(Vector2(off.x, off.z).length(), Circus.POOL_RADIUS)
	hair.bag(_cop())
	assert_has(case.clues_found, "hair")
	circus.open_tap(null)
	assert_false(hair.spoiled, "bagged, the water can't take it")


func test_the_tap_washes_the_hair_away() -> void:
	var case := _case("hair")
	var circus := case.place as Circus
	circus.open_tap(null)
	assert_true((case.items.hair as CrimeClueItem).spoiled)
	assert_has(case.ruined, "hair")


func test_the_tap_without_the_hair_clue_does_nothing() -> void:
	var case := _case("hair", false)
	(case.place as Circus).open_tap(null)
	assert_true(case.ruined.is_empty())


func test_the_bitten_fish_is_food() -> void:
	var case := _case("bite")
	var fish: CrimeClueItem = case.items.bite
	assert_true(fish.is_food())
	fish.eat(_cop())
	assert_has(case.ruined, "bite")


func test_play_shows_the_recording() -> void:
	var case := _case("recording")
	var camera := (case.place as Circus).camera
	camera.play(_cop())
	assert_has(case.clues_found, "recording")
	camera.delete(null)
	assert_does_not_have(case.ruined, "recording", "already seen, deleting it loses nothing")


func test_delete_wipes_the_recording() -> void:
	var case := _case("recording")
	var camera := (case.place as Circus).camera
	camera.delete(null)
	assert_true(camera.deleted)
	assert_has(case.ruined, "recording")
	camera.play(_cop())
	assert_does_not_have(case.clues_found, "recording")


func test_the_buttons_press_their_own() -> void:
	var case := _case("recording")
	var camera := (case.place as Circus).camera
	var delete := camera.get_node("Button_delete") as CameraButton
	assert_eq(delete.prompt_key(null), "PROMPT_CAMERA_delete")
	delete.use(_cop())
	assert_true(camera.deleted)


func test_the_ruined_lines_are_the_circus_ones() -> void:
	var case := _case("recording")
	(case.place as Circus).camera.delete(null)
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "- " + tr("CLUE_CIRCUS_RUINED_recording"))
