class_name ConvoyTraits
extends RefCounted

## What sets a clown of the convoy apart (control-payasos.md, "Cómo es", step 2): every clown car is the same, so the
## clues are on the clown at the wheel: the color of his wig, his nose and his gloves, and how his car's horn sounds.
## Unlike the circus's clowns, it all shows. Under the makeup, whether he wears glasses: his license's photo is without
## makeup, and the wanted one's license is someone else's (control-payasos.md, step 5). The keys are the texts that
## name them. Pure data. Every number here is (propuesta).

const WIGS := {"COLOR_ORANGE": Color(0.95, 0.5, 0.1), "COLOR_GREEN": Color(0.2, 0.75, 0.25),
	"COLOR_BLUE": Color(0.35, 0.7, 0.95), "COLOR_VIOLET": Color(0.55, 0.3, 0.8), "COLOR_PINK": Color(0.95, 0.5, 0.75)}
const NOSES := {"COLOR_RED": Color(0.9, 0.12, 0.12), "COLOR_BLUE": Color(0.25, 0.5, 0.95),
	"COLOR_YELLOW": Color(0.95, 0.85, 0.15)}
const GLOVES := {"COLOR_WHITE": Color(0.96, 0.96, 0.94), "COLOR_YELLOW": Color(0.95, 0.85, 0.15),
	"COLOR_LIME": Color(0.6, 0.9, 0.2)}
## How each car's horn sounds: CONVOY_HORN_0 to _3.
const HORNS := 4
## What's in a clown car's trunk, by weight; the real safe is only in the wanted one's (WantedPlan).
const TRUNKS := {"balloons": 5, "pies": 3, "prop_safe": 2}


static func draw(rng: RandomNumberGenerator) -> Dictionary:
	return {
		"wig": WIGS.keys()[rng.randi() % WIGS.size()],
		"nose": NOSES.keys()[rng.randi() % NOSES.size()],
		"gloves": GLOVES.keys()[rng.randi() % GLOVES.size()],
		"horn": rng.randi() % HORNS,
		"glasses": rng.randf() < 0.5,
	}


static func trunk(rng: RandomNumberGenerator) -> String:
	var roll := rng.randi_range(1, TRUNKS.values().reduce(func(a: int, b: int) -> int: return a + b))
	for kind: String in TRUNKS:
		roll -= TRUNKS[kind]
		if roll <= 0:
			return kind
	return "balloons"


## Paints a clown model (npc_payaso) with these traits, made up: his own hair and glasses don't show.
static func dress(model: Node3D, traits: Dictionary) -> void:
	show_face(model, traits, false)
	if traits.is_empty():
		return
	_tint(model, "wig", WIGS[traits.wig])
	_tint(model, "nose", NOSES[traits.nose])
	_tint(model, "gloves", GLOVES[traits.gloves])


## The color a part of a dressed model shows, for tests; null if it isn't tinted.
static func tint_of(model: Node3D, id: String) -> Variant:
	var part := model.find_child(id, true, false)
	if not part:
		return null
	for mesh: MeshInstance3D in part.find_children("*", "MeshInstance3D", true, false):
		if mesh.material_override is StandardMaterial3D:
			return (mesh.material_override as StandardMaterial3D).albedo_color
	return null


## With the makeup scrubbed off, his face shows: his glasses if he wears them.
static func show_face(model: Node3D, traits: Dictionary, clean: bool) -> void:
	for id: String in ["makeup", "glasses", "hair"]:
		var part := model.find_child(id, true, false) as Node3D
		if part:
			match id:
				"makeup":
					part.visible = not clean
				"glasses":
					part.visible = clean and traits.get("glasses", false)
				"hair":
					part.visible = false


static func horn_text(traits: Dictionary) -> String:
	return "CONVOY_HORN_%d" % traits.get("horn", 0)


static func _tint(model: Node3D, id: String, color: Color) -> void:
	var part := model.find_child(id, true, false)
	if not part:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh: MeshInstance3D in part.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = material
