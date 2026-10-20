extends GutTest

## The armory's wheelbarrow (docs/diseno/comisaria.md, "La armería").

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const WB_SCENE := preload("res://scenes/tools/wheelbarrow.tscn")
const SAFE_SCENE := preload("res://scenes/props/heavy_safe.tscn")
const CRATE_SCENE := preload("res://scenes/props/crate.tscn")
const GRANDPA_SCENE := preload("res://scenes/npc/grandpa.tscn")
const TICK := 1.0 / 60.0


func _floor() -> void:
	var ground := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40, 1, 40)
	shape.shape = box
	shape.position.y = -0.5
	ground.add_child(shape)
	add_child_autofree(ground)


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	cop.position.y = 0.1
	add_child_autofree(cop)
	return cop


func _wheelbarrow(cop: Cop) -> Wheelbarrow:
	var wb: Wheelbarrow = WB_SCENE.instantiate()
	add_child_autofree(wb)
	wb.push(cop)
	return wb


func test_one_cop_carries_the_safe_in_it() -> void:
	_floor()
	var cop := _cop()
	var wb := _wheelbarrow(cop)
	var safe: Grabbable = SAFE_SCENE.instantiate()
	add_child_autofree(safe)
	assert_gt(safe.mass, GameScale.COP_CARRY_KG, "too heavy for one cop's hands")
	assert_true(wb.add(safe))
	await wait_physics_frames(2)
	for i in 60:
		cop.step(TICK, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	assert_lt(cop.global_position.z, -1.0, "the cop walks pushing it")
	assert_almost_eq(Vector2(safe.global_position.x, safe.global_position.z).distance_to(
		Vector2(wb.global_position.x, wb.global_position.z)), 0.0, 0.05, "the safe rides in the tray")
	assert_almost_eq(cop.current_speed(), GameScale.WALK_SPEED * Wheelbarrow.SPEED_FACTOR, 0.01, "slower")


func test_up_to_forty_kilos() -> void:
	var cop := _cop()
	var wb := _wheelbarrow(cop)
	var safe: Grabbable = SAFE_SCENE.instantiate()
	add_child_autofree(safe)
	wb.add(safe)
	var crate: Grabbable = CRATE_SCENE.instantiate()
	add_child_autofree(crate)
	assert_eq(wb.can_load(crate), safe.mass + crate.mass <= Wheelbarrow.CAPACITY_KG)
	var extra: Grabbable = SAFE_SCENE.instantiate()
	add_child_autofree(extra)
	assert_false(wb.add(extra), "two safes are too much")


func test_tipping_it_dumps_the_load_and_parks_it() -> void:
	var cop := _cop()
	var wb := _wheelbarrow(cop)
	var crate: Grabbable = CRATE_SCENE.instantiate()
	add_child_autofree(crate)
	wb.add(crate)
	wb.dump()
	assert_eq(wb.cargo.size(), 0)
	assert_false(crate.freeze)
	assert_ne(crate.collision_layer, 0, "it can be grabbed again")
	assert_null(cop.wheelbarrow, "the cop let go")
	assert_eq(wb.get_parent(), self)


func test_the_grandpa_hears_it_squeak() -> void:
	var grandpa: Grandpa = GRANDPA_SCENE.instantiate()
	add_child_autofree(grandpa)
	assert_true(grandpa.heard_squeak(Vector3(0, 0, -5)))
	assert_eq(grandpa.complaint, Grandpa.SQUEAK)
	assert_false(grandpa.heard_squeak(Vector3(0, 0, -30)), "too far to hear")


func test_the_armory_has_only_one() -> void:
	var wallet := StationWallet.new()
	wallet.money = 200
	var armory := Armory.new(wallet)
	var cop := _cop()
	assert_eq(armory.choose("wheelbarrow", cop), "")
	assert_eq(armory.choose("wheelbarrow", cop), "")
	assert_eq(cop.wheelbarrow, armory.wheelbarrow, "the cop leaves pushing it")
	cop.wheelbarrow.park()
	assert_eq(armory.take("wheelbarrow", _cop()), "ARMORY_WHEELBARROW_OUT")
	armory.wheelbarrow.queue_free()
