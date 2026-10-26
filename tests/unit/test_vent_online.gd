extends GutTest

## The vent jailbreak online (fuga-ventilacion.md, "Online"): the host decides the screws, the duct's way out and the
## key board; the guests see the same.

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
	jail.case_seed = 7171
	jail.variant = "vent"
	return jail


func test_the_guest_sees_the_screws_the_duct_and_the_key() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	assert_eq(guest_level.grilles.size(), 2, "the guest has the grilles")
	assert_eq(guest_level.duct.exit_stub, host_level.duct.exit_stub, "and the same way out")
	assert_eq(guest_level.key_board.good, host_level.key_board.good, "and the same good key")
	assert_eq(guest_level.big_cop().uniform, host_level.big_cop().uniform, "and the same big one")
	for i in VentGrille.TURNS:
		host_level.grilles[0].turn()
	await wait_until(func() -> bool: return guest_level.grilles[0].screws_left == VentGrille.SCREWS - 1, 5.0)
	assert_eq(guest_level.grilles[0].screws_left, VentGrille.SCREWS - 1, "a screw out on the guest too")
	host_level.key_board.has_key = false
	await wait_until(func() -> bool: return not guest_level.key_board.has_key, 5.0)
	assert_false(guest_level.key_board.has_key, "the key gone on the guest too")
