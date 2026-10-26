class_name ShredderRig
extends InsuranceRig

## The shredder (seguros.md, "La trituradora"): the office shreds every claim it doesn't want to pay. The box of the
## claims still waiting their turn is the main evidence (4 kg), hidden with a bag of shredded paper and Mirta's
## "shred everything" order. The story's own clue: a trail of paper bits leading to the box, whoever carried it lost
## some. And the archive's shredder eats whatever is put on it, evidence included: the main box in it loses the case.
## Every number here is (propuesta).

signal ate(body: RigidBody3D)

const F := InsuranceOffice.FLOOR_TOP
## The trail of paper bits to each hiding spot, from a point in plain view (the last point is the spot itself, on the
## floor), along aisles and through doors.
const TRAILS := {
	"under_reception_desk": [Vector3(-2.6, F, 6.0), Vector3(-6.0, F, 6.4)],
	"under_cubicle_desk": [Vector3(-7.6, F, -0.6), Vector3(-9.4, F, -0.6), Vector3(-9.4, F, -2.2)],
	"on_cubicle_desk": [Vector3(1.6, F, 4.55), Vector3(-0.95, F, 4.55), Vector3(-0.95, F, 3.1)],
	"under_meeting_table": [Vector3(2.8, F, 3.0), Vector3(4.6, F, 3.0), Vector3(6.6, F, 3.0)],
	"in_meeting_cabinet": [Vector3(2.8, F, 3.0), Vector3(4.6, F, 3.0), Vector3(5.4, F, 4.4), Vector3(9.8, F, 4.3)],
	"in_fridge": [Vector3(4.4, F, -1.2), Vector3(9.9, F, -1.8)],
	"in_kitchen_bin": [Vector3(7.2, F, -1.6), Vector3(4.9, F, 0.3)],
	"in_boss_safe": [Vector3(6.0, F, -1.6), Vector3(6.0, F, -3.4), Vector3(5.2, F, -6.9)],
	"in_filing_cabinet": [Vector3(6.0, F, -1.6), Vector3(6.0, F, -3.4), Vector3(10.1, F, -7.0)],
	"behind_printer": [Vector3(0.0, F, -3.6), Vector3(1.3, F, -6.0), Vector3(0.6, F, -7.6)],
	"in_archive_box": [Vector3(-8.0, F, -3.4), Vector3(-8.0, F, -4.9), Vector3(-9.2, F, -5.1)],
	"on_archive_shelf": [Vector3(-8.0, F, -3.4), Vector3(-8.0, F, -4.9), Vector3(-6.0, F, -7.0)],
}
const BIT_EVERY := 0.2
## The shredder's mouth on its top: anything let go on it that weighs up to EATS_KG goes in.
const MOUTH := Vector3(0.4, 0.25, 0.5)
const EATS_KG := 6.0
## Where what it ate goes: out of the world, kept so nothing points at a freed node.
const GONE := Vector3(0, -50, 0)

var trail: ClueSpot
var bits := 0
var eaten: Array[RigidBody3D] = []
var mouth: Area3D
var _grr: Label3D


func setup(place: InsuranceOffice) -> void:
	super.setup(place)
	var spot_id: String = InsuranceOffice.SPOTS[place.hidden_spots[0]].id
	var path: Array = TRAILS[spot_id]
	_lay_trail(place, path)
	trail = ClueSpot.new()
	trail.prompt = "PROMPT_PAPER_TRAIL"
	trail.text = tr("CLUE_PAPER_TRAIL")
	trail.size = Vector3(0.8, 0.02, 0.8)
	trail.position = (path[0] as Vector3) + Vector3(0, 0.01, 0)
	place.add_child(trail)
	trail.read.connect(place.raid.add_clue)
	mouth = Area3D.new()
	mouth.collision_layer = 0
	mouth.collision_mask = 4
	mouth.position = InsuranceOffice.SHREDDER_AT + Vector3(0, 0.8 + MOUTH.y / 2, 0)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = MOUTH
	shape.shape = box
	mouth.add_child(shape)
	place.add_child(mouth)
	_grr = Label3D.new()
	_grr.text = "SHREDDER_GRR"
	_grr.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_grr.pixel_size = 0.004
	_grr.font_size = 40
	_grr.outline_size = 10
	_grr.position = InsuranceOffice.SHREDDER_AT + Vector3(0, 1.3, 0)
	_grr.hide()
	place.add_child(_grr)


## White paper bits every BIT_EVERY along the path, two at a time, a little to each side.
func _lay_trail(place: Node3D, path: Array) -> void:
	var look := StandardMaterial3D.new()
	look.albedo_color = Color(0.96, 0.96, 0.92)
	var bit := BoxMesh.new()
	bit.size = Vector3(0.12, 0.004, 0.04)
	var rng := RandomNumberGenerator.new()
	rng.seed = office.case_seed * 19 + 7
	for i in path.size() - 1:
		var from: Vector3 = path[i]
		var to: Vector3 = path[i + 1]
		var along := (to - from).normalized()
		var side := Vector3(-along.z, 0, along.x)
		for s in int(from.distance_to(to) / BIT_EVERY) * 2:
			var piece := MeshInstance3D.new()
			piece.mesh = bit
			piece.material_override = look
			piece.position = from + along * (s / 2) * BIT_EVERY + side * rng.randf_range(-0.2, 0.2) + Vector3.UP * 0.003
			piece.rotation.y = rng.randf() * TAU
			place.add_child(piece)
			bits += 1


func _physics_process(_delta: float) -> void:
	if not mouth:
		return
	for body in mouth.get_overlapping_bodies():
		var thing := body as RigidBody3D
		if thing and not thing.freeze and thing.mass <= EATS_KG and not (thing is Grabbable and (thing as Grabbable).is_held()):
			eat(thing)


## The shredder eats `thing`: it's gone for good, and if it was the main evidence the case is lost.
func eat(thing: RigidBody3D) -> void:
	eaten.append(thing)
	thing.freeze = true
	thing.collision_layer = 0
	thing.collision_mask = 0
	thing.hide()
	thing.global_position = GONE
	_grr.show()
	get_tree().create_timer(2.0).timeout.connect(_grr.hide)
	ate.emit(thing)
	if thing == office.main:
		office.raid.fail("CASE_FAILED_SHREDDED")
