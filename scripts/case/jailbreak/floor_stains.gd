class_name FloorStains
extends Node3D

## The stains on the station's floor in the cleaning crew's jailbreak (docs/diseno/fuga-limpieza.md, step 4): coffee,
## mud, footprints and donut crumbs on COUNT_MIN to COUNT_MAX of the SPOTS, drawn by the seed. A mop moving with its
## head on one (CleaningTool.is_working), or the floor polisher on (FloorPolisher, faster), scrubs it, and SCRUB seconds of it clean it: the floor there stays wet for
## WET_TIME seconds, with a little yellow sign, and a cop running over it slips. The host scrubs (the guests get it
## from NpcSync); every PC slips its own cop (the level). Every number here is (propuesta).

signal cleaned(index: int, at: Vector3)

## In the station's own space (StationRooms): the guard room and the cells room, out of the furniture's way.
const SPOTS: Array[Vector3] = [
	Vector3(-4.5, 0, 3.5), Vector3(-2.5, 0, 3.0), Vector3(-0.8, 0, 4.2), Vector3(1.2, 0, 3.4), Vector3(3.0, 0, 4.6),
	Vector3(4.8, 0, 5.5), Vector3(-3.2, 0, 6.0), Vector3(-1.0, 0, 6.8), Vector3(1.6, 0, 6.2), Vector3(3.5, 0, 7.0),
	Vector3(-0.4, 0, 8.2), Vector3(0.9, 0, 8.6), Vector3(-5.0, 0, 7.4), Vector3(2.4, 0, 2.4), Vector3(7.2, 0, 6.0),
	Vector3(8.8, 0, 7.8), Vector3(10.4, 0, 5.8), Vector3(12.6, 0, 6.2), Vector3(14.0, 0, 8.2), Vector3(7.6, 0, 8.4),
]
const KINDS := ["coffee", "mud", "footprints", "crumbs"]
const COLORS := {
	"coffee": Color(0.42, 0.25, 0.12), "mud": Color(0.36, 0.3, 0.2), "footprints": Color(0.22, 0.22, 0.24),
	"crumbs": Color(0.85, 0.72, 0.5),
}
const COUNT_MIN := 8
const COUNT_MAX := 12
const RADIUS := 0.35
## How close to a stain the mop's head must be, flat and above the floor, to scrub it.
const REACH := 0.45
const ABOVE := 0.3
const SCRUB := 2.0
const WET_TIME := 20.0
const WET := Color(0.55, 0.75, 0.95, 0.55)
const SIGN := Color(1.0, 0.85, 0.1)

## Each stain: where (world), its kind, the seconds of scrubbing it still needs (0: clean) and how long it stays wet.
var spots: Array[Vector3] = []
var kinds: Array[String] = []
var dirt := PackedFloat32Array()
var wet := PackedFloat32Array()
var _marks: Array[MeshInstance3D] = []
var _signs: Array[MeshInstance3D] = []


## The stains for this jailbreak's seed, on the station of `station_lot`.
func setup(case_seed: int, station_lot: Transform3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["floor stains", case_seed])
	var order := range(SPOTS.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for i in rng.randi_range(COUNT_MIN, COUNT_MAX):
		spots.append(station_lot * SPOTS[order[i]])
		kinds.append(KINDS[rng.randi_range(0, KINDS.size() - 1)])
	dirt.resize(spots.size())
	dirt.fill(SCRUB)
	wet.resize(spots.size())
	wet.fill(0.0)
	for i in spots.size():
		_marks.append(_disc(spots[i], COLORS[kinds[i]]))
		_signs.append(_sign(spots[i]))
	_refresh()


func _disc(at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = RADIUS
	mesh.bottom_radius = RADIUS
	mesh.height = 0.01
	mesh.radial_segments = 12
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = material
	var mark := MeshInstance3D.new()
	mark.mesh = mesh
	add_child(mark)
	mark.global_position = at + Vector3.UP * 0.012
	return mark


## The little yellow "wet floor" sign beside a stain.
func _sign(at: Vector3) -> MeshInstance3D:
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.25, 0.4, 0.18)
	var material := StandardMaterial3D.new()
	material.albedo_color = SIGN
	mesh.material = material
	var sign := MeshInstance3D.new()
	sign.mesh = mesh
	add_child(sign)
	sign.global_position = at + Vector3(RADIUS + 0.1, 0.2, 0)
	return sign


func _physics_process(delta: float) -> void:
	var changed := false
	for i in wet.size():
		if wet[i] > 0.0:
			wet[i] = maxf(wet[i] - delta, 0.0)
			changed = changed or wet[i] == 0.0
	for scrubber: Node in get_tree().get_nodes_in_group("floor_scrubbers"):
		if scrubber.call("is_scrubbing"):
			var at: Vector3 = scrubber.call("scrub_point")
			var scrubbed := scrub_at(at, delta * float(scrubber.call("scrub_factor")), scrubber.call("scrub_reach"))
			changed = scrubbed >= 0 or changed
	if changed:
		_refresh()


## A mop's head at `tip` (or a polisher's disc `reach` wide) scrubs the dirty stain under it for `delta` seconds: its
## index, or -1 if none is there.
func scrub_at(tip: Vector3, delta: float, reach := REACH) -> int:
	for i in spots.size():
		var flat := Vector2(tip.x - spots[i].x, tip.z - spots[i].z)
		if dirt[i] <= 0.0 or flat.length() > reach or tip.y - spots[i].y > ABOVE:
			continue
		dirt[i] = maxf(dirt[i] - delta, 0.0)
		if dirt[i] == 0.0:
			wet[i] = WET_TIME
			_refresh()
			cleaned.emit(i, spots[i])
		return i
	return -1


func is_clean(index: int) -> bool:
	return dirt[index] <= 0.0


## Whether `at` is on a wet patch of floor.
func wet_at(at: Vector3) -> bool:
	for i in spots.size():
		if wet[i] > 0.0 and Vector2(at.x - spots[i].x, at.z - spots[i].z).length() <= RADIUS + 0.2:
			return true
	return false


## A dirty stain shows its color, fading as it's scrubbed; a clean one, the wet floor and its sign while it's wet.
func _refresh() -> void:
	for i in spots.size():
		var material: StandardMaterial3D = _marks[i].mesh.material
		if dirt[i] > 0.0:
			material.albedo_color = COLORS[kinds[i]]
			material.albedo_color.a = 0.35 + 0.65 * dirt[i] / SCRUB
		else:
			material.albedo_color = WET
		_marks[i].visible = dirt[i] > 0.0 or wet[i] > 0.0
		_signs[i].visible = wet[i] > 0.0


## Online: how dirty and how wet each stain is (NpcSync).
func net_state() -> Variant:
	return [dirt, wet]


func apply_net_state(state: Variant) -> void:
	dirt = state[0]
	wet = state[1]
	_refresh()
