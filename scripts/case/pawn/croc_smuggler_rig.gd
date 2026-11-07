class_name CrocSmugglerRig
extends PawnRig

## The smuggler crocodile (allanamiento-empenos.md, "El cocodrilo contrabandista"): the shop's stuffed crocodile is
## full of smuggled jewels (14 kg, the main evidence, in plain sight with its "Not for sale" tag); the customs label
## and the ship's receipt are hidden. It tinkles when it moves (the first time, that's the story's clue), and moved
## hard it drops a pearl from its mouth, once (only to look at: it rolls nowhere, so every PC shows it the same).
## Online the host's crocodile decides, and the guests' follow (net_state). Every number here is (propuesta).

const CROC_SCENE := preload("res://scenes/props/jewel_croc.tscn")
const PEARL_MODEL := preload("res://assets/models/pawn_pearl.glb")
const TINKLE_SPEED := 0.6
const TINKLE_AGAIN := 3.0
const DROP_SPEED := 3.0

var croc: Evidence
var tinkled := false
var pearl: Node3D
var _tinkle_wait := 0.0


func setup(place: PawnShop) -> void:
	super.setup(place)
	for part in place.croc_parts:
		part.free()
	place.croc_parts.clear()
	croc = CROC_SCENE.instantiate()
	croc.position = PawnShop.CROC_AT + Vector3.UP * 0.01
	place.add_child(croc)
	place.main = croc
	var tag := Label3D.new()
	tag.name = "NotForSale"
	tag.text = "PAWN_CROC_TAG"
	tag.font_size = 32
	tag.pixel_size = 0.004
	tag.outline_size = 8
	tag.modulate = Color(1.0, 0.85, 0.3)
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.position = Vector3(0.8, 0.75, 0)
	croc.add_child(tag)


## Something inside tinkles; the first time, it's a clue.
func tinkle() -> void:
	_tinkle_wait = TINKLE_AGAIN
	shop.say_at(croc.global_position + Vector3.UP * 0.8, "PAWN_CROC_TINKLES")
	if not tinkled:
		tinkled = true
		shop.raid.add_clue(tr("CLUE_CROC_SMUGGLER"))


## A pearl falls from its mouth, once.
func drop_pearl() -> void:
	if pearl:
		return
	pearl = PEARL_MODEL.instantiate()
	pearl.name = "Pearl"
	shop.add_child(pearl)
	var mouth := shop.to_local(croc.to_global(Vector3(1.1, 0, 0)))
	pearl.position = Vector3(mouth.x, PawnShop.FLOOR_TOP, mouth.z)
	shop.raid.add_clue(tr("CLUE_CROC_PEARL"))


func _physics_process(delta: float) -> void:
	if not is_instance_valid(croc):
		return
	_tinkle_wait -= delta
	var speed := croc.linear_velocity.length()
	if not multiplayer.is_server():
		return
	if _tinkle_wait <= 0.0 and (speed > TINKLE_SPEED or croc.is_held()):
		tinkle()
	if speed > DROP_SPEED:
		drop_pearl()


func net_state() -> Variant:
	return [tinkled, pearl != null]


func apply_net_state(state: Variant) -> void:
	if state[0] and not tinkled:
		tinkle()
	if state[1]:
		drop_pearl()
