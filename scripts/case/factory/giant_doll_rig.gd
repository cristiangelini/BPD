class_name GiantDollRig
extends FactoryRig

## The giant doll (fabrica.md, "El muñeco gigante"): the jeweler's safe that was stolen hides inside the giant parade
## doll in the storeroom. The safe (25 kg, two cops) can't be reached until the zipper on the doll's back is opened. A
## trail of footprints goes from the storeroom door to the doll's back and doesn't come back: looking at it is the
## story's own clue. The parade plan and the safe's key are hidden. Every number here is (propuesta).

const SAFE_SCENE := preload("res://scenes/props/jewelers_safe.tscn")
## Where the doll stands in the storeroom, facing the doors (its back to the racks).
const DOLL_AT := Vector3(10.5, DollFactory.FLOOR_TOP, 5.0)
const DOLL_TURN := -PI / 2
## The footprints, from the storeroom door around the crate to the doll's back.
const TRAIL: Array[Vector3] = [
	Vector3(5.6, DollFactory.FLOOR_TOP, 5.6), Vector3(9.0, DollFactory.FLOOR_TOP, 4.0),
	Vector3(11.8, DollFactory.FLOOR_TOP, 4.2), Vector3(11.8, DollFactory.FLOOR_TOP, 5.0),
]
const STEP := 0.45

var doll: GiantDoll
var safe: Evidence
var steps: ClueSpot
var footprints := 0


func setup(place: DollFactory) -> void:
	super.setup(place)
	doll = GiantDoll.new()
	doll.position = DOLL_AT
	doll.rotation.y = DOLL_TURN
	place.add_child(doll)
	safe = SAFE_SCENE.instantiate()
	safe.position = DOLL_AT + Vector3(0, 0.25, 0)
	# Out of reach (and of sight for the cops' aim) until the dress opens.
	safe.collision_layer = 0
	place.add_child(safe)
	place.main = safe
	doll.opened.connect(func(_cop: Cop) -> void: safe.collision_layer = 4)
	_lay_trail(place)
	steps = ClueSpot.new()
	steps.prompt = "PROMPT_GIANT_STEPS"
	steps.text = tr("CLUE_GIANT_STEPS")
	steps.size = Vector3(0.8, 0.02, 0.8)
	steps.position = TRAIL[0] + Vector3(0.4, 0.01, 0)
	place.add_child(steps)
	steps.read.connect(place.raid.add_clue)


## Dark shoe prints every STEP along TRAIL, left and right.
func _lay_trail(place: Node3D) -> void:
	var look := StandardMaterial3D.new()
	look.albedo_color = Color(0.25, 0.22, 0.2, 0.8)
	look.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var shoe := BoxMesh.new()
	shoe.size = Vector3(0.1, 0.004, 0.24)
	for i in TRAIL.size() - 1:
		var from := TRAIL[i]
		var to := TRAIL[i + 1]
		var count := int(from.distance_to(to) / STEP)
		var along := (to - from).normalized()
		var side := Vector3(-along.z, 0, along.x)
		for s in count:
			var print_ := MeshInstance3D.new()
			print_.mesh = shoe
			print_.material_override = look
			print_.position = from + along * s * STEP + side * (0.1 if (footprints % 2) == 0 else -0.1) + Vector3.UP * 0.003
			print_.rotation.y = atan2(along.x, along.z)
			place.add_child(print_)
			footprints += 1
