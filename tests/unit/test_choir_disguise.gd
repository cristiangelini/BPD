extends GutTest

## The choir's disguise (infiltracion-coro.md, step 2, decision 101): a robe that goes on brought to the chest and a
## songbook to carry, in front of the station's lockers. A robe makes a chorister, not a grandparent, and the other
## way round.

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


func test_a_robe_brought_to_the_chest_goes_on() -> void:
	var robe: DisguisePiece = DisguisePiece.scene_of("robe").instantiate()
	level.add_child(robe)
	robe.global_position = cop.global_position + Vector3(0, 0.3, -1.2)
	await wait_physics_frames(1)
	cop.get_node("Grabber").grab(robe)
	robe.global_position = cop.global_transform * DisguisePiece.SLOTS["robe"]
	await wait_physics_frames(3)
	assert_true(cop.disguise.has("robe"))
	assert_not_null(cop.get_node_or_null("Disguise/robe"), "it shows on the cop")
	assert_true(cop.is_disguised("chorister"))


func test_a_robe_is_not_a_grandparent_and_a_wig_is_not_a_chorister() -> void:
	cop.put_on_disguise("robe", 0.0)
	assert_false(cop.is_disguised(), "a robe alone doesn't pass for a grandparent")
	cop.lose_disguise("robe")
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("glasses", 0.0)
	assert_true(cop.is_disguised("grandparent"))
	assert_false(cop.is_disguised("chorister"))


func test_running_shakes_the_robe_off_too() -> void:
	cop.put_on_disguise("robe", 0.0)
	for i in int(Cop.DISGUISE_LOOSE_RUN / 0.1) + 2:
		cop.step(0.1, Vector2(0, -1), true, false, false)
	assert_false(cop.is_disguised("chorister"))


func test_the_station_has_a_robe_and_a_songbook_for_each_cop() -> void:
	var house: Node3D = HOUSE_SCENE.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)
	var robes := house.find_children("*", "RigidBody3D", true, false).filter(func(body: Node) -> bool:
		return body is DisguisePiece and body.kind == "robe")
	assert_eq(robes.size(), 4)
	assert_eq(get_tree().get_nodes_in_group("songbooks").filter(func(book: Node) -> bool:
		return house.is_ancestor_of(book)).size(), 4)
