extends GutTest

## The gym's disguise (infiltracion-gimnasio.md, step 1, decision 172): a headband, a pair of wristbands and a tank top
## in front of the station's lockers. Two of the three make a gym member, none of them make a grandparent or a party
## cop, and running doesn't shake them off: they're made to sweat in.

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")

var level: Node3D
var cop: Cop


func before_each() -> void:
	level = Node3D.new()
	add_child_autofree(level)
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40, 0.2, 40)
	shape.shape = box
	floor_body.add_child(shape)
	floor_body.position.y = -0.1
	level.add_child(floor_body)
	cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	level.add_child(cop)
	await wait_physics_frames(2)


func test_the_headband_brought_to_the_head_goes_on() -> void:
	var headband: DisguisePiece = DisguisePiece.scene_of("gym_headband").instantiate()
	level.add_child(headband)
	headband.global_position = cop.global_position + Vector3(0, 0.3, -1.2)
	await wait_physics_frames(1)
	cop.get_node("Grabber").grab(headband)
	headband.global_position = cop.global_transform * DisguisePiece.SLOTS["gym_headband"]
	await wait_physics_frames(3)
	assert_true(cop.disguise.has("gym_headband"))
	assert_not_null(cop.get_node_or_null("Disguise/gym_headband"), "it shows on the cop")
	assert_false(cop.is_disguised("gym"), "one piece isn't enough")


func test_two_of_the_three_pieces_make_a_gym_member() -> void:
	cop.put_on_disguise("gym_wristbands", 0.0)
	cop.put_on_disguise("gym_tank", 0.0)
	assert_true(cop.is_disguised("gym"))
	assert_false(cop.is_disguised("grandparent"))
	assert_false(cop.is_disguised("party"))


func test_a_party_cop_is_not_a_gym_member() -> void:
	cop.put_on_disguise("party_cap", 0.0)
	cop.put_on_disguise("party_badge", 0.0)
	cop.put_on_disguise("gym_tank", 0.0)
	assert_false(cop.is_disguised("gym"))


func test_running_doesn_t_shake_sportswear_off() -> void:
	cop.put_on_disguise("gym_headband", DisguisePiece.MAX_TILT)
	cop.put_on_disguise("gym_tank", 0.0)
	for i in int(Cop.DISGUISE_LOOSE_RUN / 0.1) * 3:
		cop.step(0.1, Vector2(0, -1), true, false, false)
	assert_true(cop.is_disguised("gym"))


func test_running_still_shakes_the_rest_off() -> void:
	cop.put_on_disguise("gym_tank", 0.0)
	cop.put_on_disguise("party_cap", 0.0)
	for i in int(Cop.DISGUISE_LOOSE_RUN / 0.1) + 2:
		cop.step(0.1, Vector2(0, -1), true, false, false)
	assert_false(cop.disguise.has("party_cap"))
	assert_true(cop.disguise.has("gym_tank"))


func test_the_station_has_a_gym_disguise_for_each_cop() -> void:
	var house: Node3D = HOUSE_SCENE.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)
	for kind: String in DisguisePiece.LOOKS.gym.pieces:
		var found := house.find_children("*", "RigidBody3D", true, false).filter(func(body: Node) -> bool:
			return body is DisguisePiece and body.kind == kind)
		assert_eq(found.size(), 4, kind)
