extends GutTest

## Doña Hortensia at the nursery (docs/diseno/allanamiento-vivero.md, step 4): she walks between the yard and the
## greenhouse, adds 5 to her complaint for each cop she sees slip in the mud (once per cop) and 10 each time she sees
## the Dentuda bite, and the soil truck's horn sends her to count bags by the back gate, twice; the third time she
## catches on.

const SCENE := preload("res://scenes/levels/nursery.tscn")
const LINES := ["LINE_1", "LINE_2", "LINE_3", "LINE_4", "PRINTER", "FIX_1", "FIX_2", "FIX_3", "FIX_DONE", "HURT",
	"DOOR", "SAW", "NOTHING", "OFFENDED", "LAWYER", "CAUGHT_ON", "FLOWERBEDS", "DENTUDA"]


func _nursery() -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.case_seed = 5
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func test_she_walks_her_round_and_talks() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var owner_npc := nursery.owner_npc
	assert_eq(owner_npc.voice, "HORTENSIA")
	assert_eq(owner_npc.complaint, 0.0)
	var from := owner_npc.global_position
	await wait_physics_frames(30)
	assert_gt(owner_npc.global_position.distance_to(from), 0.2, "she walks")
	for line: String in LINES:
		assert_ne(tr("HORTENSIA_" + line), "HORTENSIA_" + line, line)
	assert_ne(tr("PROMPT_NURSERY_HORN"), "PROMPT_NURSERY_HORN")


func test_she_sees_a_cop_slip_once() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var owner_npc := nursery.owner_npc
	owner_npc.set_physics_process(false)
	owner_npc.start_at(0)
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.to_global(Vector3(-9.0, Nursery.FLOOR_TOP, -2.5))
	await wait_physics_frames(2)
	nursery.irrigation.slipped.emit(cop)
	assert_eq(owner_npc.complaint, Nursery.SAW_SLIP)
	nursery.irrigation.slipped.emit(cop)
	assert_eq(owner_npc.complaint, Nursery.SAW_SLIP, "once per cop")


func test_she_sees_the_dentuda_bite() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var owner_npc := nursery.owner_npc
	owner_npc.set_physics_process(false)
	owner_npc.global_position = nursery.to_global(Vector3(4.0, Nursery.FLOOR_TOP, 0.0))
	nursery.dentuda.set_physics_process(false)
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.to_global(Vector3(6.5, Nursery.FLOOR_TOP, 0.0))
	await wait_physics_frames(2)
	nursery.dentuda.bite(cop)
	assert_eq(owner_npc.complaint, Nursery.SAW_BITE)


func test_the_horn_sends_her_to_count_bags_twice() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var horn := nursery.horn
	var owner_npc := nursery.owner_npc
	horn.button.use(nursery.get_node("Cop"))
	assert_true(horn.is_counting())
	assert_true(horn.truck.visible, "the truck shows up")
	assert_eq(owner_npc.errand(), "printer", "she goes to count the bags")
	horn.press()
	assert_eq(horn.distractions, 1, "not again so soon")
	horn.fix()
	assert_false(horn.truck.visible)
	horn.rest_left = 0.0
	horn.press()
	assert_eq(horn.distractions, 2)
	horn.fix()
	horn.rest_left = 0.0
	horn.press()
	assert_false(horn.is_counting(), "the third time she catches on")
	assert_eq(owner_npc.complaint, Nursery.CAUGHT_ON)


func test_counting_she_sees_nothing() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var owner_npc := nursery.owner_npc
	owner_npc.start_at(1)
	nursery.horn.press()
	for i in 100:
		await wait_physics_frames(10)
		if owner_npc.is_fixing():
			break
	assert_true(owner_npc.is_fixing(), "she got to the gate")
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = owner_npc.global_position + Vector3(0, 0, 2)
	await wait_physics_frames(2)
	nursery.irrigation.slipped.emit(cop)
	assert_eq(owner_npc.complaint, 0.0, "her back to everything")
