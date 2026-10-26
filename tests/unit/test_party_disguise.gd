extends GutTest

## The costume party's disguise (infiltracion-fiesta.md, step 1, decision 171): a party-store cop cap, a fake mustache
## and a plastic badge in front of the station's lockers. Two of the three make a party cop, and none of them make a
## grandparent or a mime.

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


func test_the_fake_mustache_brought_to_the_face_goes_on() -> void:
	var mustache: DisguisePiece = DisguisePiece.scene_of("party_mustache").instantiate()
	level.add_child(mustache)
	mustache.global_position = cop.global_position + Vector3(0, 0.3, -1.2)
	await wait_physics_frames(1)
	cop.get_node("Grabber").grab(mustache)
	mustache.global_position = cop.global_transform * DisguisePiece.SLOTS["party_mustache"]
	await wait_physics_frames(3)
	assert_true(cop.disguise.has("party_mustache"))
	assert_not_null(cop.get_node_or_null("Disguise/party_mustache"), "it shows on the cop")
	assert_false(cop.is_disguised("party"), "one piece isn't enough")


func test_two_of_the_three_pieces_make_a_party_cop() -> void:
	cop.put_on_disguise("party_cap", 0.0)
	cop.put_on_disguise("party_badge", 0.0)
	assert_true(cop.is_disguised("party"))
	assert_false(cop.is_disguised("grandparent"))
	assert_false(cop.is_disguised("mime"))


func test_a_mime_is_not_a_party_cop() -> void:
	cop.put_on_disguise("mime_beret", 0.0)
	cop.put_on_disguise("mime_face", 0.0)
	cop.put_on_disguise("party_badge", 0.0)
	assert_false(cop.is_disguised("party"))


func test_running_shakes_the_party_pieces_off() -> void:
	cop.put_on_disguise("party_cap", 0.0)
	cop.put_on_disguise("party_mustache", 0.0)
	for i in int(Cop.DISGUISE_LOOSE_RUN / 0.1) + 2:
		cop.step(0.1, Vector2(0, -1), true, false, false)
	assert_false(cop.is_disguised("party"))


func test_the_station_has_a_party_disguise_for_each_cop() -> void:
	var house: Node3D = HOUSE_SCENE.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)
	for kind: String in DisguisePiece.LOOKS.party.pieces:
		var found := house.find_children("*", "RigidBody3D", true, false).filter(func(body: Node) -> bool:
			return body is DisguisePiece and body.kind == kind)
		assert_eq(found.size(), 4, kind)
