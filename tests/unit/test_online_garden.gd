extends GutTest

## The prison garden online (carcel-huerta.md, step 7; docs/diseno/online.md): the host's plan and case decide, and
## every PC sees the same beds, beans, pulls, climbers and counts.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const GARDEN_SCENE := preload("res://scenes/levels/prison_garden.tscn")
const SEED := 9

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = GARDEN_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func _same(guest: PrisonLevel, plant: GardenPlant) -> GardenPlant:
	return guest.garden.plants[plant.bed * GardenPlan.PER_BED + plant.slot]


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.garden_case.follower)
	assert_true(guest.garden.follower)
	assert_true(guest.garden.plants[0].follower)
	assert_eq(guest.garden.kinds, host.garden.kinds, "the same garden from the same seed")
	for i in GardenPlan.MAGIC:
		assert_eq(guest.garden.beans[i].name, host.garden.beans[i].name)


func test_a_bean_grows_and_is_pulled_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	var bean := host.garden.beans[0]
	var copy := _same(guest, bean)
	bean.growing = true
	bean.set_stage(2)
	await wait_until(func() -> bool: return copy.stage == 2, 5.0)
	assert_not_null(copy.get_node_or_null("Stalk"))
	host.garden._on_tugged(bean, host.get_node("Cop"))
	await wait_until(func() -> bool: return copy.pulled, 5.0)
	await wait_until(func() -> bool: return guest.garden.pulled == 1 and guest.garden.early == 1, 5.0)
	assert_eq(guest.garden_case.rows()[1].text, tr("OBJ_GARDEN_BEANS") % [1, GardenPlan.MAGIC])


func test_the_guest_cannot_pull_by_itself() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _level(pcs[1])
	var bean := guest.garden.beans[0]
	guest.garden._on_tugged(bean, guest.get_node("Cop"))
	assert_false(bean.pulled, "the host decides")
	assert_eq(guest.garden.pulled, 0)


func test_a_climber_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	var bean := host.garden.beans[0]
	bean.set_stage(GardenPlant.STAGES)
	host.garden.send_climber(bean)
	await wait_until(func() -> bool: return guest.garden.climbers.size() == 1, 5.0)
	await wait_physics_frames(2)
	var copy := guest.garden.climbers[0]
	assert_not_null(OwnerEscort.of(copy), "the guest's cops can walk him to a cell")
	var climber := host.garden.climbers[0]
	climber.global_position = host.global_transform * climber.foot
	await wait_until(func() -> bool: return copy.climbing, 5.0)
	assert_eq(copy.prompt_key(guest.get_node("Cop")), "PROMPT_GARDEN_PULL_DOWN")
	climber._climb.custom_step(100.0)
	await wait_until(func() -> bool: return guest.garden.escaped == 1, 5.0)


func test_the_end_of_garden_time_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.garden.start()
	host.garden.time = GardenPlan.TIME - 0.01
	await wait_until(func() -> bool: return guest.garden.over and guest.garden_case.solved_it, 5.0)
	assert_true(guest.garden_case.rows()[0].done)
