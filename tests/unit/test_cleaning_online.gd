extends GutTest

## The cleaning crew's jailbreak online (fuga-limpieza.md, "Online"): the same way out on every PC, Clotilde's doors
## and the stains follow the host.

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
	jail.case_seed = 4321
	jail.variant = "cleaning"
	return jail


func test_clotildes_open_door_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	assert_not_null(guest_level.cleaner, "the guest has her too")
	var cleaner := host_level.cleaner
	cleaner.set_physics_process(false)
	for i in 3000:
		if cleaner.doing() == "mop":
			break
		cleaner.run(0.1)
	var cell := cleaner.mopping_cell()
	await wait_until(func() -> bool: return not guest_level.city.cell_doors[cell].locked, 5.0)
	assert_true(guest_level.city.cell_doors[cell].is_open, "open on the guest")


func test_a_cleaned_stain_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	assert_eq(guest_level.stains.spots.size(), host_level.stains.spots.size(), "the same stains")
	for i in int(FloorStains.SCRUB / 0.1) + 2:
		host_level.stains.scrub_at(host_level.stains.spots[0] + Vector3.UP * 0.1, 0.1)
	await wait_until(func() -> bool: return guest_level.stains.is_clean(0), 5.0)
	assert_true(guest_level.stains.is_clean(0))
