class_name GoldenSkateRig
extends RinkRig

## The golden skate (allanamiento-pista.md, "El patín de oro"): Doña Pirueta stole the championship's Golden Skate,
## painted it white and hid it among the rental skates on the rack. It weighs far more than a skate should: every time a
## cop picks it up it goes "clang", and the first time is the story's own clue (on the checklist). Its weight bends the
## rack's shelf down on its side. Every number here is (propuesta).

## How far down the shelf bends on the skate's side, and how long that bent half is.
const SAG := deg_to_rad(7.0)
const SAG_SIZE := Vector3(1.9, 0.05, 0.42)
## The skate stands in the gap between two rental skates, so its chipped gold shows.
const BETWEEN_SKATES := 0.4

var clangs := 0
var sag: MeshInstance3D
var _held := false


func setup(place: Rink) -> void:
	super.setup(place)
	rink.main.position.x += BETWEEN_SKATES
	sag = MeshInstance3D.new()
	var plank := BoxMesh.new()
	plank.size = SAG_SIZE
	sag.mesh = plank
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Rink.WOOD.darkened(0.3)
	sag.material_override = wood
	sag.position = Rink.RACK_AT + Vector3(-Rink.RACK_SIZE.x / 4, 0.9, 0)
	sag.rotation.z = SAG
	rink.add_child(sag)


## Online the host hears who picks it up, and the guests' rink shows the clang (Rink.net_state).
func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server() or not is_instance_valid(rink.main):
		return
	var held := not rink.main.holders.is_empty()
	if held and not _held:
		clang()
	_held = held


## A cop picked up the heavy skate: "clang". The first time it's a clue.
func clang() -> void:
	clangs += 1
	_show_clang()
	if clangs == 1:
		rink.raid.add_clue(tr("CLUE_HEAVY_SKATE"))


func _show_clang() -> void:
	rink.raid.float_label(tr("RINK_CLANG"), rink.main.global_position + Vector3.UP * 0.5, Color(1.0, 0.85, 0.3))


func net_state() -> Array:
	return [clangs]


func apply_net_state(state: Array) -> void:
	if state[0] > clangs and is_instance_valid(rink.main):
		_show_clang()
	clangs = state[0]
