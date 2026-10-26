extends GutTest

## The bribe jailbreak online (fuga-soborno.md, "Online"): the host runs the guard and the camera; a guest's cop calls
## him from the bars and sees him come, the price and what he's paid, and the camera turning the same.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL := preload("res://scenes/levels/jailbreak.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_jail)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_jail() -> Node3D:
	var jail: JailbreakLevel = LEVEL.instantiate()
	jail.case_seed = 5151
	jail.variant = "bribe"
	return jail


func test_a_guest_calls_the_guard_and_sees_him_paid() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	var host_guard := host_level.guard as BribeGuard
	var guest_guard := guest_level.guard as BribeGuard
	host_guard.camera = null
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.act("use", guest_level.city.cell_doors[1])
	await wait_until(func() -> bool: return host_guard.stage == "coming", 5.0)
	assert_eq(host_guard.at_cell, 1, "the host's guard comes to the guest's door")
	await wait_until(func() -> bool: return guest_guard.stage != "", 5.0)
	assert_eq(guest_guard.at_cell, 1, "and the guest sees him come")
	await wait_until(func() -> bool: return host_guard.stage == "at_bars", 15.0)
	await wait_until(func() -> bool: return guest_guard.line == "BRIBE_GUARD_PRICE", 5.0)
	assert_eq(guest_guard.line_number, host_guard.price, "the same price on the guest")
	host_guard.paid = host_guard.price - BribeGuard.HAGGLE_DROP
	host_guard.haggle()
	await wait_until(func() -> bool: return not guest_guard.key_on_belt, 5.0)
	assert_true(guest_guard.is_paid(), "paid on the guest too")
	assert_eq(guest_guard.haggles, 1)
	var host_camera: CorridorCamera = host_level.get_node("CorridorCamera")
	var guest_camera: CorridorCamera = guest_level.get_node("CorridorCamera")
	host_camera.left = 0.01
	await wait_until(func() -> bool: return guest_camera.turning, 5.0)
	assert_eq(guest_camera.cell, host_camera.cell, "the camera turns on the guest too")
