extends GutTest

## The guilty neighbor's second pair of stories (docs/diseno/casa-equivocada.md, step 6): Pepe the parrot, who flies
## away from cops, and the box of rockets that goes off when hit.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")
const STEP := 1.0 / 60.0

var place: WrongHouse
var cop: Cop


func _open(story: String, seed_value := 77) -> void:
	place = SCENE.instantiate()
	place.case_seed = seed_value
	place.story_id = story
	cop = place.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(place)
	await wait_physics_frames(2)


## Stand-ins for more cops: only where they are counts.
func _cop_at(where: Vector3) -> Node3D:
	var other := Node3D.new()
	other.add_to_group("cops")
	place.add_child(other)
	other.global_position = where
	return other


func _flap(pepe: Parrot, seconds: float) -> void:
	for i in int(seconds / STEP):
		pepe._physics_process(STEP)


func test_pepe_is_the_main_one_on_a_perch_in_his_house() -> void:
	await _open("parrot")
	var rig := place.rig as WhParrotRig
	var pepe := rig.pepe
	assert_eq(place.main, pepe)
	assert_eq(pepe.perch, WhParrotRig.first_perch(77))
	assert_eq(pepe.perches.size(), WhParrotRig.PERCHES.size())
	for i in pepe.perches.size():
		assert_eq(WrongHouse.house_of(pepe.perch_point(i)), place.guilty, "perch %d is in his house" % i)
	assert_eq(place.extras.size(), 2)
	assert_eq(place.neighbor.loot.back(), pepe, "she takes him out last")


func test_pepe_flies_to_the_perch_farthest_from_the_cops() -> void:
	await _open("parrot")
	place.set_physics_process(false)
	place.neighbor.set_physics_process(false)
	var pepe := (place.rig as WhParrotRig).pepe
	pepe.set_physics_process(false)
	cop.global_position = pepe.global_position + Vector3(1.0, 0, 0)
	watch_signals(pepe)
	var expected := pepe.flee_perch()
	assert_ne(expected, -1)
	_flap(pepe, Parrot.FLIGHT + 0.1)
	assert_signal_emitted(pepe, "flew")
	assert_eq(pepe.perch, expected)
	assert_almost_eq(pepe.global_position, pepe.perch_point(expected), Vector3.ONE * 0.01)
	assert_eq(pepe.state, Parrot.State.PERCHED)
	_flap(pepe, Parrot.TALK_EVERY)
	assert_ne(pepe.said(), "", "he says numbers")


func test_with_a_cop_by_every_perch_he_is_cornered() -> void:
	await _open("parrot")
	place.set_physics_process(false)
	place.neighbor.set_physics_process(false)
	var pepe := (place.rig as WhParrotRig).pepe
	pepe.set_physics_process(false)
	cop.global_position = pepe.global_position + Vector3(1.0, 0, 0)
	for i in pepe.perches.size():
		if i != pepe.perch:
			_cop_at(pepe.perch_point(i) + Vector3(0.5, 0, 0))
	assert_true(pepe.cornered())
	var perch := pepe.perch
	_flap(pepe, 1.0)
	assert_eq(pepe.perch, perch, "nowhere to go")
	var grabber: Grabber = cop.get_node("Grabber")
	pepe.hold(grabber.get_instance_id(), pepe.global_position)
	assert_eq(pepe.state, Parrot.State.CAUGHT)
	assert_false(pepe.freeze, "plain evidence once caught")
	pepe.let_go(grabber.get_instance_id())


func test_after_five_flights_he_rests_and_lets_you_grab_him() -> void:
	await _open("parrot")
	place.set_physics_process(false)
	place.neighbor.set_physics_process(false)
	var pepe := (place.rig as WhParrotRig).pepe
	pepe.set_physics_process(false)
	for flight in Parrot.TIRED_AFTER:
		cop.global_position = pepe.global_position + Vector3(1.0, 0, 0)
		_flap(pepe, Parrot.FLIGHT + 0.1)
	assert_eq(pepe.flights, Parrot.TIRED_AFTER)
	cop.global_position = pepe.global_position + Vector3(1.0, 0, 0)
	var perch := pepe.perch
	_flap(pepe, Parrot.REST - 1.0)
	assert_eq(pepe.state, Parrot.State.RESTING)
	assert_eq(pepe.perch, perch, "too tired to fly")
	_flap(pepe, 1.5)
	assert_ne(pepe.state, Parrot.State.RESTING, "rested, he's off again")
	assert_lte(pepe.flights, 1)


