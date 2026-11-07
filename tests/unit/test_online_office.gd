extends GutTest

## The office online (escena-oficina.md, step 6; docs/diseno/online.md): it's drawn among the crime scenes, and the
## guests' office follows the host's: the desk bell, the employees and their coffee, Pelusa, Benja and the jugs off the
## water truck.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/forms_office.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: FormsOfficeLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 21
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _office(net: Node) -> FormsOffice:
	return (OnlinePcs.level(net) as FormsOfficeLevel).office


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as FormsOfficeLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as FormsOfficeLevel).case.tip_given, 5.0)
	return pcs


func test_the_office_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "office")
	assert_true(PlaceDraw.PLACES.has("office"))
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 600):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_eq(drawn.size(), count, "every crime scene comes up")
	for node: Node in [OfficeEmployee.new(), OfficeIntern.new(), RobotVacuum.new(), ChaseJug.new()]:
		assert_true(NpcSync.is_npc(node), "the guests see the host's %s" % node.get_class())
		node.free()


func test_the_desk_bell_and_the_coffee_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _office(pcs[0])
	var guest := _office(pcs[1])
	assert_true(guest.case.follower)
	guest.bell_in = 0.0
	await wait_physics_frames(2)
	assert_eq(guest.bell_in, 0.0, "a guest's office doesn't ring on its own")
	host.ring_desk_bell()
	await wait_until(func() -> bool: return guest.desk_of == host.desk_of, 5.0)
	assert_eq(guest.desk_of, host.desk_of)
	var employee := host.employees[0]
	employee.hold_cup(true)
	employee.on_break = true
	host.coffee_machine.screen.text = "COFFEE_SCREEN_BREWING"
	await wait_until(func() -> bool: return guest.coffee_machine.screen.text == "COFFEE_SCREEN_BREWING", 5.0)
	await wait_until(func() -> bool: return guest.employees[0].on_break, 5.0)
	var cup := guest.employees[0].part("cup_left" if employee.traits.get("left", false) else "cup_right")
	assert_true(cup.visible, "the cup in the same hand")
	for i in 30:
		host.employees[1].position.x += 0.1
	await wait_until(func() -> bool:
		return guest.employees[1].global_position.distance_to(host.employees[1].global_position) < 0.3, 5.0)
	assert_lt(guest.employees[1].global_position.distance_to(host.employees[1].global_position), 0.3)


func test_pelusa_and_benja_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _office(pcs[0])
	var guest := _office(pcs[1])
	host.vacuum.use(null)
	host.intern.offend()
	await wait_until(func() -> bool: return guest.vacuum.flipped and guest.intern.offended, 5.0)
	assert_false(guest.vacuum.running, "on its back on the guest's too")
	assert_true(guest.witness_offended())
