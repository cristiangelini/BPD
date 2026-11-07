class_name GiantCarrotsRig
extends FarmRaidRig

## The giant carrots (allanamiento-granja.md, "Las zanahorias gigantes"): Don Florencio wins the fair's prizes with
## fertilizer stolen from the laboratory. In the garden there's a carrot taller than a cop; two cops tugging together
## pull it out, and its root still wears the laboratory's label (the story's own clue). Once out it's a heavy thing to
## carry, and it leaves a hole. Every number here is (propuesta).

## Where it grows in the garden (the farm's space), on its second row.
const CARROT_AT := Vector3(9.2, 0, 13.8)
const MODEL := preload("res://assets/models/giant_carrot.glb")
const RADIUS := 0.3
const HEIGHT := 1.9
const UNDERGROUND := 0.8
const MASS := 30.0
const HOLE := Color(0.25, 0.17, 0.1)

var carrot: GiantCarrot
var model: Node3D
## The carrot once out, a heavy thing to carry: made with the farm on every PC (so it's the same prop online),
## hidden and out of reach until it's pulled.
var loose: Grabbable
var pulled := false


func setup(place: FarmRaid) -> void:
	super.setup(place)
	carrot = GiantCarrot.new()
	carrot.name = "GiantCarrot"
	carrot.position = CARROT_AT + Vector3.UP * (FarmRaid.GROUND + HEIGHT / 2)
	carrot.add_child(_shape(HEIGHT))
	model = MODEL.instantiate()
	model.position = Vector3.DOWN * HEIGHT / 2
	carrot.add_child(model)
	place.add_child(carrot)
	carrot.tugged.connect(func(cop: Cop) -> void:
		farm.raid.float_label(tr("FARM_CARROT_STUCK"), cop.global_position + Vector3.UP * 2.0, Color.WHITE))
	carrot.pulled_out.connect(func(_cops: Array[Cop]) -> void: pull_out())
	_make_loose()


## The pulled-out carrot, lying on its side beside the hole, its leaves toward the garden's east; hidden for now.
func _make_loose() -> void:
	loose = Grabbable.new()
	loose.name = "LooseCarrot"
	loose.mass = MASS
	loose.collision_layer = 0
	loose.collision_mask = 15
	loose.freeze = true
	loose.visible = false
	var length := HEIGHT + UNDERGROUND
	var shape := _shape(length)
	shape.position = Vector3.UP * (length / 2 - UNDERGROUND)
	loose.add_child(shape)
	loose.add_child(MODEL.instantiate())
	loose.add_child(_label())
	loose.rotation.z = -PI / 2
	loose.position = CARROT_AT + Vector3(UNDERGROUND, FarmRaid.GROUND + RADIUS + 0.05, 0.6)
	farm.add_child(loose)


## The laboratory's label on the root, shown once it's pulled out (just over it, as the carrot lies on its side).
func _label() -> Label3D:
	var label := Label3D.new()
	label.text = tr("FARM_CARROT_LABEL")
	label.modulate = Color(0.1, 0.1, 0.1)
	label.outline_modulate = Color(0.95, 0.82, 0.12)
	label.outline_size = 24
	label.font_size = 32
	label.pixel_size = 0.004
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(-0.5, -0.4, 0)
	return label


func _shape(height: float) -> CollisionShape3D:
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = RADIUS
	cylinder.height = height
	shape.shape = cylinder
	return shape


## Out it comes, once: the clue, a hole where it was and the carrot lying beside it, root and all.
func pull_out() -> void:
	if pulled:
		return
	pulled = true
	carrot.out = true
	if multiplayer.is_server():
		farm.raid.add_clue(tr("CLUE_GIANT_CARROT"))
		farm.raid.float_label(tr("FARM_CARROT_OUT"), carrot.global_position + Vector3.UP * 1.5, Color(1.0, 0.55, 0.1))
	var hole := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = RADIUS + 0.1
	disc.bottom_radius = RADIUS + 0.1
	disc.height = 0.01
	var material := StandardMaterial3D.new()
	material.albedo_color = HOLE
	disc.material = material
	hole.mesh = disc
	hole.position = CARROT_AT + Vector3.UP * (FarmRaid.GROUND + 0.01)
	farm.add_child(hole)
	loose.visible = true
	loose.collision_layer = 4
	# On a guest PropSync moves its frozen copy.
	if multiplayer.is_server():
		loose.freeze = false
	carrot.queue_free()


func net_state() -> Variant:
	return pulled


func apply_net_state(state: Variant) -> void:
	if state:
		pull_out()
