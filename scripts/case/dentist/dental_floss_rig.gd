class_name DentalFlossRig
extends DentistRaidRig

## The dental floss (allanamiento-dentista.md, "El hilo dental"): Dr. Molina sells reinforced floss to a gang planning a
## jailbreak. The crate of reels is hidden; a rope of floss hangs from the little window at the corridor's west end,
## the story's own clue (on the checklist the first time a cop comes close); and THREADS taut threads cross the
## corridor at ankle height (where, drawn with the seed): a cop running over one trips, drops what it holds and is
## down for TRIP_TIME seconds. Walking over them is fine. Every number here is (propuesta).

const F := DentistRaid.FLOOR_TOP
const THREADS := 3
## Where a thread can cross the corridor (x), from its rooms' wall to the waiting room's.
const THREAD_XS: Array[float] = [-9.6, -7.0, -4.2, -1.4, 1.4, 4.2, 7.0, 9.6]
const THREAD_HEIGHT := 0.12
const TRIP_TIME := 1.5
const TRIP_PUSH := 3.0
const TRIP_AGAIN := 2.0
## A cop's feet this far above the floor at most still catch a thread.
const FEET := 0.4
## The rope hanging from the little window high on the corridor's west wall, and how close a cop notices it.
const WINDOW_AT := Vector3(-DentistRaid.HALF_X + 0.06, F + 2.5, 2.0)
const ROPE_RANGE := 1.5
const FLOSS := Color(0.96, 0.96, 0.92)

var thread_xs: Array[float] = []
var trips := 0
var saw_rope := false
var rope: MeshInstance3D
## Cop -> where it was last frame (in the office's space), and seconds until it can trip again.
var _last := {}
var _again := {}


func setup(place: DentistRaid) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["dental floss", place.case_seed])
	var xs := THREAD_XS.duplicate()
	for i in THREADS:
		thread_xs.append(xs.pop_at(rng.randi_range(0, xs.size() - 1)))
	thread_xs.sort()
	var look := StandardMaterial3D.new()
	look.albedo_color = FLOSS
	look.emission_enabled = true
	look.emission = FLOSS * 0.3
	for x in thread_xs:
		var length := DentistRaid.WAITING_Z - DentistRaid.ROOMS_Z
		_box(Vector3(x, F + THREAD_HEIGHT, DentistRaid.ROOMS_Z + length / 2), Vector3(0.012, 0.012, length), look)
	var window := StandardMaterial3D.new()
	window.albedo_color = Color(0.6, 0.8, 0.95)
	_box(WINDOW_AT + Vector3(0.0, 0.25, 0.0), Vector3(0.04, 0.4, 0.6), window)
	rope = _box(WINDOW_AT + Vector3(0.12, -(WINDOW_AT.y - F) / 2, 0.0), Vector3(0.025, WINDOW_AT.y - F, 0.025), look)


## Whether going from `from` to `to` (the office's space) steps over a thread: its index, or -1.
func crossed(from: Vector3, to: Vector3) -> int:
	if to.z < DentistRaid.ROOMS_Z or to.z > DentistRaid.WAITING_Z or to.y > F + FEET:
		return -1
	for i in thread_xs.size():
		if signf(from.x - thread_xs[i]) != signf(to.x - thread_xs[i]):
			return i
	return -1


## `cop` trips on a thread heading `ahead`: it lets go of what it holds and is down for TRIP_TIME.
func trip(cop: Cop, ahead: Vector3) -> void:
	trips += 1
	_again[cop] = TRIP_AGAIN
	cop.get_node("Grabber").release()
	cop.knock_back(ahead * TRIP_PUSH, TRIP_TIME)
	cop.show_hint("HINT_FLOSS_TRIP")


func _physics_process(delta: float) -> void:
	for cop: Variant in _again.keys():
		_again[cop] -= delta
		if _again[cop] <= 0.0 or not is_instance_valid(cop):
			_again.erase(cop)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var at := office.to_local(cop.global_position)
		if not saw_rope and Vector2(at.x - rope.position.x, at.z - rope.position.z).length() < ROPE_RANGE:
			saw_rope = true
			office.raid.add_clue(tr("CLUE_FLOSS_ROPE"))
		# Each PC trips only its own player's cop.
		if FamousDenturesRig.is_mine(cop) and _last.has(cop) and cop.is_running and not _again.has(cop) \
				and crossed(_last[cop], at) >= 0:
			trip(cop, Vector3(signf(at.x - _last[cop].x), 0.0, 0.0))
		_last[cop] = at


func _box(at: Vector3, size: Vector3, look: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var box := MeshInstance3D.new()
	box.mesh = mesh
	box.material_override = look
	box.position = at
	office.add_child(box)
	return box
