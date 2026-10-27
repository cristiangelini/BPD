class_name IceSurpriseRig
extends RinkRig

## The ice with a surprise (allanamiento-pista.md, "El hielo con sorpresa"): Doña Pirueta froze the stolen jewels in a
## block of ice, too heavy for one cop. The block glitters, and a cop this close to it sees it, the story's own clue (on
## the checklist the first time); a trail of puddles goes from where the block is to the office. Every number here is
## (propuesta).

const GLITTER_RANGE := 3.0
const GLITTER_EVERY := 2.0
## A puddle every PUDDLE_STEP meters from the block to the office door.
const PUDDLE_STEP := 1.4
const PUDDLE := Color(0.45, 0.65, 0.85, 0.7)

var glitters := 0
var puddles: Array[MeshInstance3D] = []
var _since := GLITTER_EVERY


func setup(place: Rink) -> void:
	super.setup(place)
	var glow := OmniLight3D.new()
	glow.light_color = Color(0.6, 0.9, 1.0)
	glow.light_energy = 1.2
	glow.omni_range = 1.5
	glow.position = Vector3(0, 0.5, 0)
	rink.main.add_child(glow)
	var from := rink.to_local(rink.main.global_position)
	var to := Vector3(Rink.OFFICE_DOOR_X, 0, Rink.BACK_Z - 0.6)
	from.y = 0.0
	var steps := floori(from.distance_to(to) / PUDDLE_STEP)
	for i in range(1, steps + 1):
		var at := from.lerp(to, float(i) / (steps + 1))
		puddles.append(_puddle(Vector3(at.x, Rink.FLOOR_TOP + 0.005, at.z), 0.25 + (i % 3) * 0.08))


func _puddle(at: Vector3, radius: float) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.01
	look.mesh = disc
	var wet := StandardMaterial3D.new()
	wet.albedo_color = PUDDLE
	wet.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wet.roughness = 0.05
	look.material_override = wet
	look.position = at
	rink.add_child(look)
	return look


func _physics_process(delta: float) -> void:
	_since += delta
	if _since < GLITTER_EVERY or not is_instance_valid(rink.main):
		return
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(rink.main.global_position) <= GLITTER_RANGE:
			glitter()
			return


## The block glitters at a cop nearby; the first time it's a clue.
func glitter() -> void:
	_since = 0.0
	glitters += 1
	rink.raid.float_label(tr("RINK_GLITTER"), rink.main.global_position + Vector3.UP * 0.8, Color(0.7, 0.95, 1.0))
	if glitters == 1:
		rink.raid.add_clue(tr("CLUE_ICE_GLITTERS"))
