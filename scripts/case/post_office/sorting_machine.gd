class_name SortingMachine
extends Node

## The sorting machine (escena-correo.md, "La clasificadora"): once the cops are at the scene, every EVERY seconds the
## siren sounds and the big machine runs on its own for RUN_SECONDS. Envelopes fly all over the sorting room, the wind
## pushes the cops in it toward the door, and anything loose on its floor (a clue not bagged yet, a donut, a camera)
## ends up on top of a mail sack. When it stops every carrier is somewhere else, picking up their letters. The red
## button in the boss's office stops it early, but Doña Sellito loses BUTTON_PATIENCE of her patience; at 0 she
## stamps the cops' faces, and a stamped cop can't take prints for STAMPED_SECONDS. The host decides; each PC pushes
## its own cop. Every number here is (propuesta).

## The machine started (`first` the first time: it uncovers what was under the letters, step 6).
signal started(first: bool)

const EVERY := 120.0
const RUN_SECONDS := 20.0
const PATIENCE := 100.0
const BUTTON_PATIENCE := 10.0
const STAMPED_SECONDS := 30.0
## How fast the wind pushes a cop toward the sorting room's door (m/s).
const WIND_SPEED := 2.5
const ENVELOPES := 70
## Where the wind blows the cops: in front of the sorting room's door, on the hall side.
const DOOR_AT := Vector3(PostOffice.DOOR_SORTING_X, 0, PostOffice.ROOMS_Z + 1.0)

var post_office: PostOffice
var case: CrimeSceneCase
## Seconds to the next run, and seconds left while it runs.
var until_run := EVERY
var run_left := 0.0
## How many times it ran (the carriers' shuffle uses it).
var runs := 0
var patience := PATIENCE
## Cops with a stamp on the face, and the seconds it has left.
var stamped := {}
var bar: ProgressBar
var _next: Label
var _hud: CanvasLayer
var _envelopes: Array[MeshInstance3D] = []
var _time := 0.0


func _ready() -> void:
	add_to_group("sorting_machine")
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	_hud.add_child(box)
	var title := Label.new()
	title.text = "HUD_SELLITO_PATIENCE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.show_percentage = false
	bar.max_value = PATIENCE
	bar.modulate = Color(0.4, 0.85, 0.5)
	box.add_child(bar)
	_next = Label.new()
	_next.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_next)
	_hud.visible = false
	add_child(_hud)
	var paper := BoxMesh.new()
	paper.size = Vector3(0.34, 0.015, 0.2)
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.97, 0.96, 0.9)
	for i in ENVELOPES:
		var envelope := MeshInstance3D.new()
		envelope.mesh = paper
		envelope.material_override = white
		envelope.visible = false
		post_office.add_child(envelope)
		_envelopes.append(envelope)


func is_on() -> bool:
	return run_left > 0.0


## The siren: the machine starts and blows away what's loose on the sorting room's floor.
func start_run() -> void:
	run_left = RUN_SECONDS
	runs += 1
	_running(true)
	post_office.boss.say("POST_BOSS_SORTING")
	_hint_all("HINT_SORTING_STARTS")
	_blow_away()
	started.emit(runs == 1)


## It stops: the next run in EVERY seconds, and every carrier is somewhere else.
func end_run() -> void:
	run_left = 0.0
	until_run = EVERY
	_running(false)
	_shuffle_carriers()
	_hint_all("HINT_SORTING_ENDS")


## The red button: it stops now, and Doña Sellito loses patience; at 0 she stamps the cop who pressed it (and every
## other cop at the post office, the first time).
func switch_off(cop: Cop) -> void:
	if not is_on():
		if cop:
			cop.show_hint("HINT_BUTTON_IDLE")
		return
	end_run()
	var was := patience
	patience = maxf(patience - BUTTON_PATIENCE, 0.0)
	if patience > 0.0:
		post_office.boss.say("POST_BOSS_BUTTON")
		if cop:
			cop.show_hint("HINT_BUTTON_PRESSED")
		return
	post_office.boss.say("POST_BOSS_STAMPS")
	if was > 0.0:
		for node in get_tree().get_nodes_in_group("cops"):
			var other := node as Cop
			if other and post_office.inside(other.global_position):
				stamp(other)
	if cop:
		stamp(cop)


