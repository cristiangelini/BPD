extends GutTest

## With a donut box in hand, E on a crime scene's suspect who takes food (the museum's guards, the hotel's guests)
## gives them a bite for their file instead of the cop eating a donut (Cop.takes_food).

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const BOX_SCENE := preload("res://scenes/props/donut_box.tscn")

var cop: Cop
var guard: MuseumGuard


func before_each() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(20, 0.2, 20)
	shape.shape = box
	floor_body.add_child(shape)
	floor_body.position.y = -0.1
	add_child_autofree(floor_body)
	guard = MuseumGuard.new()
	guard.traits = GuardTraits.draw(1)[0]
	add_child_autofree(guard)
	guard.global_position = Vector3(0, 0, -1.2)
	cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0.1, 0)
	cop.input_enabled = false
	await wait_physics_frames(3)
	var to := guard.global_position + Vector3.UP * 1.2 - cop.camera.global_position
	cop.global_rotation.y = atan2(-to.x, -to.z)
	cop.camera.get_parent().rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	await wait_physics_frames(2)


func test_only_the_suspects_who_take_food() -> void:
	assert_true(Cop.takes_food(guard))
	var guest: HotelGuest = autofree(HotelGuest.new())
	assert_true(Cop.takes_food(guest))
	assert_false(Cop.takes_food(autofree(Node.new())))
	assert_false(Cop.takes_food(null))


func test_e_with_the_box_feeds_the_guard_instead_of_the_cop() -> void:
	var donuts: DonutBox = BOX_SCENE.instantiate()
	add_child_autofree(donuts)
	cop.get_node("Grabber").grab(donuts)
	await wait_physics_frames(2)
	assert_eq(cop._usable_target(), guard, "aiming at the guard")
	assert_eq(cop.current_prompt(), "PROMPT_GUARD_FEED")
	var before := donuts.donuts
	assert_true(cop.use())
	assert_eq(donuts.donuts, before - 1, "one donut less")
	assert_eq(guard.said(), "GUARD_BITES", "the guard bit it")
	assert_false(cop.mouth_full(), "and the cop didn't eat it")
