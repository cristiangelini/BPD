extends GutTest

## The cop's 4 tool slots: handcuffs, flashlight, camera and fingerprint kit (docs/diseno/herramientas.md).

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const CRATE_SCENE := preload("res://scenes/props/crate.tscn")
const BOOK_SCENE := preload("res://scenes/props/betting_book.tscn")
const GRANDPA_SCENE := preload("res://scenes/npc/grandpa.tscn")


## A place whose trails a photo can catch, like the grandpa's house.
class FakePlace:
	extends Node3D
	var trails := {}
	var clues: Array[String] = []

	func photo_clues() -> Dictionary:
		return trails

	func add_clue(line: String) -> void:
		clues.append(line)


func _cop(at := Vector3.ZERO, uniform := 0) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.position = at
	add_child_autofree(cop)
	cop.set_uniform(uniform)
	return cop


## A crate floating at eye height in front of a cop at the origin, so the camera points at it.
func _crate_in_front() -> Grabbable:
	var crate: Grabbable = CRATE_SCENE.instantiate()
	crate.gravity_scale = 0.0
	crate.position = Vector3(0, GameScale.EYE_HEIGHT, -1.2)
	add_child_autofree(crate)
	return crate


func test_four_slots_in_order() -> void:
	var cop := _cop()
	var keys := cop.belt.tools.map(func(tool: CopTool) -> String: return tool.name_key)
	assert_eq(keys, ["TOOL_HANDCUFFS", "TOOL_FLASHLIGHT", "TOOL_CAMERA", "TOOL_PRINT_KIT"])
	assert_eq(cop.belt.current, -1, "hands start free")


func test_same_number_puts_the_tool_away() -> void:
	var cop := _cop()
	assert_true(cop.belt.select(2))
	assert_true(cop.belt.held_tool() is PhotoCamera)
	assert_true(cop.belt.tools[2].model.visible)
	assert_eq(cop.current_prompt(), "PROMPT_CAMERA")
	cop.belt.select(0)
	assert_true(cop.belt.held_tool() is Handcuffs, "another number swaps tools")
	assert_false(cop.belt.tools[2].model.visible)
	cop.belt.select(0)
	assert_null(cop.belt.held_tool())


func test_a_tool_in_hand_means_no_grabbing() -> void:
	var cop := _cop()
	_crate_in_front()
	await wait_physics_frames(2)
	cop.belt.select(1)
	assert_false(cop.get_node("Grabber").try_grab())
	cop.belt.holster()
	assert_true(cop.get_node("Grabber").try_grab())


func test_no_tools_while_carrying_the_ram() -> void:
	var cop := _cop()
	cop.equip_ram()
	assert_false(cop.belt.select(1))
	assert_null(cop.belt.held_tool())


func test_flashlight_lights_what_it_points_at() -> void:
	var cop := _cop()
	await wait_physics_frames(1)
	var light := cop.belt.flashlight
	var ahead := Vector3(0, 0.2, -5)
	assert_false(light.lights(ahead), "off")
	light.toggle()
	assert_true(light.light.visible)
	assert_true(light.lights(ahead))
	assert_false(light.lights(Vector3(0, 0.2, -12)), "too far to make out a trail")
	assert_false(light.lights(Vector3(0, 1, 5)), "behind")


func test_photos_use_film_and_wait_between_shots() -> void:
	var cop := _cop()
	var camera: PhotoCamera = cop.belt.tools[2]
	await wait_physics_frames(1)
	camera.shoot()
	camera.shoot()
	assert_eq(camera.film, PhotoCamera.FILM - 1, "the second click comes too soon")
	assert_eq(cop.stats.photos, 1)
	await wait_seconds(PhotoCamera.COOLDOWN + 0.1)
	camera.shoot()
	assert_eq(camera.film, PhotoCamera.FILM - 2)


func test_a_photo_notes_the_trail_in_frame() -> void:
	var cop := _cop()
	var place := FakePlace.new()
	add_child_autofree(place)
	place.add_to_group("photo_clues")
	var seen := Node3D.new()
	var missed := Node3D.new()
	place.add_child(seen)
	place.add_child(missed)
	seen.position = Vector3(0.5, 0, -8)
	missed.position = Vector3(8, 0, 0)
	place.trails = {"mud": [seen], "crumbs": [missed]}
	await wait_physics_frames(1)
	assert_eq((cop.belt.tools[2] as PhotoCamera).shoot(), ["mud"] as Array[String])
	assert_eq(place.clues, ["mud"] as Array[String])


func test_the_flash_in_the_grandpas_face_upsets_him() -> void:
	var cop := _cop()
	var grandpa: Grandpa = GRANDPA_SCENE.instantiate()
	grandpa.position = Vector3(0, 0, -3)
	add_child_autofree(grandpa)
	cop.look(Vector2(0, 0.25))
	await wait_physics_frames(2)
	(cop.belt.tools[2] as PhotoCamera).shoot()
	assert_almost_eq(grandpa.complaint, Grandpa.PHOTOGRAPHED, 0.01)


func test_a_cuffed_partner_cant_grab_until_freed() -> void:
	var cop := _cop()
	var partner := _cop(Vector3(0, 0, -1.3), 1)
	await wait_physics_frames(2)
	cop.belt.select(0)
	assert_eq((cop.belt.tools[0] as Handcuffs).cuff(), partner)
	assert_true(partner.is_cuffed())
	assert_false(partner.belt.select(2), "no tools with the hands tied")
	assert_eq(cop.current_prompt(), "PROMPT_HANDCUFFS")
	cop.belt.holster()
	assert_eq(cop.current_prompt(), "PROMPT_UNCUFF")
	assert_true(cop.use())
	assert_false(partner.is_cuffed())


