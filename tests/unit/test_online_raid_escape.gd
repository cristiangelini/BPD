extends GutTest

## The raid's owner running off online (persecucion-final.md, decision 96; docs/diseno/online.md): the host decides he
## ran off and runs the chase after him, and every PC sees him drive off, the meters and how it ends.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var house: GrandpaHouse = HOUSE_SCENE.instantiate()
		house.story = GrandpaHouse.BINGO
		house.case_seed = 7
		house.start_at_station = false
		house.get_node("Cop/Grabber").input_enabled = false
		return house)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _raid(net: Node) -> RaidCase:
	return (OnlinePcs.level(net) as GrandpaHouse).raid


## Host and guest with the grandpa run off on the host.
func _fled() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	_raid(pcs[0]).escape.flee()
	await wait_until(func() -> bool: return _raid(pcs[1]).escape.fled, 5.0)
	return pcs


func test_he_runs_off_on_every_pc_in_one_wheelchair() -> void:
	var pcs := await _fled()
	var host := _raid(pcs[0]).escape.chase
	var guest := _raid(pcs[1]).escape.chase
	assert_true(guest.follower)
	assert_false(host.follower)
	assert_false((OnlinePcs.level(pcs[1]) as GrandpaHouse).grandpa.visible, "he's gone from the house on the guest")
	await wait_physics_frames(30)
	var cars := OnlinePcs.level(pcs[1]).find_children("*", "SuspectCar", false, false)
	assert_eq(cars.size(), 1, "one wheelchair on the guest, the host's")
	assert_eq((cars[0] as SuspectCar).kind, "wheelchair")
	await wait_until(func() -> bool: return guest.truck.global_position.distance_to(host.truck.global_position) < 0.5, 5.0)
	assert_almost_eq(guest.truck.global_position.distance_to(host.truck.global_position), 0.0, 0.5, "where the host's goes")
	await wait_until(func() -> bool: return guest.time_left < ChaseCase.TIME_LIMIT, 5.0)
	assert_almost_eq(guest.time_left, host.time_left, 0.5, "the guest's clock is the host's")


func test_he_gets_out_on_every_pc_and_getting_away_ends_it_everywhere() -> void:
	var pcs := await _fled()
	var host := _raid(pcs[0]).escape.chase
	var guest := _raid(pcs[1]).escape.chase
	host.pull_over()
	await wait_until(func() -> bool: return guest.suspect != null, 5.0)
	assert_eq(guest.suspect.kind, "grandpa", "the grandpa gets off on the guest")
	host.fail("CASE_FAILED_TIME")
	await wait_until(func() -> bool: return guest.case_failed, 5.0)
	assert_false(guest.chasing, "it's over on the guest")
	assert_true(_raid(pcs[1]).escape.escaped, "and the guest's raid knows he got away")
	assert_false(_raid(pcs[1]).case_failed, "the raid goes on")
