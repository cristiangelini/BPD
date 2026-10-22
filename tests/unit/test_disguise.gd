extends GutTest

## The infiltration's disguise (infiltracion.md, step 1, decision 100): pieces from the station's lockers that go on
## by bringing them up to the head, end up crooked if brought in off-center and fall off running.

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


func _pieces_in(root: Node) -> Array:
	return root.find_children("*", "RigidBody3D", true, false).filter(func(body: Node) -> bool: return body is DisguisePiece)


func _piece(kind: String) -> DisguisePiece:
	var piece: DisguisePiece = DisguisePiece.scene_of(kind).instantiate()
	level.add_child(piece)
	piece.global_position = cop.global_position + Vector3(0, 0.3, -1.2)
	await wait_physics_frames(1)
	return piece


## Holds `piece` and brings it to `at` (in the cop's space), as the mouse wheel and the view would.
func _bring(piece: DisguisePiece, at: Vector3) -> void:
	cop.get_node("Grabber").grab(piece)
	piece.global_position = cop.global_transform * at
	await wait_physics_frames(3)


func test_a_wig_brought_to_the_head_goes_on() -> void:
	var wig := await _piece("wig")
	await _bring(wig, DisguisePiece.SLOTS["wig"])
	assert_true(cop.disguise.has("wig"), "it's on")
	assert_false(is_instance_valid(wig), "the one on the floor is gone")
	assert_null(cop.get_node("Grabber").held, "and the hands are free")
	assert_not_null(cop.get_node_or_null("Disguise/wig"), "it shows on the cop")
	assert_lt(absf(cop.disguise["wig"]), DisguisePiece.CROOKED, "straight")


func test_far_from_its_place_it_doesnt_go_on() -> void:
	var glasses := await _piece("glasses")
	await _bring(glasses, DisguisePiece.SLOTS["glasses"] + Vector3(0, 0, -0.6))
	assert_false(cop.disguise.has("glasses"))
	assert_true(is_instance_valid(glasses))


func test_brought_in_off_center_it_ends_up_crooked() -> void:
	var mustache := await _piece("mustache")
	await _bring(mustache, DisguisePiece.SLOTS["mustache"] + Vector3(0.18, 0, 0))
	assert_true(cop.disguise.has("mustache"))
	assert_gt(absf(cop.disguise["mustache"]), DisguisePiece.CROOKED, "crooked")


func test_held_disguise_comes_right_up_to_the_face() -> void:
	var wig := await _piece("wig")
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.grab(wig)
	for i in 10:
		grabber.nudge(true)
	assert_eq(grabber.hold_distance, DisguisePiece.HOLD_CLOSE)
	grabber.release()
	assert_eq(grabber.closest(), GameScale.HOLD_MIN, "anything else stops further away")


func test_running_shakes_a_piece_off() -> void:
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("glasses", 0.0)
	assert_true(cop.is_disguised())
	for i in int(Cop.DISGUISE_LOOSE_RUN / 0.1) + 2:
		cop.step(0.1, Vector2(0, -1), true, false, false)
	assert_eq(cop.disguise.size(), 1, "one fell off")
	assert_false(cop.is_disguised())
	await wait_physics_frames(1)
	assert_eq(_pieces_in(level).size(), 1, "it's on the floor")


func test_a_crooked_piece_falls_first_and_sooner() -> void:
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("mustache", DisguisePiece.MAX_TILT)
	for i in int(Cop.DISGUISE_CROOKED_RUN / 0.1) + 2:
		cop.step(0.1, Vector2(0, -1), true, false, false)
	assert_false(cop.disguise.has("mustache"), "the crooked one fell")
	assert_true(cop.disguise.has("wig"))


func test_walking_keeps_it_on() -> void:
	cop.put_on_disguise("wig", DisguisePiece.MAX_TILT)
	for i in 100:
		cop.step(0.1, Vector2(0, -1), false, false, false)
	assert_true(cop.disguise.has("wig"))


func test_the_station_has_a_disguise_for_each_cop() -> void:
	var house: Node3D = HOUSE_SCENE.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)
	var pieces := _pieces_in(house)
	assert_eq(pieces.size(), 16, "3 pieces for the club and a robe for the choir, for each cop")
	for kind: String in DisguisePiece.SLOTS:
		assert_eq(pieces.filter(func(piece: DisguisePiece) -> bool: return piece.kind == kind).size(), 4)
