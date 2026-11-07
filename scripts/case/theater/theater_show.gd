class_name TheaterShow
extends Node

## The show goes on (escena-teatro.md, "La función que sigue"): once the cops are at the scene, every EVERY seconds
## Maestro Bambalina shouts "¡Cambio de escena!" through the megaphone and for CHANGE_SECONDS the stage changes:
## - the turntable makes half a turn in SPIN_SECONDS, carrying the cops on it, and whatever lies loose on it ends up
##   behind the backdrop;
## - the four trapdoors open for TRAP_SECONDS, so whoever stands on one drops to the basement;
## - a flat comes down on its ropes (a castle, a moon, a tree) and hides the back of the stage until the next change.
## When it's over every ghost is on someone else's mark. The stage lever behind the curtain stops the show for EVERY
## seconds, but the director loses LEVER_PATIENCE of his patience; at 0 the cops on the stage have to act, stuck in
## the spotlight for SPOTLIGHT_SECONDS. The host decides; each PC moves its own cop. Every number here is (propuesta).

## A change started (`first` the first time: the turn uncovers the culprit's talc footprint, step 6).
signal changed(first: bool)

const EVERY := 120.0
const CHANGE_SECONDS := 15.0
const SPIN_SECONDS := 3.0
const TRAP_SECONDS := 3.0
const PATIENCE := 100.0
const LEVER_PATIENCE := 10.0
const SPOTLIGHT_SECONDS := 10.0
## The flats that come down, in turn, and the parts each is made of: [center, size, color] in the flat's space.
const FLATS := {
	"castle": [[Vector3(0, 1.6, 0), Vector3(6.0, 3.2, 0.1), Color(0.6, 0.6, 0.62)],
		[Vector3(-2.4, 3.6, 0), Vector3(1.2, 0.8, 0.1), Color(0.6, 0.6, 0.62)],
		[Vector3(0, 3.6, 0), Vector3(1.2, 0.8, 0.1), Color(0.6, 0.6, 0.62)],
		[Vector3(2.4, 3.6, 0), Vector3(1.2, 0.8, 0.1), Color(0.6, 0.6, 0.62)],
		[Vector3(0, 0.9, 0.06), Vector3(1.4, 1.8, 0.02), Color(0.35, 0.22, 0.12)]],
	"moon": [[Vector3(0, 2.4, 0), Vector3(4.0, 4.0, 0.1), Color(0.98, 0.9, 0.45)],
		[Vector3(1.2, 2.8, 0.06), Vector3(1.4, 2.6, 0.02), Theater.BACKDROP]],
	"tree": [[Vector3(0, 1.2, 0), Vector3(0.8, 2.4, 0.1), Color(0.45, 0.3, 0.16)],
		[Vector3(0, 3.4, 0), Vector3(4.4, 2.6, 0.1), Color(0.25, 0.55, 0.25)]],
}
## Where a flat hangs when it's down: right behind the turntable, from the stage up.
const FLAT_AT := Vector3(0, Theater.STAGE_TOP, -10.6)
const FLAT_UP := 6.0

var theater: Theater
var case: CrimeSceneCase
## Seconds to the next change, and seconds left while it lasts.
var until_change := EVERY
var change_left := 0.0
## How many changes so far (the flat and the ghosts' marks use it).
var changes := 0
var patience := PATIENCE
## The turntable's turn so far (radians), and which flat is down ("" for none).
var spun := 0.0
var flat := ""
var bar: ProgressBar
var _next: Label
var _hud: CanvasLayer
var _flats := {}
var _trap_layers: Array[int] = []


func _ready() -> void:
	add_to_group("theater_show")
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	_hud.add_child(box)
	var title := Label.new()
	title.text = "HUD_BAMBALINA_PATIENCE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.show_percentage = false
	bar.max_value = PATIENCE
	bar.modulate = Color(0.85, 0.3, 0.35)
	box.add_child(bar)
	_next = Label.new()
	_next.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_next)
	_hud.visible = false
	add_child(_hud)
	for door in theater.trapdoors:
		_trap_layers.append(door.collision_layer)
	for flat_name: String in FLATS:
		var hung := Node3D.new()
		hung.name = "Flat_" + flat_name
		hung.position = FLAT_AT + Vector3(0, FLAT_UP, 0)
		hung.visible = false
		for part: Array in FLATS[flat_name]:
			var mesh := BoxMesh.new()
			mesh.size = part[1]
			var piece := MeshInstance3D.new()
			piece.mesh = mesh
			var material := StandardMaterial3D.new()
			material.albedo_color = part[2]
			piece.material_override = material
			piece.position = part[0]
			hung.add_child(piece)
		theater.add_child(hung)
		_flats[flat_name] = hung


func is_on() -> bool:
	return change_left > 0.0


func traps_open() -> bool:
	return is_on() and CHANGE_SECONDS - change_left < TRAP_SECONDS


## Online, a guest's show follows the host's: [seconds of the change left, seconds to the next, changes, patience]. A
## new change starts here too (the flat, the trapdoors, the turn), and the ghosts' marks come with the theater's state.
func follow(state: Array) -> void:
	if state[2] > changes:
		changes = state[2] - 1
		start_change()
	elif is_on() and state[0] <= 0.0:
		end_change()
	change_left = state[0]
	until_change = state[1]
	changes = state[2]
	patience = state[3]
	if not traps_open():
		_open_traps(false)


