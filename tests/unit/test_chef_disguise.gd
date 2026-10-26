extends GutTest

## The restaurant's disguise (infiltracion-restaurante.md, step 1, decision 174): a tall chef's hat, a curly mustache
## and a white apron in front of the station's lockers. Two of the three make a cook; none of them make a party guest
## (whose mustache is fake too) or a thief, and running shakes them off like any other disguise.

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


func test_the_mustache_brought_to_the_lip_goes_on() -> void:
	var mask: DisguisePiece = DisguisePiece.scene_of("chef_mustache").instantiate()
	level.add_child(mask)
	mask.global_position = cop.global_position + Vector3(0, 0.3, -1.2)
	await wait_physics_frames(1)
	cop.get_node("Grabber").grab(mask)
	mask.global_position = cop.global_transform * DisguisePiece.SLOTS["chef_mustache"]
	await wait_physics_frames(3)
	assert_true(cop.disguise.has("chef_mustache"))
	assert_not_null(cop.get_node_or_null("Disguise/chef_mustache"), "it shows on the cop")
	assert_false(cop.is_disguised("chef"), "one piece isn't enough")


func test_two_of_the_three_pieces_make_a_cook() -> void:
	cop.put_on_disguise("chef_hat", 0.0)
	cop.put_on_disguise("chef_apron", 0.0)
	assert_true(cop.is_disguised("chef"))
	assert_false(cop.is_disguised("party"))
	assert_false(cop.is_disguised("thief"))


func test_a_party_guest_is_not_a_cook() -> void:
	cop.put_on_disguise("party_mustache", 0.0)
	cop.put_on_disguise("party_cap", 0.0)
	cop.put_on_disguise("chef_mustache", 0.0)
	assert_false(cop.is_disguised("chef"))


func test_running_shakes_it_off() -> void:
	assert_false(DisguisePiece.TIGHT.has("chef_hat"))
	cop.put_on_disguise("chef_hat", 0.0)
	for i in int(Cop.DISGUISE_LOOSE_RUN / 0.1) + 2:
		cop.step(0.1, Vector2(0, -1), true, false, false)
	assert_false(cop.disguise.has("chef_hat"))


func test_the_station_has_a_chef_disguise_for_each_cop() -> void:
	var house: Node3D = HOUSE_SCENE.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)
	for kind: String in DisguisePiece.LOOKS.chef.pieces:
		var found := house.find_children("*", "RigidBody3D", true, false).filter(func(body: Node) -> bool:
			return body is DisguisePiece and body.kind == kind)
		assert_eq(found.size(), 4, kind)
