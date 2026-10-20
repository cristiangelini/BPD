class_name BonesRig
extends GroomerRig

## Bone smuggling (peluqueria.md, "Contrabando de huesos"): the dinosaur bones stolen from the museum are buried in
## the yard, under one of DIGS_AT patches of loose earth (drawn with the seed). Digging takes the yard shovel. The dogs
## smell them: every DIG_EVERY seconds a loose dog that isn't busy goes to dig, most of the times at the right patch (the story's own
## clue), and leaves dirt all over. The dig map is hidden like any extra. Every number here is (propuesta).

const BAG_SCENE := preload("res://scenes/props/bone_bag.tscn")
const SHOVEL_SCENE := preload("res://scenes/props/shovel.tscn")
const DIGS_AT: Array[Vector3] = [
	Vector3(-6.0, Groomer.GRASS_TOP, -4.0), Vector3(-3.5, Groomer.GRASS_TOP, -6.0), Vector3(-0.5, Groomer.GRASS_TOP, -4.5),
	Vector3(2.5, Groomer.GRASS_TOP, -3.2), Vector3(3.0, Groomer.GRASS_TOP, -6.2),
]
## The shovel lies on the grass by the yard door.
const SHOVEL_AT := Vector3(-1.8, Groomer.GRASS_TOP + 0.03, -2.8)
const DIG_EVERY := 15.0
## A dog digs at the right patch this share of the times.
const RIGHT_SHARE := 0.7
const DOG_DIG := 3.0
## A dog that doesn't get there in this long gives up.
const GIVE_UP := 12.0
const ARRIVE := 0.6
## A cop this close sees a dog dig.
const SEES := 6.0

var spots: Array[DigSpot] = []
var right_spot: DigSpot
var shovel: Shovel
var bag: Evidence
var digger: Dog
var dig_target: DigSpot
var digging := 0.0
var _dig_wait := DIG_EVERY
var _going := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: Groomer) -> void:
	super.setup(place)
	_rng.seed = place.case_seed * 7 + 5
	for at in DIGS_AT:
		var spot := DigSpot.new()
		spot.position = at
		place.add_child(spot)
		spots.append(spot)
	right_spot = spots[place.case_seed % spots.size()]
	bag = BAG_SCENE.instantiate()
	place.add_child(bag)
	right_spot.bury(bag)
	place.main = bag
	shovel = SHOVEL_SCENE.instantiate()
	shovel.position = SHOVEL_AT
	shovel.rotation.x = PI / 2
	place.add_child(shovel)


## Sends `dog` to dig at `spot`.
func send(dog: Dog, spot: DigSpot) -> void:
	digger = dog
	dig_target = spot
	_going = GIVE_UP
	var at := spot.global_position
	dog.areas = [Rect2(at.x - 0.2, at.z - 0.2, 0.4, 0.4)]
	dog._wander = 0.0


func _physics_process(delta: float) -> void:
	if digger:
		_dig(delta)
		return
	_dig_wait -= delta
	if _dig_wait > 0.0:
		return
	_dig_wait = DIG_EVERY
	var free := groomer.dogs.filter(func(dog: Dog) -> bool:
		return dog.state == Dog.State.WANDER and not dog.is_held() and not dog.caged and dog.flee <= 0.0)
	if free.is_empty():
		return
	var closed := spots.filter(func(spot: DigSpot) -> bool: return not spot.is_open())
	if closed.is_empty():
		return
	var spot: DigSpot = right_spot if not right_spot.is_open() and _rng.randf() < RIGHT_SHARE \
		else closed[_rng.randi() % closed.size()]
	send(free[_rng.randi() % free.size()], spot)


func _dig(delta: float) -> void:
	if digger.is_held() or dig_target.is_open() or digger.state != Dog.State.WANDER:
		_release()
		return
	if digging > 0.0:
		digging -= delta
		digger._model.position.y = absf(sin(digging * 18.0)) * 0.05
		if dig_target == right_spot and _cop_near(digger.global_position):
			groomer.raid.add_clue(tr("CLUE_BONES_DIGGING"))
		if digging <= 0.0:
			dig_target.dog_dug()
			_release()
		return
	_going -= delta
	var at := dig_target.global_position
	if Vector2(at.x - digger.global_position.x, at.z - digger.global_position.z).length() < ARRIVE:
		digging = DOG_DIG
		digger.caged = true
	elif _going <= 0.0:
		_release()


func _release() -> void:
	digger.caged = false
	digger.areas = Groomer.DOG_AREAS
	digger._model.position.y = 0.0
	digger = null
	dig_target = null
	digging = 0.0


func _cop_near(at: Vector3) -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(at) < SEES:
			return true
	return false
