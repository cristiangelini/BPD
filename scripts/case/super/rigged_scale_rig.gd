extends SupermarketRig

## The scale that adds up (allanamiento-super.md, "La balanza que suma"): Don Ofertón has a magic screw in the produce
## stand's scale, and every apple weighs more than it does. The screw, the "How to weigh more" manual and the golden
## screwdriver are hidden; the scale on the stand shows what lies on it plus 300 g, and empty it shows 300 g. The first
## time something is weighed is the clue. Three tomatoes lie by it to try. Every number here is (propuesta).

const TOMATO_MODEL := preload("res://assets/models/food_tomato.glb")
const TOMATO_SIZE := Vector3(0.14, 0.12, 0.13)
const TOMATO_KG := 0.2
## Where the tomatoes lie, on the scale's stool on both sides of the pan.
const TOMATOES_AT: Array[Vector3] = [Vector3(0.33, 0, -0.07), Vector3(0.33, 0, 0.08), Vector3(-0.33, 0, 0)]
## The scale's pan on the stand (the model's scale, turned with the stand), the box over it that weighs what lies there,
## and what it adds.
const PAN_AT := Supermarket.PRODUCE_AT + Vector3(0, 0.9, -1.3)
const PAN_SIZE := Vector3(0.35, 0.08, 0.3)
const WEIGHS := Vector3(0.45, 0.5, 0.4)
const EXTRA_KG := 0.3

var readout: Label3D
var tomatoes: Array[Grabbable] = []
## What it shows (with the extra), and whether it weighed something yet.
var shown_kg := EXTRA_KG
var weighed := false
var _pan: Area3D


func setup(place: Supermarket) -> void:
	super.setup(place)
	store._solid(PAN_AT + Vector3(0, PAN_SIZE.y / 2, 0), PAN_SIZE)
	_pan = Area3D.new()
	_pan.name = "ScalePan"
	_pan.collision_layer = 0
	_pan.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = WEIGHS
	shape.shape = box
	_pan.add_child(shape)
	store.add_child(_pan)
	_pan.position = PAN_AT + Vector3(0, PAN_SIZE.y + WEIGHS.y / 2, 0)
	readout = Label3D.new()
	readout.name = "ScaleReadout"
	readout.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	readout.pixel_size = 0.003
	readout.outline_size = 8
	readout.modulate = Color(0.5, 1, 0.5)
	store.add_child(readout)
	readout.position = PAN_AT + Vector3(0.2, 0.35, 0)
	for i in TOMATOES_AT.size():
		var tomato := ClubEvidence.make_item("Tomato%d" % i, TOMATO_MODEL, TOMATO_SIZE, TOMATO_KG)
		store.add_child(tomato)
		tomato.position = PAN_AT + TOMATOES_AT[i] + Vector3.UP * (TOMATO_SIZE.y / 2 + 0.01)
		tomatoes.append(tomato)
	_show(0.0)


func _physics_process(_delta: float) -> void:
	var kg := 0.0
	for body in _pan.get_overlapping_bodies():
		if body is Grabbable and not (body as Grabbable).is_held():
			kg += (body as RigidBody3D).mass
	_show(kg)
	if kg > 0.0 and not weighed:
		weighed = true
		store.raid.add_clue(tr("SUPER_SCALE_CLUE"))


## The scale's readout: what lies on it, 300 g more.
func _show(kg: float) -> void:
	shown_kg = kg + EXTRA_KG
	readout.text = tr("SUPER_SCALE_READOUT") % shown_kg
