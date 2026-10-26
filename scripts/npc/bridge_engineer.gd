class_name BridgeEngineer
extends CharacterBody3D

## Engineer Remache of Pegote Hermanos (politico-puente.md, step 5, decision 178): hard hat, vest and clipboard, in the
## crowd on the west bank watching his bridge. He kept half of the materials, and it shows: sawdust on his hands, a
## nervous line every time something breaks (`nervous`, from BridgeRemache) and every WATCH_EVERY seconds a look at his
## watch. E on him: one of his excuses. Cuffed, he protests, and E walks him to the patrol car (OwnerEscort). Every
## number here is (propuesta).

## A cop cuffed him (the handcuffs, on every PC).
signal cuffed_now(engineer: BridgeEngineer)

const MODEL := preload("res://assets/models/npc_ingeniero.glb")
const SAY_TIME := 4.0
## Where the hands are, on the model (it faces +Z): the sawdust shows there, bigger than life.
const HANDS: Array[Vector3] = [Vector3(0.5, 0.55, 0.1), Vector3(-0.5, 0.55, 0.1)]
const SAWDUST := Color(0.87, 0.72, 0.45)
const WATCH_EVERY := 25.0
const TALKS := 3
const NERVES := 3

## A guest's copy (NpcSync): the host's decides whether the cuffs closed (step 6).
var follower := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _cuffed_left := 0.0
var _watch_left := WATCH_EVERY
var _talk := 0
var _nerve := 0


func _ready() -> void:
	add_to_group("bridge_engineers")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	_model.name = "Model"
	# The models face +Z; he faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	_sawdust()
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)


## Sawdust on both hands, a few light flakes bigger than life.
func _sawdust() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = SAWDUST
	for hand: Vector3 in HANDS:
		for i in 3:
			var flake := MeshInstance3D.new()
			flake.name = "Sawdust"
			var box := BoxMesh.new()
			box.size = Vector3(0.09, 0.05, 0.09)
			flake.mesh = box
			flake.material_override = material
			flake.position = hand + Vector3((i - 1) * 0.05, (i % 2) * 0.05, (i - 1) * -0.04)
			flake.rotation.y = i * 0.7
			_model.add_child(flake)


func has_sawdust() -> bool:
	return _model.has_node("Sawdust")


## Something broke on the bridge: a nervous line, unless he's busy being taken away.
func nervous() -> void:
	if not _free():
		return
	say("BRIDGE_ENGINEER_NERVOUS_%d" % (_nerve % NERVES + 1))
	_nerve += 1


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_ENGINEER"


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	say("BRIDGE_ENGINEER_TALK_%d" % (_talk % TALKS + 1))
	_talk += 1


## The handcuffs: he protests, and the case hears it.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	if follower:
		return
	say("BRIDGE_ENGINEER_CUFFED")
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## Walked to the patrol car and sitting in it.
func in_car() -> bool:
	var escort := OwnerEscort.of(self)
	return escort != null and escort.in_car


## Neither cuffed, nor being walked to the patrol car, nor in it.
func _free() -> bool:
	var escort := OwnerEscort.of(self)
	return not is_cuffed() and not (escort and (escort.escorted_by or escort.in_car))


## What the escort calls (OwnerEscort): a line for `seconds`; he has no complaint meter.
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


## What a guest's copy needs besides where he is and what he says (NpcSync): cuffed.
func net_state() -> Array:
	return [is_cuffed()]


func apply_net_state(state: Variant) -> void:
	_cuffed_left = Handcuffs.SECONDS if state[0] else 0.0


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if follower:
		return
	_watch_left -= delta
	if _watch_left <= 0.0:
		_watch_left = WATCH_EVERY
		if _free() and _bubble_left <= 0.0:
			say("BRIDGE_ENGINEER_WATCH")


func _process(delta: float) -> void:
	# The escort turns him with his +Z ahead.
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and (escort.escorted_by or escort.in_car) else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
