class_name GoldenEggsRig
extends FarmRaidRig

## The golden eggs (allanamiento-granja.md, "Los huevos de oro"): Don Florencio sells lead eggs painted gold as the eggs
## of a "magic hen". Among the real eggs in the hen house's run lies one of lead: dropped on the ground it goes "clonc"
## and doesn't break, the story's own clue (on the checklist the first time). Every number here is (propuesta).

signal clonked(at: Vector3)

const EGG_MODEL := preload("res://assets/models/farm_egg.glb")
const EGG_KG := 0.4
## Falling faster than this when it lands is a "clonc".
const CLONK_SPEED := 2.0

var lead_egg: Grabbable
var clonks := 0
var _falling := 0.0


func setup(place: FarmRaid) -> void:
	super.setup(place)
	lead_egg = Grabbable.new()
	lead_egg.name = "LeadEgg"
	lead_egg.mass = EGG_KG
	lead_egg.collision_layer = 4
	lead_egg.collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.06, 0.08, 0.06)
	shape.shape = box
	lead_egg.add_child(shape)
	var look: Node3D = EGG_MODEL.instantiate()
	look.position.y = -0.04
	lead_egg.add_child(look)
	var run := FarmRaid.COOP_RUN
	lead_egg.position = Vector3(run.get_center().x + 0.4, FarmRaid.GROUND + 0.05, run.get_center().y)
	place.add_child(lead_egg)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(lead_egg):
		return
	var fall := -lead_egg.linear_velocity.y
	if _falling > CLONK_SPEED and fall < 0.5 and not lead_egg.is_held():
		clonk()
	_falling = fall


## The lead egg hit the ground: "clonc", and it's still whole.
func clonk() -> void:
	clonks += 1
	var at := lead_egg.global_position
	farm.raid.float_label(tr("FARM_CLONK"), at + Vector3.UP * 0.4, Color(0.85, 0.85, 0.9))
	if clonks == 1:
		farm.raid.add_clue(tr("CLUE_LEAD_EGG"))
	clonked.emit(at)
