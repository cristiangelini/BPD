extends GutTest

## Doña Pepa and Cuqui (docs/diseno/edificio.md, step 5): she only talks after a cop walks her dog a whole lap of
## floor 30's hallway (10 s, one hand busy), once per cop.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")

var tower: ApartmentTower
var pepa: NosyNeighbor
var cop: Cop


func before_each() -> void:
	tower = TOWER_SCENE.instantiate()
	cop = tower.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(tower)
	await wait_physics_frames(2)
	pepa = tower.pepa
	_put(Vector3(ApartmentTower.FLAT_A_DOOR_X, ApartmentTower.TOP_Y + 0.1, -2.4))


func after_each() -> void:
	Engine.time_scale = 1.0


func _put(at: Vector3) -> void:
	cop.global_position = tower.to_global(at)
	cop.velocity = Vector3.ZERO


## Waits `seconds` of game time, sped up (GUT counts scaled time).
func _wait(seconds: float) -> void:
	Engine.time_scale = 4.0
	await wait_seconds(seconds)


func test_she_waits_at_her_door_with_cuqui() -> void:
	assert_true(ApartmentTower.on_top_floor(pepa.position), "on floor 30")
	assert_almost_eq(pepa.position.x, ApartmentTower.FLAT_A_DOOR_X, 0.01, "at 30A")
	assert_lt(pepa.dog.global_position.distance_to(pepa.global_position), 1.5, "Cuqui by her side")
	assert_eq(pepa.prompt_key(cop), "PROMPT_WALK_DOG")


func test_a_whole_lap_and_she_tells() -> void:
	pepa.tips.append("SEEN_IT")
	watch_signals(pepa)
	pepa.use(cop)
	assert_eq(cop.leash, pepa.dog, "the leash in one hand")
	assert_false(cop.get_node("Grabber").try_grab(), "the other one can't grab")
	assert_eq(pepa.prompt_key(cop), "")
	_put(Vector3(0.0, ApartmentTower.TOP_Y + 0.1, -2.4))
	await _wait(1.5)
	assert_lt(pepa.dog.global_position.distance_to(cop.global_position), 2.0, "Cuqui trots behind")
	_put(Vector3(-9.5, ApartmentTower.TOP_Y + 0.1, -2.4))
	await _wait(1.0)
	_put(Vector3(ApartmentTower.FLAT_A_DOOR_X, ApartmentTower.TOP_Y + 0.1, -2.4))
	await _wait(2.0)
	assert_signal_not_emitted(pepa, "told", "too fast: not 10 s yet")
	await _wait(NosyNeighbor.LAP_TIME)
	assert_signal_emitted_with_parameters(pepa, "told", ["SEEN_IT"])
	assert_null(cop.leash, "Cuqui back with her")
	assert_eq(pepa.prompt_key(cop), "", "once per cop")


func test_no_lap_no_gossip() -> void:
	watch_signals(pepa)
	pepa.use(cop)
	await _wait(NosyNeighbor.LAP_TIME + 1.0)
	assert_signal_not_emitted(pepa, "told", "never went down the hallway")
	assert_eq(cop.leash, pepa.dog, "still walking him")


func test_off_the_floor_cuqui_runs_home() -> void:
	watch_signals(pepa)
	pepa.use(cop)
	_put(Vector3(0.0, ApartmentTower.LOBBY_Y + 0.1, 2.0))
	await _wait(1.0)
	assert_null(cop.leash, "he slipped the leash")
	assert_null(pepa.walker())
	assert_signal_not_emitted(pepa, "told")
	assert_eq(pepa.prompt_key(cop), "PROMPT_WALK_DOG", "the walk didn't count")
	await _wait(2.0)
	assert_lt(pepa.dog.global_position.distance_to(pepa.global_position), 1.5, "Cuqui back by her side")
