extends GutTest

## The farm raid online (allanamiento-granja.md, step 7): the animals are run by the host and followed by the guests,
## the corral's gate and the greenhouse follow the host, the eggs the hens lay come over golden or not, the giant
## carrot two cops pull out on the host lies out on the guest, and the pigs dig up the same things everywhere.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const FARM := preload("res://scenes/levels/farm_raid.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "golden_eggs"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_farm)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_farm() -> Node3D:
	var farm: FarmRaid = FARM.instantiate()
	farm.case_seed = SEED
	farm.story_id = _story
	return farm


func test_the_animals_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FarmRaid = OnlinePcs.level(pcs[0])
	var guest: FarmRaid = OnlinePcs.level(pcs[1])
	for animal: Node3D in [guest.goat, guest.cow, guest.pigs[0], guest.pancho]:
		assert_false(animal.is_physics_processing(), "%s only follows on the guest" % animal.name)
	host.cow.global_position += Vector3(1.5, 0, 0)
	await wait_until(func() -> bool: return guest.cow.global_position.distance_to(host.cow.global_position) < 0.1 \
		and guest.goat.global_position.distance_to(host.goat.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.cow.global_position.distance_to(host.cow.global_position), 0.0, 0.1, "Margarita too")


func test_the_gate_and_the_greenhouse_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FarmRaid = OnlinePcs.level(pcs[0])
	var guest: FarmRaid = OnlinePcs.level(pcs[1])
	host.corral_gate.set_open(true)
	host.break_greenhouse()
	await wait_until(func() -> bool: return guest.corral_gate.is_open and guest.greenhouse_broken, 5.0)
	assert_true(guest.corral_gate.is_open, "open on the guest too")
	assert_true(guest.greenhouse_broken, "and the glass is gone")


func test_a_golden_egg_laid_on_the_host_is_golden_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FarmRaid = OnlinePcs.level(pcs[0])
	var guest: FarmRaid = OnlinePcs.level(pcs[1])
	var egg := host.add_egg(Vector3(0, 0.5, 5), true)
	var props: PropSync = pcs[1].get_node("Props")
	var index: int = (pcs[0].get_node("Props") as PropSync).index_of(egg)
	await wait_until(func() -> bool: return props.prop_at(index) != null, 5.0)
	var copy := props.prop_at(index) as FarmEgg
	assert_not_null(copy, "the guest has a copy")
	assert_true(copy.golden, "painted gold")
	assert_true(guest.is_ancestor_of(copy))


func test_the_carrot_pulled_out_on_the_host_lies_out_on_the_guest() -> void:
	_story = "giant_carrots"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FarmRaid = OnlinePcs.level(pcs[0])
	var guest: FarmRaid = OnlinePcs.level(pcs[1])
	(host.rig as GiantCarrotsRig).pull_out()
	var rig := guest.rig as GiantCarrotsRig
	await wait_until(func() -> bool: return rig.pulled, 5.0)
	assert_true(rig.loose.visible, "lying beside its hole on the guest")
	assert_true(rig.loose.freeze, "where the host's goes (PropSync)")


func test_the_pigs_dig_up_the_same_things_everywhere() -> void:
	_story = "piggy_bank"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FarmRaid = OnlinePcs.level(pcs[0])
	var guest: FarmRaid = OnlinePcs.level(pcs[1])
	var host_rig := host.rig as PiggyBankRig
	var guest_rig := guest.rig as PiggyBankRig
	for i in 3:
		host_rig.dig()
	await wait_until(func() -> bool: return guest_rig.dug == 3, 5.0)
	assert_true(guest.main.visible, "the piggy bank is out on the guest too")
	assert_true(guest.main.freeze, "and the host moves it")
