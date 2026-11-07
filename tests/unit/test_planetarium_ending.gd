extends GutTest

## The planetarium's ending (escena-planetario.md, step 7): the comisario gives the case at the station, and the culprit
## who runs off goes in the planetarium's van, slow, dropping two inflatable planets at every corner it turns
## (SuspectCar, ChaseDrops, ChasePlanet); a planet hit sends it flying and holds the patrol car back for a moment, a
## cop on foot pops it, and the guide is interrogated as one.

const LEVEL := preload("res://scenes/levels/planetarium.tscn")


func test_the_van_is_a_slow_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.planetarium.getaway, SuspectCar.PLANETARIUM_VAN)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.PLANETARIUM_VAN))
	assert_lt(SuspectCar.SPEEDS[SuspectCar.PLANETARIUM_VAN], SuspectCar.SPEED, "slow")
	assert_true(ChaseSuspect.MODELS.has("guide"), "they get out as a guide")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_guide"), "and are interrogated as one")
	for key: String in ["CRIME_owner_guide", "CONFESS_owner_guide", "HINT_ESCAPE_guide", "PROMPT_POP_PLANET",
			"HINT_PLANET_POPPED"]:
		assert_ne(tr(key), key)


func test_the_van_waits_at_the_curb_and_drives_out() -> void:
	var planetarium := Planetarium.new()
	add_child_autofree(planetarium)
	var getaway := planetarium.getaway(0, null)
	var at := planetarium.to_local((getaway.at as Transform3D).origin)
	assert_gt(at.z - SuspectCar.SIZES[SuspectCar.PLANETARIUM_VAN].z / 2, Planetarium.FRONT_Z + 1.5, "clear of the door")
	assert_gt(absf(at.x - Planetarium.DOOR_FRONT_X), 5.0, "not in front of the door")
	assert_gt(planetarium.to_local(getaway.via[0] as Vector3).z, at.z, "out into the street")


func test_a_planet_is_popped_or_hit_and_holds_the_car_back() -> void:
	var drops := DropsStub.new()
	add_child_autofree(drops)
	var popped := ChasePlanet.new()
	popped.planet = "saturn"
	add_child_autofree(popped)
	assert_true(popped.part("ring").visible, "Saturn keeps its ring")
	assert_eq(popped.prompt_key(null), "PROMPT_POP_PLANET")
	popped.use(null)
	assert_true(popped.popped)
	var car := Node3D.new()
	add_child_autofree(car)
	var planet := ChasePlanet.new()
	planet.car = car
	planet.drops = drops
	planet.gravity_scale = 0.0
	add_child_autofree(planet)
	assert_false(planet.part("ring").visible, "only Saturn has a ring")
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_true(planet.hit, "the patrol car went into it fast")
	assert_eq(drops.hits, 1, "and is held back, once")
	await wait_physics_frames(3)
	assert_gt(planet.linear_velocity.y, 0.0, "off it flies")


func test_the_culprit_runs_off_in_the_van_dropping_planets() -> void:
	var level: PlanetariumLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_not_null(level.case, "the comisario gives the case")
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.PLANETARIUM_VAN)
	assert_eq(chase.who, "guide")
	chase.chasing = true
	chase.drops._on_corner(true)
	assert_eq(chase.drops.planets.size(), ChaseDrops.PLANETS_PER_CORNER, "two planets at every corner")
	assert_eq(chase.drops.planets[0].car, chase.car)
	chase.drops.planet_hit()
	chase.car.linear_velocity = chase.car.global_basis.z * 10.0
	await wait_physics_frames(2)
	assert_lt(chase.car.linear_velocity.length(), 10.0, "held back")
	assert_gt(chase.drops.planet_hold_left, 0.0)


class DropsStub:
	extends ChaseDrops
	var hits := 0

	func _ready() -> void:
		pass

	func _physics_process(_delta: float) -> void:
		pass

	func planet_hit() -> void:
		hits += 1