func test_cuffs_wear_off() -> void:
	var cop := _cop()
	cop.cuffed(0.2)
	assert_true(cop.is_cuffed())
	for i in 20:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
	assert_false(cop.is_cuffed())


func test_the_grandpa_cuffed_stays_put_and_complains() -> void:
	var cop := _cop()
	var grandpa: Grandpa = GRANDPA_SCENE.instantiate()
	grandpa.position = Vector3(0, 0, -1.4)
	add_child_autofree(grandpa)
	cop.look(Vector2(0, 0.4))
	await wait_physics_frames(2)
	assert_eq((cop.belt.tools[0] as Handcuffs).cuff(), grandpa)
	assert_true(grandpa.is_cuffed())
	assert_almost_eq(grandpa.complaint, Grandpa.CUFFED, 0.01)


func test_prints_of_the_cops_who_grabbed_it() -> void:
	var cop := _cop(Vector3.ZERO, 2)
	var crate := _crate_in_front()
	await wait_physics_frames(2)
	assert_eq(PrintKit.prints_at(crate, crate.global_position), {"owner": false, "cops": []})
	cop.get_node("Grabber").try_grab()
	cop.get_node("Grabber").release()
	assert_eq(PrintKit.prints_at(crate, crate.global_position).cops, [2])


func test_fresh_prints_of_the_owner_near_hidden_evidence() -> void:
	var cop := _cop()
	var crate := _crate_in_front()
	var book: Evidence = BOOK_SCENE.instantiate()
	book.position = Vector3(5, 0, 0)
	add_child_autofree(book)
	await wait_physics_frames(1)
	assert_false(PrintKit.prints_at(crate, crate.global_position).owner)
	book.global_position = crate.global_position + Vector3(0, -0.6, 0)
	assert_true((cop.belt.tools[3] as PrintKit).reveal(crate, crate.global_position).owner)


func test_dusting_takes_a_moment_of_holding_on() -> void:
	var cop := _cop()
	_crate_in_front()
	await wait_physics_frames(2)
	var kit: PrintKit = cop.belt.tools[3]
	kit.press()
	await wait_seconds(PrintKit.DUST_TIME * 0.5)
	assert_eq(kit.prompt_key(), "PROMPT_PRINT_KIT_DUSTING")
	await wait_seconds(PrintKit.DUST_TIME * 0.6)
	assert_eq(kit.prompt_key(), "PROMPT_PRINT_KIT", "done dusting")


func test_photographer_of_the_shift_award() -> void:
	var awards := ShiftReport.awards([{"photos": 3}, {"photos": 7}])
	assert_eq(awards, [{"key": "AWARD_PHOTOS", "cop": 1, "value": 7}] as Array[Dictionary])


## Something cuffable floating at eye height right in front of a cop at the origin.
func _float_in_front(body: RigidBody3D, distance := 1.0) -> void:
	body.gravity_scale = 0.0
	body.position = Vector3(0, GameScale.EYE_HEIGHT, -distance)
	add_child_autofree(body)


func test_anyone_can_be_cuffed_and_wears_the_cuffs() -> void:
	var cop := _cop()
	var cat: Cat = preload("res://scenes/npc/cat.tscn").instantiate()
	_float_in_front(cat)
	await wait_physics_frames(2)
	var cuffs: Handcuffs = cop.belt.tools[0]
	assert_eq(cuffs.cuff(), cat)
	assert_true(cat.is_cuffed())
	assert_eq(cuffs._worn.size(), 1, "the cuffs show on Michi")
	cat._cuffed_left = 0.0
	await wait_physics_frames(1)
	assert_eq(cuffs._worn.size(), 0, "and come off once free")


func test_a_turtle_is_cuffed_through_its_walker() -> void:
	var cop := _cop()
	var turtle: Grabbable = preload("res://scenes/props/turtle_plain.tscn").instantiate()
	_float_in_front(turtle)
	await wait_physics_frames(2)
	assert_eq((cop.belt.tools[0] as Handcuffs).cuff(), turtle.get_node("Walk"))
	assert_true((turtle.get_node("Walk") as TurtleWalk).is_cuffed())


func test_the_neighbor_cuffed_at_her_window_says_nothing() -> void:
	var cop := _cop()
	var neighbor := Neighbor.new()
	neighbor.position = Vector3(0, 0, -0.9)
	add_child_autofree(neighbor)
	await wait_physics_frames(2)
	assert_eq((cop.belt.tools[0] as Handcuffs).cuff(), neighbor)
	neighbor.use(cop)
	assert_false(neighbor.was_asked, "cuffed, she doesn't even ask for her tupperware")


func test_a_cuffed_customer_stays_then_runs_off() -> void:
	var customer: BakeryCustomer = preload("res://scenes/npc/bakery_customer.tscn").instantiate()
	customer.route = [Vector3(0, 0, -5), Vector3(0, 0, -1)] as Array[Vector3]
	add_child_autofree(customer)
	customer.cuffed(0.2)
	await wait_seconds(0.1)
	assert_eq(customer.state, BakeryCustomer.State.ENTERING)
	assert_almost_eq(Vector2(customer.velocity.x, customer.velocity.z).length(), 0.0, 0.01, "stays put")
	await wait_seconds(0.2)
	assert_eq(customer.state, BakeryCustomer.State.FLEEING)
