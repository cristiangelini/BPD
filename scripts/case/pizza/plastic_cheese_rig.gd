class_name PlasticCheeseRig
extends PizzaRaidRig

## The plastic cheese (allanamiento-pizzeria.md, "El queso de plástico"): Don Muzza makes his muzzarella out of plastic.
## The sample pizza on the counter stretches its cheese up to STRETCH meters without breaking, the story's own clue:
## pulled further, the cheese snaps it back onto its board. And the slices bounce like balls: thrown, they jump all
## over the dining room. Every number here is (propuesta).

const SAMPLE_MODEL := preload("res://assets/models/sample_pizza.glb")
## On the counter, between the stacks of plates and the tower of boxes.
const SAMPLE_AT := Vector3(-3.4, PizzaRaid.FLOOR_TOP + 1.03, 3.2)
const STRETCH := 3.0
const BOUNCE := 0.9
const CHEESE := Color(0.96, 0.78, 0.25)
const BOING := Color(1.0, 0.9, 0.3)

var sample: ClueNote
## The string of cheese from the board to the sample pizza.
var strand: MeshInstance3D
var snaps := 0


func setup(place: PizzaRaid) -> void:
	super.setup(place)
	sample = clue_item("SamplePizza", SAMPLE_MODEL, Vector3(0.32, 0.05, 0.32), SAMPLE_AT, "PROMPT_SAMPLE_PIZZA",
		"CLUE_SAMPLE_PIZZA")
	var bouncy := PhysicsMaterial.new()
	bouncy.bounce = BOUNCE
	bouncy.friction = 0.3
	for slice: Grabbable in pizzeria.slices:
		slice.physics_material_override = bouncy
	var string := CylinderMesh.new()
	string.top_radius = 0.008
	string.bottom_radius = 0.008
	string.height = 1.0
	string.radial_segments = 5
	var material := StandardMaterial3D.new()
	material.albedo_color = CHEESE
	string.material = material
	strand = MeshInstance3D.new()
	strand.mesh = string
	strand.visible = false
	pizzeria.add_child(strand)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(sample):
		strand.hide()
		return
	var from := pizzeria.to_global(SAMPLE_AT)
	var to := sample.global_position
	var length := from.distance_to(to)
	strand.visible = length > 0.15
	if strand.visible:
		strand.global_position = (from + to) / 2
		strand.look_at(to, Vector3.UP if absf((to - from).normalized().y) < 0.95 else Vector3.FORWARD)
		strand.rotate_object_local(Vector3.RIGHT, PI / 2)
		strand.scale = Vector3(1, length, 1)
	# The host decides when the cheese snaps it back; PropSync shows the guests where the pizza is.
	if multiplayer.is_server() and length > STRETCH:
		snap_back()


## Pulled past STRETCH, the cheese pulls the sample pizza out of the cop's hands and back onto its board.
func snap_back() -> void:
	snaps += 1
	for cop: Cop in pizzeria.get_tree().get_nodes_in_group("cops"):
		if cop.get_node("Grabber").held == sample:
			cop.get_node("Grabber").release()
			cop.show_hint("HINT_CHEESE_SNAP")
	sample.linear_velocity = Vector3.ZERO
	sample.angular_velocity = Vector3.ZERO
	sample.global_transform = pizzeria.global_transform * Transform3D(Basis.IDENTITY, SAMPLE_AT)
	pizzeria.raid.float_label(tr("CHEESE_BOING"), sample.global_position + Vector3.UP * 0.3, BOING)
