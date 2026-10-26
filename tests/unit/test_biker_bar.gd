extends GutTest

## The biker bar "El Caño Libre" (infiltracion-motos.md, step 2, decision 176): on its own city lot, bikers only past
## the bouncer; the bar with its counter, the workshop where El Cromado polishes his moped, the patio of the dares and
## his locked office; the gang's bikers around the bar, drawn with the seed.

const LEVEL := preload("res://scenes/levels/biker_bar.tscn")

var bar: BikerBar


func before_each() -> void:
	bar = LEVEL.instantiate()
	bar.get_node("Cop").input_enabled = false
	add_child_autofree(bar)
	await wait_physics_frames(2)


func _at(x: float, z: float) -> Vector3:
	return bar.global_transform * Vector3(x, 1.0, z)


func test_it_is_on_its_own_lot_and_play_can_open_it() -> void:
	var lot: Dictionary = CityLayout.place("biker")
	assert_false(lot.is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=biker"])), "biker")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["biker"]))
	assert_almost_eq(lot.size.x, BikerBar.HALF_X * 2, 0.01, "as wide as its lot")
	assert_almost_eq(lot.size.z, BikerBar.HALF_Z * 2, 0.01, "and as deep")


func test_it_is_the_biker_infiltration_place() -> void:
	assert_true(bar is InfiltrationPlace)
	assert_eq(bar.variant, "biker")


func test_the_rooms_are_where_they_say() -> void:
	assert_true(bar.in_bar(_at(-4.0, 5.0)))
	assert_true(bar.in_workshop(_at(8.0, 5.0)))
	assert_true(bar.in_patio(_at(-4.0, -5.0)))
	assert_true(bar.in_back_room(_at(8.0, -5.0)), "the office behind the workshop")
	assert_false(bar.in_bar(_at(8.0, -5.0)))


func test_the_office_is_locked() -> void:
	assert_true(bar.office_door.locked)


func test_the_bikers_are_drawn_with_the_seed() -> void:
	assert_eq(bar.members.size(), BikerBar.PLAYERS)
	for member: ClubMember in bar.members:
		assert_true(member.look in ["motoquero", "motoquera"])
		assert_true(bar.is_inside(member.global_position + Vector3.UP))
	var other: BikerBar = LEVEL.instantiate()
	other.case_seed = bar.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in bar.members.size():
		assert_eq(other.members[i].position, bar.members[i].position)
		assert_eq(other.members[i].look, bar.members[i].look)


func test_el_cromado_is_the_boss_polishing_his_moped() -> void:
	assert_eq(bar.boss, bar.cromado)
	assert_true(bar.cromado.is_boss())
	assert_true(bar.in_workshop(bar.cromado.global_position + Vector3.UP))
	var to_moped := bar.global_transform * BikerBar.MOPED_AT - bar.cromado.global_position
	to_moped.y = 0.0
	assert_gt((-bar.cromado.global_basis.z).dot(to_moped.normalized()), 0.99, "looking at his moped")


func test_bikers_gossip_and_el_cromado_has_his_own_lines() -> void:
	var cop: Cop = bar.get_node("Cop")
	bar.members[0].use(cop)
	assert_true(bar.members[0].said().begins_with("BIKER_GOSSIP_"))
	bar.cromado.use(cop)
	assert_true(bar.cromado.said().begins_with("CROMADO_"))


func test_the_whole_bar_watches_for_bikers() -> void:
	assert_eq(bar.suspicion.disguise_look, "biker")
	assert_eq(bar.suspicion.prefix, "BIKER_")
	assert_eq(bar.suspicion.boss_found_out, "CROMADO_FOUND_OUT")
	assert_true(bar.suspicion.inside.call(_at(-4.0, 5.0)), "the bar counts")
	assert_true(bar.suspicion.inside.call(_at(-4.0, -5.0)), "and the patio")
	assert_false(bar.suspicion.inside.call(_at(0.0, 14.0)), "the street doesn't")


## A cop walking in from the street.
func _walk_in(cop: Cop) -> void:
	cop.global_position = bar.global_transform * Vector3(BikerBar.ENTRANCE_X, 0.1, BikerBar.HALF_Z + 1.0)
	cop.global_rotation.y = bar.global_rotation.y
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		bar.doorman._physics_process(1.0 / 60.0)


func test_the_bouncer_wants_a_biker() -> void:
	var cop: Cop = bar.get_node("Cop")
	cop.put_on_disguise("mustache", 0.0)
	await _walk_in(cop)
	assert_eq(bar.doorman.said(), "BIKERDOOR_NO_1", "a grandpa's mustache isn't a biker")
	assert_gt((bar.global_transform.affine_inverse() * cop.global_position).z, BikerBar.HALF_Z - 0.3, "didn't get in")


func test_the_bouncer_lets_a_biker_in() -> void:
	var cop: Cop = bar.get_node("Cop")
	cop.put_on_disguise("biker_beard", 0.0)
	cop.put_on_disguise("biker_jacket", 0.0)
	await _walk_in(cop)
	assert_eq(bar.doorman.said(), "BIKERDOOR_WELCOME")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = bar.get_node("Cop")
	var station := bar.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_biker_bar_s_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PLACE_BIKER", "PROMPT_TALK_BIKER", "BIKER_CUFFED", "PROMPT_TALK_CROMADO",
		"CROMADO_CUFFED", "CROMADO_FOUND_OUT", "BIKERDOOR_WELCOME", "BIKERDOOR_NO_0", "BIKERDOOR_NO_1",
		"HINT_BIKERDOOR_NO_DISGUISE", "HUD_BIKER_SUSPICION", "HINT_BIKER_FOUND_OUT"]
	for i in 10:
		keys.append("BIKER_GOSSIP_%d" % i)
	for i in 4:
		keys.append("CROMADO_%d" % i)
	for i in 3:
		keys.append("BIKER_FOUND_OUT_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
