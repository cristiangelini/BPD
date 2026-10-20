extends GutTest

## A player who comes in during a case (docs/diseno/online.md, "Entrar a mitad de un caso"): it opens the same case,
## everyone gets its cop, and the host sends it how things are now.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CRATE := preload("res://scenes/props/crate.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, _fill_level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


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
	crate.position = Vector3(0, 0.25, -5)
	level.add_child(crate)


func _late_joins(host: Node) -> Node:
	var late: Node = _pcs.new_pc()
	late.join("127.0.0.1", _pcs.port)
	await wait_until(func() -> bool: return late.players.size() == 3, 5.0)
	late.spawn_cops(OnlinePcs.own_cop(late))
	await wait_until(func() -> bool: return host.scene_peers.size() == 2, 5.0)
	return late


func test_everyone_gets_the_late_players_cop() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var late: Node = await _late_joins(pcs[0])
	var late_id: int = late.multiplayer.get_unique_id()
	for net: Node in pcs:
		assert_true(net.cop_syncs.has(late_id), "a cop for the newcomer")
		assert_eq(net.cop_syncs[late_id].cop.uniform, 2, "in the third color")
	assert_eq(late.cop_syncs.size(), 3, "and the newcomer sees the two that were there")


func test_the_late_player_sees_things_where_they_are_now() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_crate: Grabbable = OnlinePcs.level(pcs[0]).get_node("Crate")
	host_crate.global_position = Vector3(3, 0.25, 2)
	host_crate.linear_velocity = Vector3.ZERO
	var late: Node = await _late_joins(pcs[0])
	var late_crate: Grabbable = OnlinePcs.level(late).get_node("Crate")
	await wait_until(func() -> bool: return late_crate.global_position.distance_to(host_crate.global_position) < 0.3, 3.0)
	assert_almost_eq(late_crate.global_position.x, host_crate.global_position.x, 0.3, "where the host moved it")
