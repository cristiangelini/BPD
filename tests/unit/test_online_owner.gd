extends GutTest

## The raid's owner online (interrogatorio.md, "El dueño del allanamiento"; online.md): the host walks him to the
## patrol car for whichever cop took him, and every PC sees him ride in the back.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var house: GrandpaHouse = HOUSE_SCENE.instantiate()
		house.story = GrandpaHouse.BINGO
		house.case_seed = 7
		house.get_node("Cop/Grabber").input_enabled = false
		return house)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _house(net: Node) -> GrandpaHouse:
	return OnlinePcs.level(net) as GrandpaHouse


func test_a_guest_walks_the_owner_into_the_car_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_house := _house(pcs[0])
	var guest_house := _house(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	# The cuffs went on through the belt, on every PC.
	for house: GrandpaHouse in [host_house, guest_house]:
		house.grandpa.cuffed(Handcuffs.SECONDS)
	guest_cop.global_position = guest_house.car.to_global(Vector3(1.5, 0.1, -0.5))
	host_house.grandpa.global_position = host_house.car.to_global(Vector3(1.5, 0.1, 6.0))
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	await wait_until(func() -> bool: return copy.global_position.distance_to(guest_cop.global_position) < 0.5, 5.0)
	guest_cop.act("use", guest_house.grandpa)
	var host_escort := OwnerEscort.of(host_house.grandpa)
	var guest_escort := OwnerEscort.of(guest_house.grandpa)
	await wait_until(func() -> bool: return host_escort.escorted_by == copy, 5.0)
	assert_eq(host_escort.escorted_by, copy, "the host walks him after the guest's cop")
	await wait_until(func() -> bool: return guest_escort.escorted_by == guest_cop, 5.0)
	assert_eq(guest_escort.escorted_by, guest_cop, "and the guest sees whose arm he's on")
	assert_true(guest_escort.follower, "the guest's copy doesn't walk him on its own")
	await wait_until(func() -> bool: return guest_escort.in_car, 15.0)
	assert_true(host_escort.in_car, "the host put him in the car")
	assert_eq(guest_house.car.prisoner, guest_house.grandpa, "the guest sees him in the back")
	await wait_physics_frames(3)
	assert_almost_eq(guest_house.grandpa.global_position.distance_to(guest_house.car.prisoner_seat().origin), 0.0, 0.05,
		"riding in the back seat")



func test_the_owner_in_custody_sits_in_the_chair_on_every_pc() -> void:
	# The guest's PC got the host's custody with the case (Net.match_custody); both PCs read it here.
	PlaceDraw.custody = {"owner": "baker", "story": "wedding", "slips": [], "missed": 300}
	var interrogation := OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: InterrogationLevel = preload("res://scenes/levels/interrogation.tscn").instantiate()
		level.case_seed = 7
		return level)
	var pcs: Array[Node] = await interrogation.two_pcs()
	var host: InterrogationLevel = OnlinePcs.level(pcs[0])
	var guest: InterrogationLevel = OnlinePcs.level(pcs[1])
	assert_eq(guest.suspect.kind, "owner_baker", "the guest has the host's owner in the chair")
	assert_eq(guest.case.suspect_id, host.case.suspect_id)
	host.case.give_tip()
	await wait_until(func() -> bool: return guest.case.tip_given, 5.0)
	OnlinePcs.own_cop(pcs[1]).act("use", guest.get_node("City").find_child("Prop_slam_table", true, false))
	await wait_until(func() -> bool: return guest.case.nerves > 0.0, 5.0)
	assert_gt(host.case.nerves, 0.0, "the guest's slam counted on the host")
	assert_eq(guest.case.nerves, host.case.nerves)
	interrogation.free_all()
