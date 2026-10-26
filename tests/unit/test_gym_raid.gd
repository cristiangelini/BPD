extends GutTest

## The gym as a place to raid (docs/diseno/allanamiento-gimnasio.md, step 1): the infiltration's hall with six common
## members, the locked office and locker room with their key in the till, the mirror that breaks when hit fast and the
## treadmills that break when something heavy lands on them.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")


func _gym(case_seed := 5) -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.case_seed = case_seed
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func _prop(gym: GymRaid, kg: float, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", GymHall.DUMBBELL_MODEL, Vector3(0.3, 0.3, 0.3), kg)
	gym.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_hall_has_its_members_doors_and_spots() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	assert_eq(gym.members.size(), GymRaid.MEMBERS)
	for member: ClubMember in gym.members:
		assert_true(member.look.begins_with("gym_member"), "common members, not the band")
	assert_eq(gym.dumbbells.size(), GymHall.DUMBBELLS.size())
	assert_true(gym.office_door.locked)
	assert_true(gym.locker_door.locked)
	assert_true(gym.till.has_key, "the key to both doors is in the reception's till")
	assert_eq(GymRaid.SPOTS.size(), 12)
	assert_eq(GymRaid.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in GymRaid.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), GymHall.HALF_X, spot.id)
		assert_lt(absf(at.z), GymHall.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_same_seed_puts_the_members_in_the_same_places() -> void:
	var a := _gym(7)
	var b := _gym(7)
	await wait_physics_frames(1)
	for i in GymRaid.MEMBERS:
		assert_eq(a.members[i].position, b.members[i].position)
		assert_eq(a.members[i].look, b.members[i].look)


func test_something_thrown_hard_at_the_mirror_breaks_it_once() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	_prop(gym, 2.0, GymRaid.MIRROR_AT + Vector3(0, 0, 1.2), Vector3(0, 0, -8.0))
	await wait_physics_frames(30)
	assert_true(gym.mirror_is_broken)
	assert_eq(gym.fines, GymRaid.MIRROR_FINE)
	gym.break_mirror()
	assert_eq(gym.fines, GymRaid.MIRROR_FINE, "only once")


func test_a_slow_prop_doesnt_break_the_mirror() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	_prop(gym, 2.0, GymRaid.MIRROR_AT + Vector3(0, 0, 0.8), Vector3(0, 0, -1.0))
	await wait_physics_frames(30)
	assert_false(gym.mirror_is_broken)
	assert_eq(gym.fines, 0)


func test_something_heavy_dropped_on_a_treadmill_breaks_it() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var belt := GymHall.TREADMILLS[1] + Vector3(0, GymHall.FLOOR_TOP + GymHall.TREADMILL_BELT, 0)
	_prop(gym, 20.0, belt + Vector3(0, 1.6, 0), Vector3.ZERO)
	_prop(gym, 2.0, GymHall.TREADMILLS[2] + Vector3(0, 1.6, 0), Vector3.ZERO)
	await wait_physics_frames(60)
	assert_eq(gym.broken_treadmills, [1] as Array[int], "the light one doesn't")
	assert_false(gym.treadmill_works(1))
	assert_true(gym.treadmill_works(2))
	assert_eq(gym.fines, GymRaid.TREADMILL_FINE)


func test_the_till_key_opens_the_office() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var cop: Cop = gym.get_node("Cop")
	gym.till.use(cop)
	assert_true(cop.has_key)
	gym.office_door.use(cop)
	assert_false(gym.office_door.locked)
