extends GutTest

## The prison riot online (carcel-motin.md, step 6; docs/diseno/online.md): the host's riot decides the inmates'
## anger, the throws, the ringleaders and the end, and every PC sees the same.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const PRISON_SCENE := preload("res://scenes/levels/prison.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = PRISON_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _prison(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _prison(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.riot.follower)
	assert_true(guest.riot.inmates[0].follower, "only the host's inmates get angry and throw")


func test_anger_and_cuffs_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _prison(pcs[0])
	var guest := _prison(pcs[1])
	var inmate := host.riot.inmates.filter(func(i: PrisonInmate) -> bool: return not i.ringleader)[0] as PrisonInmate
	var index := host.riot.inmates.find(inmate)
	inmate.raise(100.0)
	await wait_until(func() -> bool: return guest.riot.inmates[index].is_angry(), 5.0)
	inmate.cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return guest.riot.inmates[index].is_cuffed(), 5.0)
	assert_false(guest.riot.inmates[index].is_angry(), "cuffed, calm on the guest too")


func test_a_throw_splats_on_the_guest_too() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _prison(pcs[0])
	var guest := _prison(pcs[1])
	var inmate := host.riot.inmates[0]
	inmate.throw_at(inmate.global_position + Vector3(0, 0, 4), "mash")
	await wait_until(func() -> bool: return guest.find_child("Splat", false, false) != null, 5.0)
	assert_not_null(guest.find_child("Splat", false, false), "the guest sees where it landed")


func test_a_jailed_ringleader_shows_in_the_cell_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _prison(pcs[0])
	var guest := _prison(pcs[1])
	host.riot.start()
	var leader := host.riot.ringleaders[0]
	var index := host.riot.ringleaders.find(leader)
	leader.cuffed(Handcuffs.SECONDS)
	leader.global_position = host.to_global(Vector3(-11.0, PrisonLevel.FLOOR_TOP, -5.5))
	leader.use(OnlinePcs.own_cop(pcs[0]))
	await wait_until(func() -> bool: return guest.riot.ringleaders[index].is_jailed(), 5.0)
	assert_eq(guest.riot.jailed, 1)


func test_the_overflow_and_the_end_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _prison(pcs[0])
	var guest := _prison(pcs[1])
	host.riot.start()
	for inmate in host.riot.inmates.slice(0, PrisonCase.OVERFLOW + 1):
		inmate.raise(100.0)
	await wait_until(func() -> bool: return guest.case.overflowed, 5.0)
	assert_true(guest.kitchen_door.is_broken, "the kitchen door comes down on the guest too")
	await wait_until(func() -> bool: return guest.case.shift_over, PrisonCase.SHIFT_DELAY + 5.0)
	assert_false(guest.case.solved())
