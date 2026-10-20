extends GutTest

## The belt online (docs/diseno/online.md, "Herramientas"): the tool in hand, the flashlight and the cuffs are the same
## on every PC.

const PCS := preload("res://tests/unit/online_pcs.gd")

## Someone who reacts to a photo, like the place's owner.
class Subject:
	extends StaticBody3D
	var shots := 0

	func photographed(_cop: Cop) -> void:
		shots += 1


var pcs: PCS


func before_each() -> void:
	pcs = PCS.new(self, func(level: Node3D) -> void:
		var subject := Subject.new()
		subject.name = "Subject"
		level.add_child(subject))


func after_each() -> void:
	pcs.free_all()
	await wait_process_frames(2)


func test_the_tool_in_hand_and_the_flashlight_show_on_every_pc() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest: Node = pair[1]
	var guest_cop := PCS.own_cop(guest)
	var copy: Cop = host.cop_syncs[guest.multiplayer.get_unique_id()].cop
	guest_cop.act("belt_select", guest_cop, [2])
	await wait_until(func() -> bool: return copy.belt.current == 2, 5.0)
	assert_eq(guest_cop.belt.current, 2, "the camera in the guest's hand")
	assert_eq(copy.belt.current, 2, "and in its copy on the host")
	guest_cop.act("belt_flashlight", guest_cop)
	await wait_until(func() -> bool: return copy.belt.flashlight.is_on, 5.0)
	assert_true(guest_cop.belt.flashlight.is_on)
	assert_true(copy.belt.flashlight.light.visible, "the host sees the guest's light")


func test_a_guest_cuffs_the_host_and_frees_him() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest: Node = pair[1]
	var guest_cop := PCS.own_cop(guest)
	var host_cop := PCS.own_cop(host)
	var host_copy: Cop = guest.cop_syncs[host.multiplayer.get_unique_id()].cop
	guest_cop.act("belt_cuff", guest_cop, [host_copy, host_copy.global_position])
	await wait_until(func() -> bool: return host_cop.is_cuffed(), 5.0)
	assert_true(host_cop.is_cuffed(), "the host's own cop is cuffed")
	assert_true(host_copy.is_cuffed(), "and the guest sees it")
	guest_cop.act("free_partner", guest_cop, [host_copy])
	await wait_until(func() -> bool: return not host_cop.is_cuffed(), 5.0)
	assert_false(host_cop.is_cuffed())
	assert_false(host_copy.is_cuffed())


func test_a_guests_photo_happens_on_every_pc() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest: Node = pair[1]
	var guest_cop := PCS.own_cop(guest)
	var copy: Cop = host.cop_syncs[guest.multiplayer.get_unique_id()].cop
	var on_host: Subject = PCS.level(host).get_node("Subject")
	guest_cop.act("belt_photo", guest_cop, [PCS.level(guest).get_node("Subject"), []])
	await wait_until(func() -> bool: return on_host.shots > 0, 5.0)
	assert_eq(on_host.shots, 1, "the host's owner saw the flash")
	assert_eq((copy.belt.tools[2] as PhotoCamera).film, PhotoCamera.FILM - 1, "one photo less on the copy too")
	assert_eq(copy.stats.get("photos", 0), 1, "it counts for the photographer award on the host")


func test_nodes_travel_as_something_every_pc_can_find() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var actions: ActionSync = host.actions
	var host_cop := PCS.own_cop(host)
	assert_eq(actions.encode(host_cop), {"cop": 1}, "a cop by its player")
	assert_eq(actions.decode(actions.encode(host_cop)), host_cop)
	assert_eq(actions.encode(3), 3, "plain values as they are")