## "¡Cambio de escena!": the turntable starts its half turn, the trapdoors open, the next flat comes down and what's
## loose on the turntable goes behind the backdrop.
func start_change() -> void:
	change_left = CHANGE_SECONDS
	changes += 1
	spun = 0.0
	theater.director.say("DIRECTOR_CHANGE")
	_hint_all("HINT_SCENE_CHANGE")
	_open_traps(true)
	flat = FLATS.keys()[(changes - 1) % FLATS.size()]
	for flat_name: String in _flats:
		var hung := _flats[flat_name] as Node3D
		hung.visible = flat_name == flat
		hung.position = FLAT_AT + Vector3(0, FLAT_UP, 0)
	_clear_turntable()
	changed.emit(changes == 1)


## It's over: the trapdoors shut, the turntable is done, the next change in EVERY seconds and every ghost is on
## someone else's mark.
func end_change() -> void:
	_spin(PI - spun)
	change_left = 0.0
	until_change = EVERY
	_open_traps(false)
	(_flats[flat] as Node3D).position = FLAT_AT
	_shuffle_ghosts()
	_hint_all("HINT_SCENE_CHANGED")


## The stage lever: no change for EVERY seconds (a change on now ends), and Maestro Bambalina loses patience; at 0
## every cop on the stage has to act.
func pull_lever(cop: Cop) -> void:
	if is_on():
		end_change()
	until_change = EVERY
	patience = maxf(patience - LEVER_PATIENCE, 0.0)
	if patience > 0.0:
		theater.director.say("DIRECTOR_LEVER")
		if cop:
			cop.show_hint("HINT_LEVER_PULLED")
		return
	theater.director.say("DIRECTOR_ACT")
	var role := 0
	for node in get_tree().get_nodes_in_group("cops"):
		var other := node as Cop
		if other and theater.room(other.global_position) == "stage":
			spotlight(other, role)
			role += 1


## A cop in the spotlight: stuck for SPOTLIGHT_SECONDS saying their part.
func spotlight(cop: Cop, role: int) -> void:
	cop.stagger(SPOTLIGHT_SECONDS)
	cop.show_hint("HINT_SPOTLIGHT_%d" % (role % 3))


## The host's clock: the countdown while the cops are at the scene, and the change.
func tick(delta: float) -> void:
	if is_on():
		var was_open := traps_open()
		change_left -= delta
		if was_open and not traps_open():
			_open_traps(false)
		if change_left <= 0.0:
			end_change()
	elif case.at_tent:
		until_change -= delta
		if until_change <= 0.0:
			start_change()


func _physics_process(delta: float) -> void:
	_hud.visible = case.at_tent
	bar.value = patience
	_next.text = tr("HUD_CHANGE_ON") if is_on() else tr("HUD_NEXT_CHANGE") % ceili(until_change)
	if not case.follower:
		tick(delta)
	if is_on():
		_spin(minf(PI * delta / SPIN_SECONDS, PI - spun))
		var hung := _flats[flat] as Node3D
		hung.position.y = move_toward(hung.position.y, FLAT_AT.y, FLAT_UP * delta / SPIN_SECONDS)


## The turntable turns `angle` more, and so does every cop of this PC standing on it.
func _spin(angle: float) -> void:
	if angle <= 0.0:
		return
	spun += angle
	var turntable := theater.get_node("Turntable") as Node3D
	turntable.rotation.y += angle
	var center := theater.to_global(Theater.TURNTABLE_AT)
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop or not _own(cop) or not _on_turntable(cop.global_position):
			continue
		var from := cop.global_position - center
		cop.global_position = center + from.rotated(Vector3.UP, angle)
		cop.rotation.y += angle


func _on_turntable(world: Vector3) -> bool:
	var local := theater.to_local(world) - Theater.TURNTABLE_AT
	return Vector2(local.x, local.z).length() < Theater.TURNTABLE_RADIUS and absf(local.y) < 0.6


func _own(cop: Cop) -> bool:
	return not cop.sync or not cop.sync.is_inside_tree() or cop.sync.is_multiplayer_authority()


## Anything loose (not held) on the turntable ends up on the other side: behind the backdrop, on the floor there.
func _clear_turntable() -> void:
	if case.follower:
		return
	for node in get_tree().root.find_children("*", "RigidBody3D", true, false):
		var item := node as Grabbable
		if not item or not item.holders.is_empty() or not item.visible or item.freeze:
			continue
		if not _on_turntable(item.global_position):
			continue
		var local := theater.to_local(item.global_position)
		item.global_position = theater.to_global(Vector3(local.x, Theater.STAGE_TOP + 0.3, Theater.BACKDROP_Z - 0.6))
		item.linear_velocity = Vector3.ZERO


## The trapdoors open (no floor, no lid) or shut.
func _open_traps(open: bool) -> void:
	for i in theater.trapdoors.size():
		var door := theater.trapdoors[i]
		door.collision_layer = 0 if open else _trap_layers[i]
		for child in door.get_children():
			if child is MeshInstance3D:
				(child as MeshInstance3D).visible = not open


## A shuffle where nobody stays on their own mark, drawn with the seed and the change; each faces what's at their new
## mark.
func _shuffle_ghosts() -> void:
	var marks: Array[Vector3] = []
	for ghost in theater.ghosts:
		marks.append(ghost.position)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["theater change", case.case_seed, changes])
	var order := range(marks.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i - 1)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for i in theater.ghosts.size():
		theater.ghosts[i].position = marks[order[i]]
		theater.ghosts[i].rotation.y = Theater.facing(marks[order[i]])


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
