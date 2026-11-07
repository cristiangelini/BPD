class_name StuffedSofasRig
extends FurnitureRig

## The stuffed sofas (allanamiento-muebleria.md, "Los sillones rellenos"): Don Cajón sews the money from a till nobody
## knows about into his sofas' cushions. The cushion full of bills is hidden with the other till's book and the
## upholsterer's needle; one of the two sofas (drawn with the seed) crunches like paper when a cop tries it, the story's
## own clue (on the checklist the first time), and toy bills fly out of it every time. Every number here is
## (propuesta).

signal crunched(cop: Cop)

const BILL_MODEL := preload("res://assets/models/toy_bill.glb")
const BILLS := 6
## How fast the toy bills fly up, and how long they stay before they're gone.
const BILL_SPEED := 4.5
const BILL_LIFE := 6.0
const PAPER := Color(0.45, 0.8, 0.45)

## The sofa that crunches (an index of FurnitureStore.SOFAS), and how many times it did.
var crunchy := -1
var crunches := 0
var _rng := RandomNumberGenerator.new()


func setup(place: FurnitureStore) -> void:
	super.setup(place)
	_rng.seed = hash(["stuffed sofas", place.case_seed])
	crunchy = _rng.randi_range(0, FurnitureStore.SOFAS.size() - 1)
	place.sofas[crunchy].tried.connect(crunch)


## `cop` sat on the crunchy sofa: it crunches like paper, toy bills fly out and, the first time, the clue.
func crunch(cop: Cop) -> void:
	crunches += 1
	var sofa := store.sofas[crunchy]
	store.raid.float_label(tr("FURNITURE_CRUNCH"), sofa.global_position + Vector3.UP * 2.3, PAPER)
	cop.show_hint("HINT_SOFA_CRUNCH")
	if crunches == 1:
		store.raid.add_clue(tr("CLUE_SOFA_CRUNCH"))
	for i in BILLS:
		_fly_bill(sofa.to_global(Vector3(_rng.randf_range(-0.9, 0.9), 1.3, 0.3)))
	crunched.emit(cop)


## One toy bill flying up from `at`, fluttering down and gone after BILL_LIFE.
func _fly_bill(at: Vector3) -> void:
	var bill := RigidBody3D.new()
	bill.name = "ToyBill"
	bill.add_to_group("toy_bills")
	bill.collision_layer = 0
	bill.collision_mask = 1
	bill.mass = 0.01
	bill.linear_damp = 2.0
	bill.angular_damp = 1.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.24, 0.01, 0.11)
	shape.shape = box
	bill.add_child(shape)
	bill.add_child(BILL_MODEL.instantiate())
	store.add_child(bill)
	bill.global_position = at
	bill.linear_velocity = Vector3(_rng.randf_range(-1.5, 1.5), BILL_SPEED, _rng.randf_range(-1.5, 1.5))
	bill.angular_velocity = Vector3(_rng.randf_range(-6, 6), _rng.randf_range(-6, 6), _rng.randf_range(-6, 6))
	get_tree().create_timer(BILL_LIFE).timeout.connect(func() -> void:
		if is_instance_valid(bill):
			bill.queue_free())
