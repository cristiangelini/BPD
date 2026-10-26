class_name InsuredPaintingRig
extends InsuranceRig

## The insured painting (seguros.md, "El cuadro asegurado"): the office says its famous painting was stolen and cashed
## the insurance, but it's still here, hung among 7 copies the owners had painted. The real one is the main evidence
## (6 kg, fragile); the copies are fragile goods, a fine each if they break. Only the real one has the painter's
## signature upside down, and grabbing it says so. The painting's policy and the box of paint tubes are hidden. The
## story's own clue: in the meeting room, the clean mark of a frame on a dusty wall, where it hung before "the theft".
## The paintings hang still on their walls until a cop grabs one. Every number here is (propuesta).

const COPY_SCENE := preload("res://scenes/props/painting_copy.tscn")
const REAL_SCENE := preload("res://scenes/props/painting_real.tscn")
## Where the eight paintings hang, and which way each one faces (its turn around Y).
const WALLS: Array[Vector3] = [
	Vector3(-4.5, 1.7, InsuranceOffice.RECEPTION_Z + 0.105), Vector3(-5.2, 1.8, InsuranceOffice.RECEPTION_Z - 0.105),
	Vector3(InsuranceOffice.HALF_X - 0.105, 1.6, 2.0), Vector3(7.5, 1.7, -InsuranceOffice.HALF_Z + 0.105),
	Vector3(8.5, 1.8, InsuranceOffice.OFFICE_FRONT_Z + 0.105), Vector3(-InsuranceOffice.HALF_X + 0.105, 1.8, 0.7),
	Vector3(-6.5, 1.8, InsuranceOffice.ARCHIVE_FRONT_Z + 0.105), Vector3(-2.5, 1.8, -InsuranceOffice.HALF_Z + 0.105),
]
const TURNS: Array[float] = [0.0, PI, -PI / 2, 0.0, 0.0, PI / 2, 0.0, 0.0]
## The clean mark on the meeting room's back wall, in the gap between two of the company's paintings.
const MARK_AT := Vector3(6.6, 1.8, InsuranceOffice.MEETING_BACK_Z + 0.08)

var real: Evidence
var paintings: Array[RigidBody3D] = []
var copies: Array[Ornament] = []
var mark: ClueSpot


func setup(place: InsuranceOffice) -> void:
	super.setup(place)
	var real_at := real_spot(place.case_seed)
	for i in WALLS.size():
		var painting: RigidBody3D
		if i == real_at:
			real = REAL_SCENE.instantiate()
			painting = real
		else:
			painting = COPY_SCENE.instantiate()
		painting.position = WALLS[i]
		painting.rotation.y = TURNS[i]
		painting.freeze = true
		place.add_child(painting)
		paintings.append(painting)
		if painting is Ornament:
			(painting as Ornament).broken.connect(place._on_fragile_broken)
			copies.append(painting)
	place.main = real
	var clean := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.82, 0.62, 0.004)
	var look := StandardMaterial3D.new()
	look.albedo_color = Color(0.98, 0.98, 0.96)
	box.material = look
	clean.mesh = box
	clean.position = MARK_AT
	place.add_child(clean)
	var dust := StandardMaterial3D.new()
	dust.albedo_color = Color(0.42, 0.4, 0.35)
	for side in 4:
		var edge := MeshInstance3D.new()
		var line := BoxMesh.new()
		line.size = Vector3(0.9, 0.04, 0.004) if side < 2 else Vector3(0.04, 0.7, 0.004)
		line.material = dust
		edge.mesh = line
		edge.position = MARK_AT + ([Vector3(0, 0.33, 0), Vector3(0, -0.33, 0), Vector3(-0.43, 0, 0), Vector3(0.43, 0, 0)][side] as Vector3)
		place.add_child(edge)
	mark = ClueSpot.new()
	mark.prompt = "PROMPT_FRAME_MARK"
	mark.text = tr("CLUE_FRAME_MARK")
	mark.size = Vector3(0.9, 0.7, 0.05)
	mark.position = MARK_AT
	place.add_child(mark)
	mark.read.connect(place.raid.add_clue)


## Which of the eight paintings is the real one, from the seed.
static func real_spot(case_seed: int) -> int:
	return case_seed % WALLS.size()


## A painting comes off its wall when a cop grabs it.
func _physics_process(_delta: float) -> void:
	for painting in paintings:
		if is_instance_valid(painting) and painting.freeze and (painting as Grabbable).is_held():
			painting.freeze = false
