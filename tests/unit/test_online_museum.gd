extends GutTest

## The museum online (escena-museo.md, step 6; docs/diseno/online.md): the guests' museum follows the host's guards
## (cap, mustache), the statue's coin, the toilet, the alarm, the frame, the monitors and the polisher, the loot found
## and the ruined clues.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/museum.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: MuseumLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 21
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _museum(net: Node) -> Museum:
	return (OnlinePcs.level(net) as MuseumLevel).museum


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as MuseumLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as MuseumLevel).case.tip_given, 5.0)
	return pcs


func test_the_museum_is_drawn() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "museum")
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % PlaceDraw.CRIME_SCENES.size()]] = true
	assert_true(drawn.has("museum"), "some seeds land on it")


func test_the_guards_cap_and_mustache_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _museum(pcs[0])
	var guest := _museum(pcs[1])
	assert_true(guest.case.follower)
	var guard := host.guards[3]
	guard.stubborn = false
	guard.ask_cap()
	guard.pull_mustache()
	await wait_until(func() -> bool: return not guest.guards[3].cap_on, 5.0)
	await wait_until(func() -> bool: return guest.guards[3].mustache_pulled, 5.0)
	assert_false(guest.guards[3].part("cap").visible, "his cap is off on the guest too")
	assert_eq(guest.guards[3].part("mustache").visible, guard.traits.mustache)
	assert_eq(guest.case.file_traits(3).hair, guard.traits.hair, "and the board's file knows his hair")


func test_the_alarm_and_the_statue_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _museum(pcs[0])
	var guest := _museum(pcs[1])
	host.alarm.ring()
	host.statue.tip(null)
	await wait_until(func() -> bool: return guest.alarm.ringing, 5.0)
	await wait_until(func() -> bool: return guest.statue.tipped, 5.0)
	host.alarm.stop()
	await wait_until(func() -> bool: return not guest.alarm.ringing, 5.0)
	assert_false(guest.alarm.ringing)


func test_the_monitors_polisher_and_loot_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _museum(pcs[0])
	var guest := _museum(pcs[1])
	host.clues.monitors.delete(null)
	host.clues.polisher.running = true
	host.clues.polisher.switched_off = true
	host.search(host.loot_spot, null)
	await wait_until(func() -> bool: return guest.clues.monitors.deleted, 5.0)
	await wait_until(func() -> bool: return guest.clues.polisher.switched_off, 5.0)
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_not_null(guest.get_node_or_null("Loot"))
	assert_true(guest.case.loot_found)
