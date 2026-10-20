extends GutTest

## The pet salon online (docs/diseno/online.md, "Qué se sincroniza"): Ramiro, the poodle lady and the human customers
## are run by the host and followed by the guests, like Marta in the bakery; the dogs are props the host moves.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const GROOMER := preload("res://scenes/levels/groomer.tscn")
const SEED := 4242

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_groomer)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_groomer() -> Node3D:
	var groomer: Node3D = GROOMER.instantiate()
	groomer.case_seed = SEED
	groomer.story_id = "human_salon"
	return groomer


func test_ramiro_moves_talks_and_gets_annoyed_the_same_for_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var on_host: DogGroomer = OnlinePcs.level(pcs[0]).ramiro
	var on_guest: DogGroomer = OnlinePcs.level(pcs[1]).ramiro
	assert_false(on_guest.is_physics_processing(), "the guest's Ramiro only follows")
	on_host.global_position += Vector3(0.5, 0, 0.3)
	var bubble: Label3D = on_host.get_node("Bubble")
	bubble.text = "NPC_NO_PHOTOS"
	bubble.show()
	on_host.complaint = 40.0
	# A loose dog can bark at him meanwhile on the host (+5, another line): the guest follows whatever the host has.
	var synced := func() -> bool:
		return on_guest.global_position.distance_to(on_host.global_position) < 0.05 \
			and on_guest.get_node("Bubble").text == bubble.text and absf(on_guest.complaint - on_host.complaint) < 0.01
	await wait_until(synced, 5.0)
	assert_almost_eq(on_guest.global_position, on_host.global_position, Vector3.ONE * 0.05)
	assert_eq(on_guest.get_node("Bubble").text, bubble.text)
	assert_almost_eq(on_guest.complaint, on_host.complaint, 0.01, "the complaint bar fills the same")
	assert_gte(on_host.complaint, 40.0)


func test_the_poodle_lady_says_the_same_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var on_host: PoodleLady = OnlinePcs.level(pcs[0]).lady
	var on_guest: PoodleLady = OnlinePcs.level(pcs[1]).lady
	on_host._say("LADY_ASK", 5.0)
	await wait_until(func() -> bool: return on_guest.get_node("Bubble").visible, 5.0)
	assert_eq(on_guest.get_node("Bubble").text, "LADY_ASK")


func test_only_the_host_brings_the_human_customer_and_the_guest_sees_the_towel() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_salon: Node3D = OnlinePcs.level(pcs[0])
	var guest_salon: Node3D = OnlinePcs.level(pcs[1])
	var customer: HumanCustomer = host_salon.rig.send_customer()
	await wait_until(func() -> bool: return not guest_salon.find_children("*", "HumanCustomer", true, false).is_empty(), 5.0)
	await wait_physics_frames(5)
	var copies := guest_salon.find_children("*", "HumanCustomer", true, false)
	assert_eq(copies.size(), 1, "one copy of the host's customer, none of the guest's own")
	var copy: HumanCustomer = copies[0]
	assert_eq(copy.look, customer.look, "dressed the same")
	assert_false(copy.is_physics_processing())
	customer.cover()
	await wait_until(func() -> bool: return copy.towel.visible, 5.0)
	assert_true(copy.towel.visible, "the towel Ramiro threw is on for the guest too")


func test_the_guests_dogs_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var dog_on_host: Dog = OnlinePcs.level(pcs[0]).dogs[0]
	var dog_on_guest: Dog = OnlinePcs.level(pcs[1]).dogs[0]
	assert_false(dog_on_guest.is_physics_processing(), "the guest's dog has no mind of its own")
	dog_on_host.global_position += Vector3(0.6, 0, 0)
	await wait_until(func() -> bool: return dog_on_guest.global_position.distance_to(dog_on_host.global_position) < 0.05, 5.0)
	assert_almost_eq(dog_on_guest.global_position, dog_on_host.global_position, Vector3.ONE * 0.05)