func test_his_owner_picking_him_up_catches_him() -> void:
	await _open("parrot")
	var pepe := (place.rig as WhParrotRig).pepe
	pepe.set_physics_process(false)
	pepe.global_position += Vector3(0.5, 0, 0)
	pepe._physics_process(STEP)
	assert_eq(pepe.state, Parrot.State.CAUGHT)


func test_parrot_you_hear_him_through_the_window() -> void:
	await _open("parrot")
	var clue := (place.rig as WhParrotRig).window_clue
	assert_eq(WrongHouse.house_of(clue.global_position + Vector3(0, 0, -1)), place.guilty)
	clue.use(cop)
	assert_eq(place.clues, [tr("CLUE_WH_PARROT")])


func test_his_owner_can_reach_every_perch() -> void:
	await _open("parrot")
	await wait_physics_frames(10)
	var map := place.get_world_3d().navigation_map
	for at in WhParrotRig.PERCHES:
		var to := WrongHouse.at(place.guilty, at)
		var path := NavigationServer3D.map_get_path(map, place.neighbor.home, to, true)
		assert_false(path.is_empty(), str(at))
		if path.is_empty():
			continue
		var end := path[path.size() - 1]
		assert_lt(Vector2(end.x - to.x, end.z - to.z).length(), GuiltyNeighbor.ARM, "%s: within her arm" % at)


func test_fireworks_a_soft_bump_is_fine_a_hit_lights_the_box() -> void:
	await _open("fireworks")
	var box := place.main as RocketBox
	assert_not_null(box)
	assert_eq(WrongHouse.house_of(box.global_position), place.guilty)
	watch_signals(box)
	box.hit(RocketBox.IGNITE_SPEED - 0.5)
	assert_false(box.is_lit)
	box.hit(RocketBox.IGNITE_SPEED + 0.5)
	assert_true(box.is_lit)
	assert_eq(box.value, box.full_value, "lit, but not broken")
	box.hit(RocketBox.IGNITE_SPEED + 0.5)
	assert_signal_emit_count(box, "lit", 1, "only once")


func test_fireworks_the_show_breaks_his_ornaments_for_ten_seconds() -> void:
	await _open("fireworks")
	var rig := place.rig as WhFireworksRig
	rig.set_physics_process(false)
	var fines := place.fines
	rig.box.hit(RocketBox.IGNITE_SPEED + 0.5)
	assert_eq(rig.show_house, place.guilty)
	assert_eq(rig.rockets.size(), WhFireworksRig.ROCKETS)
	for i in int(WhFireworksRig.SHOW / STEP) + 2:
		rig._physics_process(STEP)
	var expected := int(WhFireworksRig.SHOW / WhFireworksRig.BREAK_EVERY)
	assert_eq(place.broken[place.guilty], expected)
	assert_eq(place.fines, fines + expected * Ornament.FINE)
	assert_eq(place.broken[place.chola_house()], 0)
	assert_eq(rig.rockets.size(), 0, "the show is over")


func test_fireworks_lit_in_dona_cholas_house_cost_double() -> void:
	await _open("fireworks")
	var rig := place.rig as WhFireworksRig
	rig.set_physics_process(false)
	rig.box.global_position = WrongHouse.at(place.chola_house(), Vector3(0, 0.5, 3.0))
	var fines := place.fines
	rig.box.hit(RocketBox.IGNITE_SPEED + 0.5)
	assert_eq(rig.show_house, place.chola_house())
	for i in int(0.9 / STEP):
		rig._physics_process(STEP)
	assert_eq(place.broken[place.chola_house()], 2, "one at once and one half a second later")
	assert_eq(place.fines, fines + 2 * Ornament.FINE * WrongHouse.CHOLA_FINES)


func test_fireworks_the_burnt_curtain_is_a_clue() -> void:
	await _open("fireworks")
	var burns := (place.rig as WhFireworksRig).burns
	assert_eq(WrongHouse.house_of(burns.global_position + Vector3(0, 0, -1)), place.guilty)
	burns.use(cop)
	assert_eq(place.clues, [tr("CLUE_WH_BURNS")])
