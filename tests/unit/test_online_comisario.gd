extends GutTest

## The comisario online (docs/diseno/online.md, "Qué se sincroniza"): whoever talks to him, every PC hears the tip,
## also a guest who joins after it.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const HOUSE := preload("res://scenes/levels/grandpa_house.tscn")
const SEED := 4242

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var house: Node3D = HOUSE.instantiate()
		house.case_seed = SEED
		return house)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _raid(net: Node) -> RaidCase:
	return OnlinePcs.level(net).raid


func _comisario(net: Node) -> Comisario:
	return (OnlinePcs.level(net).get_node("City") as City).comisario


func test_a_guest_talking_to_the_comisario_gives_the_tip_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	assert_false(_raid(pcs[0]).tip_given, "the case waits for the comisario")
	OnlinePcs.own_cop(pcs[1]).act("use", _comisario(pcs[1]))
	await wait_until(func() -> bool: return _raid(pcs[0]).tip_given and _raid(pcs[1]).tip_given, 5.0)
	assert_true(_raid(pcs[0]).tip_given, "the host's case is on")
	assert_true(_raid(pcs[1]).tip_given, "and the guest's")
	assert_eq(_raid(pcs[0]).car.locked_hint, "", "the patrol car opens")


func test_a_guest_who_missed_the_comisario_gets_the_tip_from_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	# As if the host's cop had heard him before the guest joined: nobody told the guest's PC.
	_raid(pcs[0]).give_tip()
	await wait_until(func() -> bool: return _raid(pcs[1]).tip_given, 5.0)
	assert_true(_raid(pcs[1]).tip_given, "the host's case tells the guest's")
	assert_eq(_raid(pcs[1]).car.locked_hint, "")
