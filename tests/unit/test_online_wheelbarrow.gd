extends GutTest

## The wheelbarrow online (docs/diseno/online.md, "Herramientas"): pushing, loading, parking and tipping it over
## happen on every PC, and what it carries is still moved by the host.

const PCS := preload("res://tests/unit/online_pcs.gd")
const CRATE := preload("res://scenes/props/crate.tscn")

var pcs: PCS


func before_each() -> void:
	pcs = PCS.new(self, func(level: Node3D) -> void:
		var crate: Grabbable = CRATE.instantiate()
		crate.name = "Crate"
		crate.position = Vector3(3, 0.5, 3)
		level.add_child(crate)
		var barrow: Wheelbarrow = Armory.WHEELBARROW_SCENE.instantiate()
		barrow.name = "Wheelbarrow"
		barrow.position = Vector3(-3, 0, 3)
		level.add_child(barrow))


func after_each() -> void:
	pcs.free_all()
	await wait_process_frames(2)


func test_a_guest_pushes_loads_and_tips_it_over_on_every_pc() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest: Node = pair[1]
	var guest_cop := PCS.own_cop(guest)
	var on_host: Wheelbarrow = PCS.level(host).get_node("Wheelbarrow")
	var on_guest: Wheelbarrow = PCS.level(guest).get_node("Wheelbarrow")
	var copy: Cop = host.cop_syncs[guest.multiplayer.get_unique_id()].cop
	guest_cop.act("use", on_guest)
	await wait_until(func() -> bool: return on_host.pusher == copy, 5.0)
	assert_eq(on_host.pusher, copy, "the host sees the guest pushing it")
	assert_eq(on_guest.pusher, guest_cop)
	var crate_on_guest: Grabbable = PCS.level(guest).get_node("Crate")
	var crate_on_host: Grabbable = PCS.level(host).get_node("Crate")
	guest_cop.act("wheelbarrow_load", guest_cop, [crate_on_guest])
	await wait_until(func() -> bool: return on_host.cargo.has(crate_on_host), 5.0)
	assert_true(on_host.cargo.has(crate_on_host), "loaded on the host")
	assert_true(on_guest.cargo.has(crate_on_guest), "and on the guest")
	guest_cop.act("wheelbarrow_dump", guest_cop)
	await wait_until(func() -> bool: return on_host.cargo.is_empty() and on_host.pusher == null, 5.0)
	assert_true(on_guest.cargo.is_empty())
	assert_false(crate_on_host.freeze, "the host's crate falls out for real")
	assert_true(crate_on_guest.freeze, "the guest's stays a copy that follows the host")