## A stamp on the cop's face: no prints for STAMPED_SECONDS.
func stamp(cop: Cop) -> void:
	stamped[cop] = STAMPED_SECONDS
	cop.show_hint("HINT_STAMPED")


func is_stamped(cop: Cop) -> bool:
	return stamped.get(cop, 0.0) > 0.0


## The host's clock: the countdown while the cops are at the scene, and the run.
func tick(delta: float) -> void:
	for cop: Cop in stamped.keys():
		stamped[cop] -= delta
		if stamped[cop] <= 0.0 or not is_instance_valid(cop):
			stamped.erase(cop)
	if is_on():
		run_left -= delta
		if run_left <= 0.0:
			end_run()
	elif case.at_tent:
		until_run -= delta
		if until_run <= 0.0:
			start_run()


func _physics_process(delta: float) -> void:
	_hud.visible = case.at_tent
	bar.value = patience
	_next.text = tr("HUD_SORTING_ON") if is_on() else tr("HUD_NEXT_SORTING") % ceili(until_run)
	if not case.follower:
		tick(delta)
	if is_on():
		_push(delta)


## The wind: every PC pushes its own cops in the sorting room toward the door.
func _push(delta: float) -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop or not _own(cop) or post_office.room(cop.global_position) != "sorting":
			continue
		var to := post_office.to_global(DOOR_AT) - cop.global_position
		to.y = 0
		if to.length() > 0.1:
			cop.global_position += to.normalized() * WIND_SPEED * delta


func _own(cop: Cop) -> bool:
	return not cop.sync or not cop.sync.is_inside_tree() or cop.sync.is_multiplayer_authority()


## Anything loose (not held) on the sorting room's floor lands on top of the nearest mail sack.
func _blow_away() -> void:
	if case.follower:
		return
	for node in get_tree().root.find_children("*", "RigidBody3D", true, false):
		var item := node as Grabbable
		if not item or not item.holders.is_empty() or not item.visible or item.freeze:
			continue
		if post_office.room(item.global_position) != "sorting":
			continue
		var local := post_office.to_local(item.global_position)
		var nearest: Vector3 = PostOffice.SACKS_AT[0]
		for sack: Vector3 in PostOffice.SACKS_AT:
			if Vector2(sack.x, sack.z).distance_to(Vector2(local.x, local.z)) < Vector2(nearest.x, nearest.z).distance_to(
					Vector2(local.x, local.z)):
				nearest = sack
		item.global_position = post_office.to_global(nearest + Vector3(0, 1.4, 0))
		item.linear_velocity = Vector3.ZERO


## The envelopes in the air.
func _running(on: bool) -> void:
	for envelope in _envelopes:
		envelope.visible = on


## A shuffle where nobody stays in their own spot, drawn with the seed and the run; each faces what's at their new
## spot.
func _shuffle_carriers() -> void:
	var carriers := post_office.carriers
	var spots: Array[Vector3] = []
	for carrier in carriers:
		spots.append(carrier.position)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["post office sorting", case.case_seed, runs])
	var order := range(spots.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i - 1)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for i in carriers.size():
		carriers[i].position = spots[order[i]]
		carriers[i].rotation.y = PostOffice.facing(spots[order[i]])


## The envelopes flutter around the machine while it runs.
func _process(delta: float) -> void:
	if not is_on():
		return
	_time += delta
	var center := PostOffice.MACHINE_AT
	for i in _envelopes.size():
		var phase := i * 2.399
		var radius := 2.0 + fmod(i * 0.37, 4.0)
		var angle := phase + _time * (0.8 + fmod(i * 0.13, 0.9))
		_envelopes[i].position = center + Vector3(cos(angle) * radius * 1.3, 0.4 + fmod(i * 0.29 + _time * 0.7, 2.6),
			sin(angle) * radius * 0.8)
		_envelopes[i].rotation = Vector3(_time * 3.0 + i, _time * 2.0 + phase, 0)


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
