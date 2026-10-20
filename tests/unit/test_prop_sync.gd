extends GutTest

## Synced props (docs/diseno/online.md, step 4): the host simulates the physics objects and the guests see them
## where the host has them; a guest's hands are asked of the host.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CRATE := preload("res://scenes/props/crate.tscn")
const FIGURINE := preload("res://scenes/props/ornament_figurine.tscn")
## Where the crate rests in every level, and where a cop stands to grab it.
const CRATE_AT := Vector3(0, 0.25, -5)
const GRAB_FROM := Vector3(0, 0, -3.5)

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, _fill_level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


## The same floor, crate and figurine on every PC.
func _fill_level(level: Node3D) -> void:
	var floor := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40, 1, 40)
	shape.shape = box
	floor.add_child(shape)
	floor.position = Vector3(0, -0.5, 0)
	level.add_child(floor)
	var crate: Grabbable = CRATE.instantiate()
	crate.name = "Crate"
	crate.position = CRATE_AT
	level.add_child(crate)
	var figurine: Ornament = FIGURINE.instantiate()
	figurine.name = "Figurine"
	figurine.position = Vector3(4, 0.1, -4)
	level.add_child(figurine)


func _crate(net: Node) -> Grabbable:
	return OnlinePcs.level(net).get_node("Crate")


func test_the_guest_props_are_frozen_copies() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	assert_false(_crate(pcs[0]).freeze, "the host simulates the crate")
	assert_true(_crate(pcs[1]).freeze, "the guest's crate only follows the host")
	assert_eq(pcs[1].props.props.size(), pcs[0].props.props.size(), "both PCs list the same props")


func test_the_guest_sees_the_crate_where_the_host_has_it() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var on_host := _crate(pcs[0])
	var on_guest := _crate(pcs[1])
	on_host.global_position = Vector3(2, 3, -6)
	on_host.linear_velocity = Vector3.ZERO
	await wait_until(func() -> bool: return on_guest.global_position.distance_to(on_host.global_position) < 0.05, 5.0)
	assert_almost_eq(on_guest.global_position, on_host.global_position, Vector3.ONE * 0.05)


func test_an_ornament_broken_on_the_host_breaks_for_everyone() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_level := OnlinePcs.level(pcs[1])
	(OnlinePcs.level(pcs[0]).get_node("Figurine") as Ornament).hit(10.0)
	await wait_until(func() -> bool: return guest_level.get_node_or_null("Figurine") == null, 5.0)
	assert_null(guest_level.get_node_or_null("Figurine"), "the guest's figurine shattered too")


func test_the_guest_grabs_through_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Node = pcs[0]
	var guest: Node = pcs[1]
	var guest_cop := OnlinePcs.own_cop(guest)
	guest_cop.global_position = GRAB_FROM
	guest_cop.rotation = Vector3.ZERO
	guest_cop.set_head_pitch(-0.62)
	var copy_on_host: Cop = host.cop_syncs[guest.multiplayer.get_unique_id()].cop
	await wait_until(func() -> bool: return copy_on_host.global_position.distance_to(GRAB_FROM) < 0.02, 5.0)
	await wait_physics_frames(10)
	assert_false(guest_cop.get_node("Grabber").try_grab(), "the guest only asks")
	await wait_until(func() -> bool: return guest_cop.get_node("Grabber").held != null, 5.0)
	assert_eq(copy_on_host.get_node("Grabber").held, _crate(host), "the host's copy of the guest's cop holds the crate")
	assert_eq(guest_cop.get_node("Grabber").held, _crate(guest), "and the guest sees it in its own hands")
	guest_cop.get_node("Grabber").release()
	await wait_until(func() -> bool: return copy_on_host.get_node("Grabber").held == null, 5.0)
	assert_false(_crate(host).is_held(), "letting go on the guest lets go on the host")


func test_solo_has_no_prop_sync() -> void:
	var net := _pcs.new_pc()
	net.spawn_cops(OnlinePcs.own_cop(net))
	assert_null(net.props)
