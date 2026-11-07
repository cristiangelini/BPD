class_name WardrobeHotelRig
extends FurnitureRig

## The wardrobe hotel (allanamiento-muebleria.md, "El ropero hotel"): Don Cajón rents his showroom wardrobes out for
## the night. The guest book is hidden with the pillow with drool and the toothbrush. One of the two wardrobes (drawn
## with the seed) has its doors shut and snores: a cop near it when it does hears it, the story's own clue (on the
## checklist the first time). Opening it (E) lets out a guest in pyjamas who walks out to the street yawning. Every
## number here is (propuesta).

signal guest_left

const CLOSED_MODEL := preload("res://assets/models/closed_wardrobe.glb")
const GUEST_MODEL := preload("res://assets/models/npc_pajama_guest.glb")
## It snores every SNORE_EVERY seconds while a cop is within SNORE_RANGE; one within HEAR_RANGE hears it.
const SNORE_EVERY := 5.0
const SNORE_RANGE := 8.0
const HEAR_RANGE := 3.5
const GUEST_SPEED := 1.2
## The guest's way out, in the store's space, after stepping out of the wardrobe.
const WAY_OUT: Array[Vector3] = [Vector3(-4.0, FurnitureStore.FLOOR_TOP, 0.0), Vector3(0.0, FurnitureStore.FLOOR_TOP, 10.0),
	Vector3(0.0, FurnitureStore.FLOOR_TOP, 16.0)]
const SLEEPY := Color(0.6, 0.75, 1.0)

## The snoring wardrobe (an index of FurnitureStore.WARDROBES), whether a cop heard it, and the guest once out.
var hotel := -1
var heard := false
var guest: Node3D
var _snore_left := SNORE_EVERY
var _path: Array[Vector3] = []
var _closed: Node3D


func setup(place: FurnitureStore) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["wardrobe hotel", place.case_seed])
	hotel = rng.randi_range(0, FurnitureStore.WARDROBES.size() - 1)
	var wardrobe := place.wardrobes[hotel]
	wardrobe.shut = true
	_show_open(false)
	wardrobe.opened.connect(open)


func _physics_process(delta: float) -> void:
	if guest:
		_walk_guest(delta)
	if not store.wardrobes[hotel].shut:
		return
	_snore_left -= delta
	if _snore_left > 0.0:
		return
	_snore_left = SNORE_EVERY
	var at := store.wardrobes[hotel].global_position
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(at) <= SNORE_RANGE:
			snore()
			return


## A snore out of the shut wardrobe; whoever is close enough hears it, and the first time that's the clue.
func snore() -> void:
	var wardrobe := store.wardrobes[hotel]
	store.raid.float_label(tr("FURNITURE_SNORE"), wardrobe.global_position + Vector3.UP * 2.4, SLEEPY)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(wardrobe.global_position) <= HEAR_RANGE:
			cop.show_hint("HINT_WARDROBE_SNORES")
			if not heard:
				heard = true
				store.raid.add_clue(tr("CLUE_SNORING_WARDROBE"))


## `cop` opened the shut wardrobe: its doors swing open and the guest in pyjamas steps out and goes home.
func open(_cop: Cop) -> void:
	_show_open(true)
	var wardrobe := store.wardrobes[hotel]
	guest = Node3D.new()
	guest.name = "PajamaGuest"
	guest.add_child(GUEST_MODEL.instantiate())
	store.add_child(guest)
	guest.global_position = wardrobe.to_global(Vector3(0, 0.02, 1.0))
	_path.assign(WAY_OUT.map(func(at: Vector3) -> Vector3: return store.to_global(at)))
	store.raid.float_label(tr("FURNITURE_GUEST"), guest.global_position + Vector3.UP * 2.2, SLEEPY)


## The guest shuffles along his way out and is gone once in the street.
func _walk_guest(delta: float) -> void:
	var to := _path[0] - guest.global_position
	to.y = 0.0
	if to.length() < 0.2:
		_path.remove_at(0)
		if _path.is_empty():
			guest.queue_free()
			guest = null
			guest_left.emit()
		return
	guest.look_at(guest.global_position - to, Vector3.UP)
	guest.global_position += to.normalized() * minf(GUEST_SPEED * delta, to.length())


## The wardrobe's own model with its doors open, or the shut one in its place.
func _show_open(open_doors: bool) -> void:
	var wardrobe := store.wardrobes[hotel]
	for child in wardrobe.get_children():
		if child is Node3D and not child is CollisionShape3D and child != _closed:
			(child as Node3D).visible = open_doors
	if open_doors:
		if _closed:
			wardrobe.remove_child(_closed)
			_closed.queue_free()
			_closed = null
		return
	_closed = CLOSED_MODEL.instantiate()
	_closed.name = "Closed"
	wardrobe.add_child(_closed)
