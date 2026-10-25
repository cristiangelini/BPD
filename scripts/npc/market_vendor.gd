class_name MarketVendor
extends CharacterBody3D

## A vendor behind a market stall's counter (politico-mercado.md, step 1): the puestero in an apron of their stall's
## color. E on them: they praise what they sell. Cuffed, they complain, and E walks them to the patrol car
## (OwnerEscort, step 5). One of them is the spiteful one who put the laxative in the samples (MarketSpite); some have
## white powder on their hands (`powder`).

## A cop cuffed them (the handcuffs, on every PC).
signal cuffed_now(vendor: MarketVendor)

const MODEL := preload("res://assets/models/npc_puestero.glb")
const SAY_TIME := 4.0
## Where the hands are, on the model (it faces +Z).
const HANDS: Array[Vector3] = [Vector3(0.5, 0.55, 0.1), Vector3(-0.5, 0.55, 0.1)]
## Where they touched their face and cap with powdery hands: these show over the counter, the hands don't.
const SMUDGES: Array[Vector3] = [Vector3(0.13, 1.22, 0.2), Vector3(-0.06, 1.51, 0.1)]

## A guest's copy (NpcSync): the host's decides whether the cuffs closed (step 7).
var follower := false
## What the stall sells (MarketLevel.KINDS).
var kind := "fruit"
var apron := Color(0.25, 0.55, 0.35)
## The one who put the laxative in (step 5).
var spiteful := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _cuffed_left := 0.0


func _ready() -> void:
	add_to_group("market_vendors")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	_model = MODEL.instantiate()
	_model.name = "Model"
	# The models face +Z; the vendor faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	var material := StandardMaterial3D.new()
	material.albedo_color = apron
	for mesh in _model.find_child("apron", true, false).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)


## White powder on both hands, a cheek and the cap, bigger than life so it can be seen across the counter
## (flour, sugar... or laxative).
func powder() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.97, 0.97, 0.95)
	for at: Vector3 in HANDS + SMUDGES:
		var puff := MeshInstance3D.new()
		puff.name = "Powder"
		var ball := SphereMesh.new()
		ball.radius = 0.1
		ball.height = 0.16
		puff.mesh = ball
		puff.material_override = material
		puff.position = at
		if SMUDGES.has(at):
			puff.scale = Vector3(0.9, 0.6, 0.5)
		_model.add_child(puff)


func has_powder() -> bool:
	return _model.has_node("Powder")


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_VENDOR"


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	say("VENDOR_%s" % kind.to_upper())


## The handcuffs: complains, and the case hears it (MarketSpite).
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	if follower:
		return
	say("VENDOR_SPITE_CUFFED" if spiteful else "VENDOR_CUFFED")
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## Walked to the patrol car and sitting in it.
func in_car() -> bool:
	var escort := OwnerEscort.of(self)
	return escort != null and escort.in_car


## What the escort calls (OwnerEscort): a line for `seconds`; vendors have no complaint meter.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key)
	_bubble_left = seconds


func _raise(_points: float) -> void:
	pass


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## What a guest's copy needs besides where they are and what they say (NpcSync): cuffed.
func net_state() -> Array:
	return [is_cuffed()]


func apply_net_state(state: Variant) -> void:
	_cuffed_left = Handcuffs.SECONDS if state[0] else 0.0


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)


func _process(delta: float) -> void:
	# The escort turns them with their +Z ahead.
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and (escort.escorted_by or escort.in_car) else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
