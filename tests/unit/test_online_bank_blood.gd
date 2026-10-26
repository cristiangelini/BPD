extends GutTest

## The blood bank online (robo-banco-sangre.md, step 5, decision 128): the host's bank decides the light, the bags'
## warmth and the vampires hiding; every PC sees the same, and a guest's fuse box and flashlight work there too.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const BANK_SCENE := preload("res://scenes/levels/bank.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "blood":
		seed_ += 1
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var bank: BankLevel = BANK_SCENE.instantiate()
		bank.case_seed = seed_
		bank.get_node("Cop/Grabber").input_enabled = false
		return bank)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _bank(net: Node) -> BankLevel:
	return OnlinePcs.level(net) as BankLevel


## The host's copy of the guest's cop (two PCs: the only other cop there).
func _copy_of(host: BankLevel) -> Cop:
	for node in host.get_children():
		if node is Cop and node != host.get_node("Cop"):
			return node
	return null


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _bank(pcs[1])
	assert_true(guest.blood, "the blood bank on the guest's PC too")
	assert_true(guest.blood_bank.follower, "the guest's light and bags only show the host's")
	for bag in guest.blood_bank.bags:
		assert_true(bag.follower, "each bag warms up only on the host")


func test_a_guest_at_the_fuse_box_lights_every_pc_and_it_goes_off_everywhere() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.blood_bank.fuse_box)
	await wait_until(func() -> bool: return host.blood_bank.lights_on() and guest.blood_bank.lights_on(), 5.0)
	assert_true(host.blood_bank.lights_on(), "the light on at the host")
	assert_true(guest.blood_bank.lights_on(), "and on the guest's PC")
	host.blood_bank.lights_left = 0.05
	await wait_until(func() -> bool: return not guest.blood_bank.lights_on(), 5.0)
	assert_false(host.blood_bank.lights_on(), "off by itself at the host")
	assert_false(guest.blood_bank.lights_on(), "and off on the guest's PC too")
	assert_false(guest.lamps[0].visible, "its lamps dark again")


func test_a_spoiled_bag_and_a_taken_one_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.blood_bank.bags[0].warmth = 0.999
	host.blood_bank.bags[0].is_cold = func(_at: Vector3) -> bool: return false
	host.blood_bank.bags[1].take()
	host.blood_bank.bags_taken += 1
	await wait_until(func() -> bool: return guest.blood_bank.bags[0].spoiled and not guest.blood_bank.bags[1].visible,
		5.0)
	assert_true(guest.blood_bank.bags[0].spoiled, "spoiled on the guest's PC too")
	assert_eq(guest.blood_bank.bags_spoiled(), 1)
	assert_false(guest.blood_bank.bags[1].visible, "the taken bag gone there too")
	assert_eq(guest.blood_bank.bags_taken, 1)
	assert_eq(guest.blood_bank.bags_cold(), BankBlood.BAGS - 2, "the planilla counts the same cold bags")


func test_a_vampire_hides_on_every_pc_and_a_guest_flashlight_shines_at_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	var robber := host.robbers[0]
	robber.lit()
	var index := host.robbers.find(robber)
	await wait_until(func() -> bool: return guest.robbers[index].is_hiding(), 5.0)
	assert_true(guest.robbers[index].is_hiding(), "hiding under his cape on the guest's PC too")
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.act("belt_flashlight", guest_cop)
	var copy := _copy_of(host)
	await wait_until(func() -> bool: return copy.belt.flashlight.is_on, 5.0)
	assert_true(copy.belt.flashlight.is_on, "the host's copy of the guest's cop lights its flashlight too")
	assert_not_null(BankBlood.beam_of(copy), "so the host's vampires see its beam")
