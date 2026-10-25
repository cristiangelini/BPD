extends GutTest

## The guard dog's jailbreak online (fuga-perro.md, "Online"): Mordisco, his friends, the key off his collar and the
## food follow the host.

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
	jail.variant = "dog"
	return jail


func test_the_guest_sees_his_friends_and_the_key_come_off() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	assert_not_null(guest_level.dog, "the guest has him too")
	assert_eq(guest_level.dog_food.size(), host_level.dog_food.size(), "and the same food")
	var host_cop := OnlinePcs.own_cop(pcs[0])
	host_level.dog.befriend(host_cop, GuardDog.FRIEND)
	host_level.dog.use(host_cop)
	assert_false(host_level.dog.key_on_collar)
	await wait_until(func() -> bool: return not guest_level.dog.key_on_collar, 5.0)
	assert_false(guest_level.dog.key_on_collar, "off his collar on the guest")
	assert_eq(guest_level.dog.friends.get(host_cop.uniform, 0.0), GuardDog.FRIEND)


func test_food_he_eats_goes_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	var food: DogFood = host_level.dog_food[0]
	var name := food.name
	host_level.dog.eat(food)
	await wait_until(func() -> bool: return guest_level.get_node_or_null(NodePath(name)) == null, 5.0)
	assert_null(guest_level.get_node_or_null(NodePath(name)), "gone on the guest too")
