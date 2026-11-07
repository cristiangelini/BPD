class_name FalseFittingRoomRig
extends CostumeRig

## The fitting room with a false back (allanamiento-disfraces.md, "El probador con fondo falso"): Don Fantoche sews
## fake brand costumes behind the mirror of fitting room 3. The room has an "out of order" sign and the customers
## skip it. Inside it, a cop hears a sewing machine behind the mirror every SEW_EVERY seconds (the story's clue); E
## on the mirror lifts it like a garage door and shows the sewing machine (15 kg, the main evidence) behind it. The
## fake labels and the costume pattern are hidden. Every number here is (propuesta).

const MACHINE_SCENE := preload("res://scenes/props/sewing_machine.tscn")
const BACK_MODEL := preload("res://assets/models/false_back.glb")
## Fitting room 3, its false back across it and the machine in the gap behind.
const ROOM := 2
const BACK_X := -11.1
const BACK_SIZE := Vector3(0.08, 2.4, 2.8)
const MACHINE_AT := Vector3(-11.55, CostumeShop.FLOOR_TOP, 2.5)
## How high the mirror goes when it's pushed, and how long it takes.
const LIFT := 2.0
const LIFT_TIME := 0.8
const SEW_EVERY := 4.0
const SEW_TIME := 2.0
## What Don Fantoche adds to his complaint if he sees it open.
const SEEN := 10.0

var machine: Evidence
var back: StaticBody3D
var is_open := false
var _sew_left := 0.0
var _heard := false
var _bubble: Label3D


func setup(place: CostumeShop) -> void:
	super.setup(place)
	place.closed_fitting = ROOM
	var z := CostumeShop.FITTING_Z[ROOM]
	place._label("COSTUME_OUT_OF_ORDER", Vector3(CostumeShop.FITTING_X + 0.3, 1.6, z), 40, PI / 2)
	machine = MACHINE_SCENE.instantiate()
	machine.position = Vector3(MACHINE_AT.x, MACHINE_AT.y + 0.01, z)
	place.add_child(machine)
	place.main = machine
	var panel := FalseBack.new()
	panel.rig = self
	back = panel
	back.name = "FalseBack"
	back.position = Vector3(BACK_X, CostumeShop.FLOOR_TOP, z)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = BACK_SIZE
	shape.shape = box
	shape.position.y = BACK_SIZE.y / 2
	back.add_child(shape)
	back.add_child(BACK_MODEL.instantiate())
	place.add_child(back)
	_bubble = Label3D.new()
	_bubble.position = Vector3(BACK_X + 0.8, 1.9, z)
	_bubble.no_depth_test = true
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.hide()
	place.add_child(_bubble)


## A cop pushed the mirror: up it goes, and Don Fantoche complains if he sees it.
func open() -> void:
	if is_open:
		return
	is_open = true
	_bubble.hide()
	create_tween().tween_property(back, "position:y", CostumeShop.FLOOR_TOP + LIFT, LIFT_TIME)
	if shop.owner_boss:
		shop.owner_boss.saw(back.global_position + Vector3.UP, SEEN, "FANTOCHE_SAW")


func _physics_process(delta: float) -> void:
	if is_open or not shop.cop_in_fitting(ROOM):
		_sew_left = 0.0
		return
	_sew_left -= delta
	if _sew_left > 0.0:
		return
	_sew_left = SEW_EVERY
	_bubble.text = "SEWING_SOUND"
	_bubble.show()
	get_tree().create_timer(SEW_TIME).timeout.connect(_bubble.hide)
	if not _heard:
		_heard = true
		shop.raid.add_clue(tr("CLUE_SEWING_SOUND"))


## The mirror at the back of fitting room 3: what a cop aims at and pushes with E.
class FalseBack:
	extends StaticBody3D

	var rig: FalseFittingRoomRig

	func prompt_key(_cop: Cop) -> String:
		return "" if rig.is_open else "PROMPT_FALSE_BACK"

	func use(_cop: Cop) -> void:
		rig.open()
