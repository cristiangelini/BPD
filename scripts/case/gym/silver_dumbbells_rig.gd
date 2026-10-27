class_name SilverDumbbellsRig
extends GymRaidRig

## The silver dumbbells (allanamiento-gimnasio.md, "Las pesas rellenas de plata"): the profe hides dirty money in hollow
## weights and the "members" carry it out in their bags. The giant dumbbell full of bills is hidden; one of the rack's
## dumbbells (drawn with the seed) jingles with coins when it hits the floor, the story's own clue (on the checklist the
## first time). Every other dumbbell that falls off the rack bursts open once: half of them (drawn with the seed) spill
## toy bills, a false lead, and the rest are just empty. Every number here is (propuesta).

signal jingled(at: Vector3)

const TOY_BILLS := 6
const BILL_SIZE := Vector3(0.16, 0.004, 0.08)
const BILL_LIFE := 10.0
const TOY_BILL := Color(0.95, 0.6, 0.8)

## The rack dumbbell with the coins, and which of the others spill toy bills.
var coins := -1
var toys: Array[int] = []
var jingles := 0
## Dumbbells already burst open; and the ones lying on the floor right now.
var opened := {}
var _down := {}


func setup(place: GymRaid) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["silver dumbbells", place.case_seed])
	coins = rng.randi_range(0, place.dumbbells.size() - 1)
	for i in place.dumbbells.size():
		if i != coins and rng.randf() < 0.5:
			toys.append(i)


func _physics_process(_delta: float) -> void:
	for i in gym.dumbbells.size():
		var dumbbell := gym.dumbbells[i]
		if not is_instance_valid(dumbbell):
			continue
		var down := gym.to_local(dumbbell.global_position).y < GymRaid.DUMBBELL_DOWN
		if down and not _down.has(i):
			landed(i)
		if down:
			_down[i] = true
		else:
			_down.erase(i)


## Dumbbell `index` just hit the floor.
func landed(index: int) -> void:
	var at := gym.dumbbells[index].global_position
	if index == coins:
		jingles += 1
		gym.raid.float_label("♫ clinc, clinc ♫", at + Vector3.UP * 0.6, Color(0.85, 0.85, 0.9))
		if jingles == 1:
			gym.raid.add_clue(tr("CLUE_DUMBBELL_COINS"))
		jingled.emit(at)
		return
	if opened.has(index):
		return
	opened[index] = true
	if toys.has(index):
		_spill(at, index)


## A burst dumbbell spills toy bills (pink, "Banco de Juguete") that fade after a while.
func _spill(at: Vector3, index: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([gym.case_seed, index])
	var material := StandardMaterial3D.new()
	material.albedo_color = TOY_BILL
	for i in TOY_BILLS:
		var bill := RigidBody3D.new()
		bill.collision_layer = 0
		bill.collision_mask = 1
		bill.mass = 0.01
		bill.linear_damp = 3.0
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = BILL_SIZE
		shape.shape = box
		bill.add_child(shape)
		var look := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = BILL_SIZE
		mesh.material = material
		look.mesh = mesh
		bill.add_child(look)
		gym.add_child(bill)
		bill.global_position = at + Vector3.UP * 0.2
		bill.linear_velocity = Vector3(rng.randf_range(-1.5, 1.5), rng.randf_range(2.0, 3.5), rng.randf_range(-1.5, 1.5))
		get_tree().create_timer(BILL_LIFE).timeout.connect(bill.queue_free)
	gym.raid.float_label(tr("GYM_TOY_BILLS"), at + Vector3.UP * 0.8, TOY_BILL)
