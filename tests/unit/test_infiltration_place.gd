extends GutTest

## The common base of the infiltration places (infiltracion-coro.md, step 1): the club is one, and the case plays on
## top of it through the place, not the club, so the choir can reuse it.

const LEVEL := preload("res://scenes/levels/grandpa_club.tscn")

var club: GrandpaClub


func before_each() -> void:
	club = LEVEL.instantiate()
	club.get_node("Cop").input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)


func test_the_club_is_an_infiltration_place_with_chela_as_its_boss() -> void:
	assert_true(club is InfiltrationPlace)
	assert_eq(club.variant, "club")
	assert_eq(club.boss, club.chela)
	assert_eq(club.suspicion.boss, club.chela)
	assert_eq(club.case.place, club)


func test_every_variant_has_all_its_texts() -> void:
	for id: String in InfiltrationCase.VARIANTS:
		var keys: Dictionary = InfiltrationCase.VARIANTS[id]
		for key in ["story", "brief", "go", "in", "found", "rows", "evidence", "boss", "getaway", "boss_cuffed",
				"cuff_row", "catch_row"]:
			assert_true(keys.has(key), "%s has %s" % [id, key])
		assert_true(SuspectCar.MODELS.has(keys.getaway), "%s runs off in a known getaway" % id)


func test_the_case_takes_the_club_texts() -> void:
	assert_eq(club.case.texts(), InfiltrationCase.VARIANTS["club"])
	assert_eq(club.case.rows()[0].text, "OBJ_CLUB_GET_IN")


func test_the_getaway_waits_out_of_the_entrance() -> void:
	var local := club.global_transform.affine_inverse() * club.getaway_at().origin
	assert_almost_eq(local.x, GrandpaClub.ENTRANCE_X, 0.01)
	assert_gt(local.z, GrandpaClub.HALF_Z, "on the sidewalk")
