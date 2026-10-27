extends GutTest

## People and animals online (docs/diseno/online.md, step 5): the host runs them and the guests' copies follow, with
## the same bubbles and complaint; only the host brings the bakery's customers in.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const BAKERY := preload("res://scenes/levels/bakery.tscn")
const SEED := 777

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_bakery)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_bakery() -> Node3D:
	var bakery: Node3D = BAKERY.instantiate()
	bakery.case_seed = SEED
	return bakery


func _baker(net: Node) -> Baker:
	return OnlinePcs.level(net).baker


func test_the_guest_baker_is_a_puppet() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	assert_true(_baker(pcs[0]).is_physics_processing(), "the host runs Marta")
	assert_false(_baker(pcs[1]).is_physics_processing(), "the guest's Marta only follows")


func test_marta_moves_talks_and_gets_annoyed_the_same_for_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var on_host := _baker(pcs[0])
	var on_guest := _baker(pcs[1])
	on_host.global_position += Vector3(1.0, 0, 0.5)
	var bubble: Label3D = on_host.get_node("Bubble")
	bubble.text = "BAKER_BUSY"
	bubble.show()
	on_host.complaint = 30.0
	await wait_until(func() -> bool: return on_guest.global_position.distance_to(on_host.global_position) < 0.05, 5.0)
	assert_almost_eq(on_guest.global_position, on_host.global_position, Vector3.ONE * 0.05)
	assert_eq(on_guest.get_node("Bubble").text, "BAKER_BUSY")
	assert_true(on_guest.get_node("Bubble").visible)
	assert_almost_eq(on_guest.complaint, 30.0, 0.01, "the complaint bar fills the same")


func test_only_the_host_brings_customers_in() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_bakery: Node3D = OnlinePcs.level(pcs[0])
	var guest_level: Node3D = OnlinePcs.level(pcs[1])
	assert_false(guest_level.brings_customers)
	host_bakery.add_customer()
	var second: BakeryCustomer = host_bakery.add_customer()
	await wait_until(func() -> bool: return guest_level.find_children("*", "BakeryCustomer", true, false).size() >= 2, 5.0)
	await wait_physics_frames(10)
	var copies := guest_level.find_children("*", "BakeryCustomer", true, false)
	assert_eq(copies.size(), host_bakery.find_children("*", "BakeryCustomer", true, false).size(),
		"the guest has a copy of each of the host's customers and none of its own")
	assert_eq((copies[1] as BakeryCustomer).look, second.look, "dressed the same")
	assert_false(copies[0].is_physics_processing())


func test_a_customer_who_leaves_on_the_host_leaves_for_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_level: Node3D = OnlinePcs.level(pcs[1])
	var customer: BakeryCustomer = OnlinePcs.level(pcs[0]).add_customer()
	await wait_until(func() -> bool: return guest_level.find_children("*", "BakeryCustomer", true, false).size() >= 1, 5.0)
	var before := guest_level.find_children("*", "BakeryCustomer", true, false).size()
	customer.queue_free()
	await wait_until(func() -> bool: return guest_level.find_children("*", "BakeryCustomer", true, false).size() < before, 5.0)
	assert_lt(guest_level.find_children("*", "BakeryCustomer", true, false).size(), before)


func test_busy_states_go_in_packets_under_the_mtu() -> void:
	var ids := PackedInt32Array()
	var states := []
	for i in 20:
		ids.append(i)
		states.append([Transform3D(), "¡Esto es un bocadillo bastante largo para llenar el paquete!", true, 0.0, false,
			{"plan": "a long plan", "trick": "a trick", "step": i}, [false, 0]])
	var packets: Array = NpcSync.packets(ids, states)
	var sent := 0
	for packet: Array in packets:
		assert_lte(var_to_bytes(packet[1]).size(), NpcSync.PACKET_BYTES + 16, "a packet fits")
		assert_lte((packet[0] as PackedInt32Array).size(), NpcSync.PER_PACKET)
		sent += (packet[0] as PackedInt32Array).size()
	assert_eq(sent, 20, "and all of them go")
	assert_gt(packets.size(), 20 / NpcSync.PER_PACKET, "more packets than by count alone")
