extends GutTest

## The battering ram: charge, hit, stagger and the slower walk (docs/diseno/allanamiento.md).

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const PICKUP_SCENE := preload("res://scenes/tools/ram_pickup.tscn")
const TICK := 1.0 / 60.0


func _cop(at: Vector3) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.position = at
	add_child_autofree(cop)
	return cop


func _charged_swing(cop: Cop, seconds: float) -> Object:
	cop.ram.start_charge()
	for i in int(seconds / TICK):
		await wait_physics_frames(1)
	return cop.ram.swing()


func test_pickup_puts_the_ram_in_hand() -> void:
	var cop := _cop(Vector3.ZERO)
	var pickup: RamPickup = PICKUP_SCENE.instantiate()
	add_child(pickup)
	pickup.use(cop)
	assert_not_null(cop.ram)
	assert_true(pickup.is_queued_for_deletion())
	assert_almost_eq(cop.current_speed(), GameScale.WALK_SPEED * BatteringRam.SPEED_FACTOR, 0.01, "15 kg slow the cop down")


func test_hands_are_busy_with_the_ram() -> void:
	var cop := _cop(Vector3.ZERO)
	cop.equip_ram()
	assert_false(cop.get_node("Grabber").try_grab())


func test_three_charged_hits_break_the_door() -> void:
	var door: FrontDoor = add_child_autofree(DOOR_SCENE.instantiate())
	var cop := _cop(Vector3(0.6, 0, 1.3))
	cop.equip_ram()
	await wait_physics_frames(2)
	for i in 3:
		assert_eq(await _charged_swing(cop, BatteringRam.CHARGE_TIME + 0.1), door.get_node("Panel"))
	assert_true(door.is_broken)


func test_weak_hit_does_not_count() -> void:
	var door: FrontDoor = add_child_autofree(DOOR_SCENE.instantiate())
	var cop := _cop(Vector3(0.6, 0, 1.3))
	cop.equip_ram()
	await wait_physics_frames(2)
	await _charged_swing(cop, BatteringRam.CHARGE_TIME * 0.2)
	assert_eq(door.hits, 0)


func test_missing_staggers_the_cop() -> void:
	var cop := _cop(Vector3(0, 0, 0))
	cop.equip_ram()
	await wait_physics_frames(2)
	assert_null(await _charged_swing(cop, 0.2))
	assert_true(cop.is_staggered())
	var start := cop.global_position
	for i in 20:
		cop.step(TICK, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	assert_almost_eq(Vector2(cop.global_position.x, cop.global_position.z).distance_to(Vector2(start.x, start.z)), 0.0, 0.01)
	cop.ram.start_charge()
	assert_false(cop.ram.is_charging, "no charging while staggered")
