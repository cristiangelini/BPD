extends GutTest

## Don Evaristo, the Las Palomas building's manager (docs/diseno/edificio.md, step 4): his round in the lobby, his
## complaint meter, and the intercom that sends him up to the 12th for 20 s, once a minute.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")

var tower: ApartmentTower
var manager: Concierge
var cop: Cop


func before_each() -> void:
	tower = TOWER_SCENE.instantiate()
	cop = tower.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(tower)
	await wait_physics_frames(2)
	manager = tower.manager


func after_each() -> void:
	Engine.time_scale = 1.0


func test_he_sweeps_the_lobby() -> void:
	var start := manager.global_position
	await wait_seconds(2.0)
	var at := tower.to_local(manager.global_position)
	assert_gt(at.distance_to(tower.to_local(start)), 1.0, "on his round")
	assert_lt(at.y, 1.0, "in the lobby")
	assert_true(manager.visible)
	assert_eq(manager.errand(), "")


func test_the_intercom_sends_him_to_the_12th() -> void:
	assert_eq(manager.fix_time, Concierge.AWAY_TIME, "20 s up there")
	manager.fix_time = 2.0
	watch_signals(tower.intercom)
	tower.intercom.button.use(cop)
	assert_signal_emitted(tower.intercom, "jammed")
	assert_eq(manager.errand(), "printer", "off to the elevator")
	Engine.time_scale = 4.0
	var waited := 0
	while not manager.is_away() and waited < 600:
		await wait_physics_frames(1)
		waited += 1
	assert_true(manager.is_away(), "he took the elevator to the leak")
	assert_almost_eq(tower.to_local(manager.global_position).z, ApartmentTower.MANAGER_ELEVATOR.z, 0.5, "at the elevator")
	await wait_physics_frames(2)
	assert_false(manager.visible, "out of sight")
	assert_false(manager.can_see(manager.global_position + Vector3(0, 1.4, 1.0)), "seeing nothing")
	assert_false(manager.heard(Concierge.HEARD_FALL, "EVARISTO_FALL"), "hearing nothing")
	assert_eq(manager.complaint, 0.0)
	waited = 0
	while manager.is_away() and waited < 600:
		await wait_physics_frames(1)
		waited += 1
	assert_false(manager.is_away(), "back from the 12th after his time")
	await wait_physics_frames(1)
	assert_true(manager.visible)
	assert_false(tower.intercom.is_jammed)


func test_once_a_minute() -> void:
	manager.fix_time = 0.1
	tower.intercom.print_copies(cop)
	assert_eq(tower.intercom.jobs, 1)
	tower.intercom.fix()
	tower.intercom.print_copies(cop)
	assert_eq(tower.intercom.jobs, 1, "the neighbors don't answer again so soon")
	tower.intercom.cooldown_left = 0.0
	tower.intercom.print_copies(cop)
	assert_eq(tower.intercom.jobs, 2, "a minute later they do")


func test_what_fills_his_complaint() -> void:
	tower.front_door.broken.emit()
	assert_eq(manager.complaint, FloorBoss.DOOR_BROKEN, "a rammed door reaches him anywhere")
	tower.something_fell.emit(cop)
	assert_eq(manager.complaint, FloorBoss.DOOR_BROKEN + Concierge.HEARD_FALL, "he hears the crash")
	manager.global_position = tower.to_global(Vector3(0, ApartmentTower.LOBBY_Y, 0))
	manager.route = [manager.global_position, manager.global_position]
	await wait_seconds(TowerElevator.DOOR_TIME + 0.2)
	tower.elevator.overloaded.emit(500.0)
	assert_eq(manager.complaint, FloorBoss.DOOR_BROKEN + Concierge.HEARD_FALL + Concierge.SAW_OVERLOAD, "the open elevator, in sight")
	tower.ornaments[0].broken.emit(tower.ornaments[0].global_position)
	assert_eq(manager.complaint, FloorBoss.DOOR_BROKEN + Concierge.HEARD_FALL + Concierge.SAW_OVERLOAD, "floor 30 is out of sight")


func test_at_100_he_calls_the_lawyer() -> void:
	for i in 10:
		tower.something_fell.emit(cop)
	assert_true(manager.has_called_lawyer)
	assert_true(tower.get_node("%CaseFailed").visible)
	assert_eq(tower.complaint_bar.value, FloorBoss.MAX_COMPLAINT)
