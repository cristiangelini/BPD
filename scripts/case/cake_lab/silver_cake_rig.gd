class_name SilverCakeRig
extends CakeLabRig

## The silver-filled cake (laboratorio.md, "El pastel relleno de plata"): the lab bakes banknotes into a three-tier cake
## (12 kg, fragile) and sells it as a "special order". The story's own clues: one of Pocha's samples has the corner
## of a banknote in it, and switching on a giant mixer makes it spit banknotes all over the kitchen (the first time it
## goes on the checklist). Every number here is (propuesta).

signal spat(at: Vector3)

const BILLS := 14
const BILL_SIZE := Vector3(0.16, 0.004, 0.08)
const BILL_LIFE := 10.0
const BILL := Color(0.42, 0.7, 0.42)
## The switch on each mixer's head, in the mixer's space.
const SWITCH_AT := Vector3(0.0, 1.2, 0.25)

var switches: Array[PushButton] = []
var spits := 0


func setup(place: CakeLab) -> void:
	super.setup(place)
	place.pocha.sample_hint = "HINT_SAMPLE_BILL"
	for at: Vector3 in CakeLab.MIXERS:
		var button := PushButton.new()
		button.prompt = "PROMPT_MIXER_SWITCH"
		button.color = Color(0.95, 0.85, 0.2)
		button.position = at + SWITCH_AT
		place.add_child(button)
		button.pressed.connect(func(_cop: Cop) -> void: spit(at))
		switches.append(button)


## The mixer at `at` whirs and spits banknotes out of its bowl; the first time, it's a clue.
func spit(at: Vector3) -> void:
	spits += 1
	var bowl := at + Vector3(0, 0.7, 0.05)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([lab.case_seed, spits])
	var material := StandardMaterial3D.new()
	material.albedo_color = BILL
	for i in BILLS:
		var bill := RigidBody3D.new()
		bill.collision_layer = 0
		bill.collision_mask = 1
		bill.mass = 0.01
		bill.linear_damp = 3.0
		bill.angular_damp = 1.0
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
		lab.add_child(bill)
		bill.global_position = bowl
		bill.linear_velocity = Vector3(rng.randf_range(-2.5, 2.5), rng.randf_range(3.0, 5.0), rng.randf_range(-2.5, 2.5))
		bill.angular_velocity = Vector3(rng.randf_range(-6.0, 6.0), rng.randf_range(-6.0, 6.0), rng.randf_range(-6.0, 6.0))
		get_tree().create_timer(BILL_LIFE).timeout.connect(bill.queue_free)
	if spits == 1:
		lab.raid.add_clue(tr("CLUE_MIXER_BILLS"))
	spat.emit(bowl)
