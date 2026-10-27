extends GutTest

## The mansion online (escena-mansion.md, step 8; docs/diseno/online.md): the guests' mansion follows the host's
## members (cap, alibi, their walks through the passages), the passages, the armour, the bells, the parrot, the loot
## found and the culprit's run through the maze.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/mansion.tscn")

var _pcs: OnlinePcs


## A seed whose culprit runs off when accused.
static func _running_seed() -> int:
	for seed_value in range(1, 40):
		if hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY == 0:
			return seed_value
	return 1


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	var seed_value := _running_seed()
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: MansionLevel = LEVEL_SCENE.instantiate()
		level.case_seed = seed_value
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _mansion(net: Node) -> Mansion:
	return (OnlinePcs.level(net) as MansionLevel).mansion


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as MansionLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as MansionLevel).case.tip_given, 5.0)
	return pcs


func test_a_members_cap_and_alibi_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _mansion(pcs[0])
	var guest := _mansion(pcs[1])
	assert_true(guest.case.follower)
	var member := host.members[2]
	member.stubborn = false
	member.alibi()
	member.ask_cap()
	await wait_until(func() -> bool: return not guest.members[2].cap_on, 5.0)
	assert_false(guest.members[2].part("cap").visible, "their cap is off on the guest too")
	assert_true(guest.members[2].told_alibi)
	assert_eq(guest.case.file_traits(2).hair, member.traits.hair, "and the board's file knows their hair")


func test_a_walk_through_a_passage_reaches_the_guest() -> void:
	var pcs := await _on()
	var host := _mansion(pcs[0])
	var guest := _mansion(pcs[1])
	var walker: MysteryMember = null
	for member in host.members:
		if host.passage_from(member.room)[0] != "":
			walker = member
			break
	var to_room := host.send_through(walker)
	assert_ne(to_room, "")
	var other := guest.members[walker.index]
	await wait_until(func() -> bool: return other.room == "", 5.0)
	var id: String = host.passage_from(to_room)[0]
	assert_true((guest.passages[id] as SecretPassage).is_open, "the passage opens on the guest too")
	await wait_until(func() -> bool: return other.room == to_room, 30.0)
	assert_eq(other.room, to_room, "and they end in the same room")
	assert_almost_eq(other.position, walker.position, Vector3.ONE * 0.1)


func test_the_guest_does_not_send_members_on_its_own() -> void:
	var pcs := await _on()
	var guest := _mansion(pcs[1])
	var rooms := guest.members.map(func(member: MysteryMember) -> String: return member.room)
	guest._move_left = 0.0
	await wait_physics_frames(3)
	assert_eq(guest.members.map(func(member: MysteryMember) -> String: return member.room), rooms)


func test_the_armour_the_bells_the_parrot_and_the_loot_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _mansion(pcs[0])
	var guest := _mansion(pcs[1])
	host.armour.push_over()
	host.clues.mix_bells()
	host.parrot.offend()
	host.search(host.loot_spot, null)
	await wait_until(func() -> bool: return guest.armour.fallen, 5.0)
	await wait_until(func() -> bool: return guest.butler.mixed, 5.0)
	await wait_until(func() -> bool: return guest.parrot.offended, 5.0)
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_not_null(guest.get_node_or_null("Loot"))
	assert_true(guest.case.loot_found)


func test_the_culprits_run_and_catch_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _mansion(pcs[0])
	var guest := _mansion(pcs[1])
	host.case.accuse(host.case.plan.culprit)
	assert_not_null(host.case.runner, "the culprit runs off on the host")
	await wait_until(func() -> bool: return guest.case.runner != null, 5.0)
	assert_true(guest.case.runner.follower, "the guest's run follows the host's")
	var runner := guest.members[host.case.plan.culprit]
	var host_runner := host.case.runner.runner
	await wait_until(func() -> bool: return runner.room == "" and runner.position.distance_to(host_runner.position) < 0.5,
		5.0)
	host.case.runner.catch()
	await wait_until(func() -> bool: return guest.case.runner.caught, 5.0)
	assert_true(guest.case.runner.over)
	assert_false(guest.case.escaped, "caught on the guest too")
