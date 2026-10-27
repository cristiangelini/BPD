class_name RealSequinsRig
extends RinkRig

## The real sequins (allanamiento-pista.md, "Las lentejuelas de verdad"): Doña Pirueta sewed stolen diamonds onto her
## competition leotard and hid it. The leotard glints in colors where it lies, faintly, and brightly when it's under the
## mirror ball; the first time a cop sees it glint (within SEE_RANGE) it's the story's own clue, on the checklist.
## Meanwhile she wears another leotard, with dull sequins, and complains that "the good one is at the dry cleaner's"
## when a cop comes near. Every number here is (propuesta).

## How far from under the mirror ball the leotard glints brightly, and how bright it glints there and elsewhere.
const BALL_REACH := 8.0
const GLINT_UNDER := 2.5
const GLINT_FAR := 0.6
## How often the glint changes color.
const GLINT_EVERY := 0.2
const GLINT_COLORS: Array[Color] = [Color(1.0, 0.3, 0.6), Color(0.3, 0.7, 1.0), Color(1.0, 0.85, 0.3),
	Color(0.5, 1.0, 0.5), Color(1.0, 1.0, 1.0)]
const SEE_RANGE := 4.0
## How near a cop has to come for her to complain, and how long before she complains again.
const COMPLAIN_RANGE := 4.0
const COMPLAIN_EVERY := 30.0
## Her leotard's materials (modelgen's "pirueta_leotard" and "pirueta_sequin"), dull in this story.
const DULL_MATERIALS: Array[String] = ["pirueta_leotard", "pirueta_sequin"]

var glint: OmniLight3D
var seen := false
var complaints := 0
var dulled := 0
var _since_glint := 0.0
var _color := 0
var _since_complaint := COMPLAIN_EVERY


func setup(place: Rink) -> void:
	super.setup(place)
	glint = OmniLight3D.new()
	glint.omni_range = 1.6
	glint.position = Vector3.UP * 0.15
	rink.main.add_child(glint)
	_dull(rink.owner_npc)
	_show_glint()


## Her own leotard with dull sequins: grey-pink, no shine.
func _dull(node: Node) -> void:
	for child in node.get_children():
		_dull(child)
	var look := node as MeshInstance3D
	if look == null or look.mesh == null:
		return
	for i in look.mesh.get_surface_count():
		var material := look.mesh.surface_get_material(i)
		if material == null or not DULL_MATERIALS.has(material.resource_name):
			continue
		var dull := StandardMaterial3D.new()
		dull.albedo_color = Color(0.55, 0.42, 0.48)
		dull.roughness = 1.0
		look.set_surface_override_material(i, dull)
		dulled += 1


func _physics_process(delta: float) -> void:
	_since_glint += delta
	if _since_glint >= GLINT_EVERY:
		_since_glint = 0.0
		_color += 1
		_show_glint()
	if not seen and _a_cop_within(rink.main.global_position, SEE_RANGE):
		seen = true
		rink.raid.add_clue(tr("CLUE_SEQUIN_GLINTS"))
	_since_complaint += delta
	if _since_complaint >= COMPLAIN_EVERY and _a_cop_within(rink.owner_npc.global_position, COMPLAIN_RANGE):
		complain()


func _show_glint() -> void:
	if not is_instance_valid(rink.main):
		return
	glint.light_color = GLINT_COLORS[_color % GLINT_COLORS.size()]
	glint.light_energy = GLINT_UNDER if under_the_ball() else GLINT_FAR


## Whether the leotard lies under the mirror ball, where it catches its light.
func under_the_ball() -> bool:
	var ball := rink.mirror_ball.global_position
	var at := rink.main.global_position
	return Vector2(at.x - ball.x, at.z - ball.z).length() <= BALL_REACH


## "The good one is at the dry cleaner's."
func complain() -> void:
	_since_complaint = 0.0
	complaints += 1
	rink.owner_npc._say("PIRUETA_DRY_CLEANER", 4.0)


func _a_cop_within(at: Vector3, distance: float) -> bool:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(at) <= distance:
			return true
	return false
