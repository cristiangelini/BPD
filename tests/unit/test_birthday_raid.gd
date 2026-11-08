extends GutTest

## The birthday party as a place to raid (docs/diseno/allanamiento-cumple.md, step 1): the Salón Gala decked out for
## Tomasito's birthday, the kids on spots drawn with the seed, the locked office with its key in Chispita's case, the
## bouncy castle that bounces a cop up, the cake that's a fine if it falls and the balloons that pop.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")


func _party(case_seed := 5) -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.case_seed = case_seed
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


func test_the_hall_has_its_kids_door_and_spots() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_eq(party.kids.size(), BirthdayRaid.KIDS)
	assert_eq(party.tomasito.look, "tomasito")
	for kid: ClubMember in party.kids.slice(1):
		assert_true(kid.look.begins_with("party_kid"), "guests, not grown-ups")
	assert_true(party.office_door.locked)
	assert_true(party.chispita_case.has_key, "the office key is in Chispita's case")
	assert_eq(BirthdayRaid.SPOTS.size(), 12)
	assert_eq(BirthdayRaid.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in BirthdayRaid.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), PartyHall.HALF_X, spot.id)
		assert_lt(absf(at.z), PartyHall.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_same_seed_puts_the_kids_in_the_same_places() -> void:
	var a := _party(7)
	var b := _party(7)
	await wait_physics_frames(1)
	for i in BirthdayRaid.KIDS:
		assert_eq(a.kids[i].position, b.kids[i].position)
		assert_eq(a.kids[i].look, b.kids[i].look)


func test_chispitas_key_opens_the_office() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var cop: Cop = party.get_node("Cop")
	party.chispita_case.use(cop)
	assert_true(cop.has_key)
	party.office_door.use(cop)
	assert_false(party.office_door.locked)


func test_the_bouncy_castle_bounces_a_cop_up() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var cop: Cop = party.get_node("Cop")
	cop.global_position = party.to_global(BirthdayRaid.CASTLE_AT + Vector3(0, BirthdayRaid.CASTLE_FLOOR + 0.05, 0))
	cop.velocity = Vector3.ZERO
	await wait_physics_frames(3)
	assert_eq(cop.velocity.y, BirthdayRaid.BOUNCE, "up it goes")


func test_the_cake_falling_off_the_table_is_a_fine_once() -> void:
	var party := _party()
	await wait_physics_frames(10)
	assert_false(party.cake_broken, "it sits on the table")
	party.cake.position = BirthdayRaid.CAKE_AT + Vector3(-1.2, 0, 0)
	party.cake.sleeping = false
	await wait_physics_frames(60)
	assert_true(party.cake_broken, "off the table and onto the floor")
	assert_eq(party.fines, BirthdayRaid.CAKE_FINE)
	party.break_cake()
	assert_eq(party.fines, BirthdayRaid.CAKE_FINE, "only once")


func test_a_cop_touching_a_balloon_pops_it_but_walking_in_doesnt() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var cop: Cop = party.get_node("Cop")
	cop.global_position = party.to_global(Vector3(0, BirthdayRaid.FLOOR_TOP + 0.05, BirthdayRaid.ARCH_Z))
	await wait_physics_frames(5)
	assert_eq(party.popped.size(), 0, "the door's way is clear")
	var balloon := party.balloons[1]
	cop.global_position = party.to_global(balloon.position - Vector3(0, 0.8, 0))
	await wait_physics_frames(5)
	assert_has(party.popped, 1)
	assert_false(balloon.get_child(1).visible, "gone")
