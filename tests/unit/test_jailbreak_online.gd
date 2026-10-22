extends GutTest

## The jailbreak online (fuga.md, "Online"): only the host makes the donuts and the key, and a catch locks the cells
## on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL := preload("res://scenes/levels/jailbreak.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_jail)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_jail() -> Node3D:
	var jail: Node3D = LEVEL.instantiate()
	jail.case_seed = 777
	return jail


func _donuts(root: Node) -> Array:
	return root.find_children("*", "RigidBody3D", true, false).filter(func(body: Node) -> bool: return body is LooseDonut)


func test_a_donut_the_host_takes_out_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level := OnlinePcs.level(pcs[0])
	var guest_level := OnlinePcs.level(pcs[1])
	host_level.box.use(OnlinePcs.own_cop(pcs[0]))
	assert_is(OnlinePcs.own_cop(pcs[0]).get_node("Grabber").held, LooseDonut, "in the host cop's hands")
	await wait_until(func() -> bool: return not _donuts(guest_level).is_empty(), 5.0)
	assert_eq(_donuts(guest_level).size(), 1, "one copy on the guest")


func test_a_guest_doesnt_make_its_own_donut_or_key() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_level := OnlinePcs.level(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_level.box.use(guest_cop)
	assert_null(guest_cop.get_node("Grabber").held, "the donut comes from the host")
	var guard: NightGuard = guest_level.guard
	guard.key_on_belt = true
	guard.fall_asleep()
	assert_null(guard.key_at(guard.belt()), "nor the key off the belt")
	assert_true(guard.key_on_belt)


func test_a_catch_locks_the_cells_on_the_guest_too() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_level := OnlinePcs.level(pcs[1])
	for door: CellDoor in guest_level.city.cell_doors:
		door.unlock()
	OnlinePcs.level(pcs[0]).guard.catch()
	await wait_until(func() -> bool: return guest_level.guard.times_caught == 1, 5.0)
	await wait_process_frames(2)
	for door: CellDoor in guest_level.city.cell_doors:
		assert_true(door.locked, "locked again on the guest")
