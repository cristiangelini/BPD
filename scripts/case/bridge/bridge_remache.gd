class_name BridgeRemache
extends Node

## Engineer Remache and the crowd (politico-puente.md, step 5, decision 178): FANS neighbors stand on the west bank
## beside the ramp watching the bridge, and Remache stands among them in a spot drawn by the seed. Every time something
## breaks he gets nervous (BridgeEngineer.nervous). At the builders' pickup, the invoices on the tailgate and the tarp
## with the steel beams under it (BridgeClue). Cuffed, E walks him to the patrol car (OwnerEscort) and he's `jailed`;
## cuffing a neighbor only makes them protest. Every number here is (propuesta).

signal found_clue(kind: String)
signal jailed

const INVOICES_MODEL := preload("res://assets/models/bridge_invoices.glb")
const TARP_MODEL := preload("res://assets/models/bridge_tarp.glb")
const BEAMS_MODEL := preload("res://assets/models/steel_beams.glb")
const FANS := 13
## The crowd's spots, in the park's space: rows north of the west ramp, between the stand and the canal's wall.
const CROWD_X: Array[float] = [-16.5, -15.0, -13.5, -12.0]
const CROWD_Z: Array[float] = [-3.0, -4.3, -5.6, -6.9]
const JITTER := 0.3
## Where they look: the middle of the bridge.
const LOOK_AT := Vector3(0, 0, 0)
## The invoices on the pickup's tailgate (its back is at -Z), and the tarp along its west side.
const INVOICES_AT := Vector3(BridgePark.VAN_AT.x, 0.8, BridgePark.VAN_AT.z - BridgePark.VAN_SIZE.z / 2 - 0.06)
const TARP_AT := Vector3(BridgePark.VAN_AT.x - 2.6, 0, BridgePark.VAN_AT.z + 0.5)
const TARP_SIZE := Vector3(3.3, 0.8, 1.1)

var park: BridgePark
var engineer: BridgeEngineer
var fans: Array[RallyFan] = []
var invoices: BridgeClue
var beams: BridgeClue
var is_jailed := false


func setup(the_park: BridgePark, breaks: BridgeBreaks, case_seed: int) -> void:
	park = the_park
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["bridge remache", case_seed])
	var spots: Array[Vector3] = []
	for z in CROWD_Z:
		for x in CROWD_X:
			spots.append(Vector3(x + rng.randf_range(-JITTER, JITTER), 0.05, z + rng.randf_range(-JITTER, JITTER)))
	for i in range(spots.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := spots[i]
		spots[i] = spots[j]
		spots[j] = swap
	engineer = BridgeEngineer.new()
	engineer.name = "Engineer"
	_stand(engineer, spots[0])
	var escort := OwnerEscort.attach(engineer, park.car)
	escort.in_car_hint = "HINT_ENGINEER_IN_CAR"
	escort.boarded.connect(_on_boarded)
	for i in FANS:
		var fan := RallyFan.new()
		fan.name = "Fan%d" % i
		fan.look = RallyCrowd.LOOKS[rng.randi() % RallyCrowd.LOOKS.size()]
		_stand(fan, spots[i + 1])
		fans.append(fan)
	breaks.broke.connect(func(_kind: String, _index: int) -> void: engineer.nervous())
	invoices = _clue("invoices", INVOICES_AT, Vector3(0.32, 0.42, 0.08), "PROMPT_READ_INVOICES", "HINT_BRIDGE_INVOICES")
	var folder: Node3D = INVOICES_MODEL.instantiate()
	# The model faces +Z; the tailgate faces -Z.
	folder.rotation.y = PI
	invoices.add_child(folder)
	var label := Label3D.new()
	label.text = "BRIDGE_INVOICES_LABEL"
	label.font_size = 28
	label.pixel_size = 0.004
	label.outline_size = 6
	label.modulate = Color(0.1, 0.1, 0.1)
	label.outline_modulate = Color(1, 1, 1)
	label.position = Vector3(0, 0.3, -0.05)
	label.rotation.y = PI
	invoices.add_child(label)
	beams = _clue("beams", TARP_AT + Vector3(0, TARP_SIZE.y / 2, 0), TARP_SIZE, "PROMPT_LIFT_TARP", "HINT_BRIDGE_BEAMS")
	beams.found_prompt = "PROMPT_LOOK_BEAMS"
	# Long side along the pickup.
	beams.rotation.y = PI / 2
	var loot: Node3D = BEAMS_MODEL.instantiate()
	loot.position.y = -TARP_SIZE.y / 2
	beams.add_child(loot)
	var tarp: Node3D = TARP_MODEL.instantiate()
	tarp.name = "Tarp"
	tarp.position.y = -TARP_SIZE.y / 2
	beams.add_child(tarp)
	beams.cover = tarp


func _stand(npc: CharacterBody3D, at: Vector3) -> void:
	npc.position = at
	park.add_child(npc)
	# They face -Z: turned to look at the bridge.
	var to := LOOK_AT - at
	npc.rotation.y = atan2(-to.x, -to.z)


func _clue(kind: String, at: Vector3, size: Vector3, prompt: String, hint: String) -> BridgeClue:
	var clue := BridgeClue.new()
	clue.name = kind.capitalize()
	clue.kind = kind
	clue.prompt = prompt
	clue.found_prompt = prompt
	clue.hint = hint
	clue.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	clue.add_child(shape)
	park.add_child(clue)
	clue.found_now.connect(func(found: BridgeClue) -> void: found_clue.emit(found.kind))
	return clue


func _on_boarded() -> void:
	is_jailed = true
	jailed.emit()


## Neither cuffed, nor being walked to the patrol car, nor in it.
func loose() -> bool:
	var escort := OwnerEscort.of(engineer)
	return not engineer.is_cuffed() and not (escort and (escort.escorted_by or escort.in_car))
