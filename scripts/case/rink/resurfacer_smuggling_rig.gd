class_name ResurfacerSmugglingRig
extends RinkRig

## The smuggling resurfacer (allanamiento-pista.md, "La pulidora contrabandista"): Doña Pirueta fills the resurfacer's
## tank with stolen perfume and sells it by the bottle. While it runs it leaves a pink trail on the ice, the story's
## own clue (on the checklist the first time), and once every lap a bottle of perfume falls off it onto the ice. Every
## number here is (propuesta).

## A pink smear behind it every SMEAR_EVERY seconds while it runs; at most MAX_SMEARS, then the oldest goes.
const SMEAR_EVERY := 0.5
const MAX_SMEARS := 80
const SMEAR_BEHIND := 1.6
const PINK := Color(1.0, 0.3, 0.6, 0.85)
## A bottle falls BOTTLE_AT meters into each lap, at most MAX_BOTTLES in the whole raid.
const BOTTLE_AT := 12.0
const MAX_BOTTLES := 6
const BOTTLE_SCENE := preload("res://scenes/props/perfume_bottle.tscn")

var smears: Array[MeshInstance3D] = []
var bottles: Array[Grabbable] = []
var _since := SMEAR_EVERY
var _next_bottle := BOTTLE_AT


func setup(place: Rink) -> void:
	super.setup(place)
	_next_bottle = rink.resurfacer.along + BOTTLE_AT


func _physics_process(delta: float) -> void:
	var resurfacer := rink.resurfacer
	if not resurfacer.is_running():
		return
	_since += delta
	if _since >= SMEAR_EVERY:
		_since = 0.0
		smear()
	if resurfacer.along >= _next_bottle:
		_next_bottle += IceResurfacer.loop_length()
		drop_bottle()


## A pink smear on the ice behind the resurfacer; the first one is a clue.
func smear() -> void:
	var resurfacer := rink.resurfacer
	var at := resurfacer.position - resurfacer.basis.z * SMEAR_BEHIND
	var look := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.5
	disc.bottom_radius = 0.5
	disc.height = 0.01
	look.mesh = disc
	var pink := StandardMaterial3D.new()
	pink.albedo_color = PINK
	pink.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pink.roughness = 0.1
	look.material_override = pink
	look.position = Vector3(at.x, Rink.ICE_TOP + 0.006, at.z)
	look.scale = Vector3(1.0, 1.0, 0.6 + (smears.size() % 3) * 0.2)
	rink.add_child(look)
	smears.append(look)
	if smears.size() > MAX_SMEARS:
		smears.pop_front().queue_free()
	if smears.size() == 1:
		rink.raid.add_clue(tr("CLUE_PINK_TRAIL"))


## A bottle of perfume falls off the back of the resurfacer (the host drops it; online it's a synced prop, step 8).
func drop_bottle() -> Grabbable:
	if bottles.size() >= MAX_BOTTLES or not multiplayer.is_server():
		return null
	var resurfacer := rink.resurfacer
	var bottle: Grabbable = BOTTLE_SCENE.instantiate()
	var at := resurfacer.position - resurfacer.basis.z * (IceResurfacer.SIZE.z / 2 + 0.3)
	bottle.position = Vector3(at.x, Rink.ICE_TOP + 0.1, at.z)
	rink.add_child(bottle)
	bottles.append(bottle)
	rink.raid.float_label(tr("RINK_PERFUME_DROP"), rink.to_global(bottle.position + Vector3.UP * 0.6),
		Color(1.0, 0.55, 0.8))
	return bottle
