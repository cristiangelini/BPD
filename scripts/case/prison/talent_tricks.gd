class_name TalentTricks
extends Node

## The escapes hidden in the talent show's acts (carcel-talentos.md, step 5). The magician asks for a volunteer from
## the audience, shuts them in his box and makes them "vanish" at MAGIC_VANISH: E on the closed box before that brings
## them out red-faced; otherwise they come out running in the kitchen. Under the choir's singing one of the audience
## saws the bars of a canteen window for SAW_TIME (heard within SAW_HEAR): E on them grabs them for the punishment
## cell; done, they're out through the window. In the smoke dance the machine fills the stage and the benches and two
## of the audience crawl for the yard door: E on the machine clears it and, seen, they go back to their seats;
## reaching the door they run. A runner goes for the gate (BlackoutInmate, like the laundry's), cuffed and walked to
## the punishment cell it counts as caught; at the gate, as escaped. Every number here is (propuesta).

signal foiled_one(trick: String)
signal caught_one(count: int)
signal escaped_one(count: int)

const MAGIC_CALL := 8.0
const MAGIC_IN := 12.0
const MAGIC_VANISH := 40.0
const BOX_AT := Vector2(1.6, 0.9)
const KITCHEN_OUT := Vector2(8.0, -3.0)
const SAW_START := 5.0
const SAW_TIME := 40.0
const SAW_HEAR := 4.0
const SAW_EVERY := 3.0
## The canteen's west wall windows the sawyer can pick (level z), and where they come out.
const WINDOW_ZS: Array[float] = [-1.0, 2.0, 5.0]
const WINDOW_SIZE := Vector2(1.0, 0.9)
const WINDOW_SILL := 1.1
const OUTSIDE_X := -13.0
const SMOKE_CRAWL := 10.0
const CRAWLERS := 2
const CRAWL_SPEED := 0.45
const CLEAR_TIME := 5.0
const SMOKE_PUFFS := 9
const YARD_DOOR := Vector2(PrisonLevel.ENTRANCES[0], 7.4)
const MACHINE_AT := Vector2(2.4, 0.4)
const PUNISHMENT_AT := Vector2(-11.0, -5.5)
const SMOKE := Color(0.92, 0.92, 0.95, 0.75)

var plan: TalentPlan
var prison: PrisonLevel
var box: TalentProp
var machine: TalentProp
var windows: Array[Node3D] = []
## Who does what in each trick (indices into plan.inmates), from the seed.
var volunteer := 0
var sawyer := 0
var crawlers: Array[int] = []
var window := 0
var foiled := 0
var caught := 0
var escaped := 0
var runners: Array[BlackoutInmate] = []
var sawing: TalentInmate
var saw_left := 0.0
var crawling: Array[TalentInmate] = []
var follower := false
var _trick := ""
var _act_time := 0.0
var _saw_noise := 0.0
var _clear_left := 0.0
var _smoke: Node3D
var _seats := {}


func setup(talent: TalentPlan, rng: RandomNumberGenerator) -> void:
	plan = talent
	prison = talent.prison
	var order := range(plan.inmates.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	volunteer = order[0]
	sawyer = order[1]
	crawlers.assign(order.slice(2, 2 + CRAWLERS))
	window = rng.randi_range(0, WINDOW_ZS.size() - 1)
	for inmate in plan.inmates:
		_seats[inmate] = inmate.global_transform
		inmate.grabbed.connect(_on_sawyer_grabbed)
	box = TalentProp.new()
	box.name = "MagicBox"
	box.kind = TalentProp.Kind.BOX
	plan.stage.add_child(box)
	box.global_position = plan.stage.spot(BOX_AT.x, BOX_AT.y)
	box.visible = false
	box.collision_layer = 0
	box.opened.connect(_on_box_opened)
	machine = TalentProp.new()
	machine.name = "SmokeMachine"
	machine.kind = TalentProp.Kind.SMOKE
	plan.stage.add_child(machine)
	machine.global_position = plan.stage.spot(MACHINE_AT.x, MACHINE_AT.y)
	machine.visible = false
	machine.collision_layer = 0
	machine.opened.connect(_on_machine_off)
	for z in WINDOW_ZS:
		windows.append(_window(z))
	plan.act_started.connect(_on_act_started)
	plan.voted.connect(_on_act_over.unbind(3))


## A barred window high on the canteen's west wall.
func _window(z: float) -> Node3D:
	var frame := Node3D.new()
	frame.name = "Window%d" % windows.size()
	frame.position = Vector3(-PrisonLevel.BUILDING_X + PlaceBuilder.WALL / 2 + 0.01, PrisonLevel.FLOOR_TOP + WINDOW_SILL, z)
	prison.add_child(frame)
	frame.add_child(CopTool.piece(CopTool.box(Vector3(0.02, WINDOW_SIZE.y, WINDOW_SIZE.x)), Color(0.55, 0.75, 0.9),
		Vector3(0, WINDOW_SIZE.y / 2, 0)))
	var bars := Node3D.new()
	bars.name = "Bars"
	frame.add_child(bars)
	for i in 5:
		bars.add_child(CopTool.piece(CopTool.cylinder(0.015, WINDOW_SIZE.y), PrisonLevel.BARS,
			Vector3(0.03, WINDOW_SIZE.y / 2, -WINDOW_SIZE.x / 2 + (i + 0.5) * WINDOW_SIZE.x / 5)))
	return frame


func _on_act_started(index: int) -> void:
	_trick = plan.acts[index] if TalentPlan.TRICKS.has(plan.acts[index]) else ""
	_act_time = 0.0
	if _trick == "magician":
		box.visible = true
		box.collision_layer = 8
	elif _trick == "smoke":
		machine.visible = true
		machine.collision_layer = 8


## The act's over: the box and the machine go backstage, and whatever was still going on stops.
func _on_act_over() -> void:
	if _trick == "magician" and box.occupied:
		_vanish()
	if _trick == "smoke":
		_smoke_off()
		for inmate: TalentInmate in crawling.duplicate():
			_back_to_seat(inmate)
		crawling.clear()
	box.visible = false
	box.collision_layer = 0
	machine.visible = false
	machine.collision_layer = 0
	_trick = ""


func _physics_process(delta: float) -> void:
	if follower:
		return
	if sawing:
		_saw(delta)
	if _clear_left > 0.0:
		_clear_left -= delta
		if _smoke:
			_smoke.scale = Vector3.ONE * maxf(_clear_left / CLEAR_TIME, 0.01)
		if _clear_left <= 0.0:
			_remove_smoke()
	if _trick == "" or plan.phase != TalentPlan.Phase.ACT:
		return
	var before := _act_time
	_act_time += delta
	match _trick:
		"magician":
			if _crossed(before, MAGIC_CALL):
				plan.performers["magician"][0].say("TALENT_MAGIC_VOLUNTEER")
				var who := plan.inmates[volunteer]
				who.set_seated(false)
				who.global_position = box.global_position + plan.prison.global_basis.z * 0.9
				who.say("TALENT_MAGIC_ME")
			if _crossed(before, MAGIC_IN):
				plan.inmates[volunteer].set_on_stage(false)
				box.occupied = true
				box.set_closed(true)
			if _crossed(before, MAGIC_VANISH) and box.occupied:
				_vanish()
		"choir":
			if _crossed(before, SAW_START) and not sawing:
				sawing = plan.inmates[sawyer]
				sawing.sawing = true
				sawing.set_seated(false)
				saw_left = SAW_TIME
				var at := windows[window].global_position
				sawing.global_position = Vector3(at.x + 0.45, prison.global_position.y + PrisonLevel.FLOOR_TOP, at.z)
				sawing.face(at)
		"smoke":
			if before == 0.0:
				_smoke_on()
			if _crossed(before, SMOKE_CRAWL) and _clear_left <= 0.0 and _smoke:
				for i in crawlers:
					var inmate := plan.inmates[i]
					inmate.set_crawling(true)
					crawling.append(inmate)
			_crawl(delta)


func _crossed(before: float, at: float) -> bool:
	return before <= at and _act_time > at


## Into thin air: the box opens empty and the volunteer runs out of the kitchen.
func _vanish() -> void:
	box.occupied = false
	box.set_closed(false)
	plan.performers["magician"][0].say("TALENT_MAGIC_VANISH")
	var who := plan.inmates[volunteer]
	who.hide()
	_runner(prison.global_transform * Vector3(KITCHEN_OUT.x, PrisonLevel.FLOOR_TOP, KITCHEN_OUT.y),
		LaundryPlan.escape_route(KITCHEN_OUT))


func _on_box_opened(_prop: TalentProp, cop: Cop) -> void:
	if follower or not box.occupied:
		return
	box.occupied = false
	box.set_closed(false)
	var who := plan.inmates[volunteer]
	who.set_on_stage(true)
	who.global_position = box.global_position + plan.prison.global_basis.z * 0.7
	who.say("TALENT_MAGIC_SHAME")
	plan.performers["magician"][0].say("TALENT_MAGIC_FOILED")
	cop.show_hint("HINT_MAGIC_FOILED")
	_foil("magician")
	get_tree().create_timer(2.0).timeout.connect(_back_to_seat.bind(who))


## The bars give a little more; heard close by over the choir. Done, they're out through the window.
func _saw(delta: float) -> void:
	_saw_noise -= delta
	if _saw_noise <= 0.0:
		_saw_noise = SAW_EVERY
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if cop.global_position.distance_to(sawing.global_position) <= SAW_HEAR:
				sawing.say("TALENT_SAW", 1.5)
				break
	saw_left -= delta
	if saw_left > 0.0:
		return
	var out := sawing
	sawing = null
	out.sawing = false
	out.hide()
	out.collision_layer = 0
	windows[window].get_node("Bars").hide()
	var z: float = WINDOW_ZS[window]
	var way: Array[Vector2] = [Vector2(OUTSIDE_X, PrisonLevel.BUILDING_FRONT + 2.0), Vector2(-6.0, 12.0),
		LaundryPlan.GATE]
	_runner(prison.global_transform * Vector3(OUTSIDE_X, PrisonLevel.FLOOR_TOP, z), way)


func _on_sawyer_grabbed(inmate: TalentInmate, cop: Cop) -> void:
	if follower or inmate != sawing:
		return
	sawing = null
	inmate.sawing = false
	inmate.say("TALENT_SAW_CAUGHT")
	cop.show_hint("HINT_SAWYER_CAUGHT")
	inmate.global_position = prison.global_transform * Vector3(PUNISHMENT_AT.x, PrisonLevel.FLOOR_TOP, PUNISHMENT_AT.y)
	_foil("choir")
	caught += 1
	caught_one.emit(caught)


func _smoke_on() -> void:
	machine.running = true
	_remove_smoke()
	_smoke = Node3D.new()
	_smoke.name = "Smoke"
	plan.stage.add_child(_smoke)
	_smoke.global_position = plan.stage.spot(0.0, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = SMOKE
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var rng := RandomNumberGenerator.new()
	rng.seed = SMOKE_PUFFS
	for i in SMOKE_PUFFS:
		var puff := MeshInstance3D.new()
		var ball := SphereMesh.new()
		ball.radius = rng.randf_range(1.4, 2.2)
		ball.height = ball.radius * 1.6
		puff.mesh = ball
		puff.material_override = material
		puff.position = Vector3(rng.randf_range(-3.0, 3.0), rng.randf_range(0.4, 1.4), rng.randf_range(-1.0, 5.5))
		_smoke.add_child(puff)


func _remove_smoke() -> void:
	if _smoke:
		_smoke.queue_free()
		_smoke = null


func _smoke_off() -> void:
	if machine.running:
		machine.running = false
		_clear_left = CLEAR_TIME


## E on the machine: off, and the smoke clears; whoever was crawling is seen and goes back, embarrassed.
func _on_machine_off(_prop: TalentProp, cop: Cop) -> void:
	if follower or not machine.running:
		return
	_smoke_off()
	cop.show_hint("HINT_SMOKE_OFF")
	var seen := not crawling.is_empty()
	for inmate: TalentInmate in crawling.duplicate():
		inmate.say("TALENT_CRAWL_SEEN")
		get_tree().create_timer(1.5).timeout.connect(_back_to_seat.bind(inmate))
	crawling.clear()
	if seen:
		_foil("smoke")


## The crawlers on their knees toward the yard door; one that gets there is off running.
func _crawl(delta: float) -> void:
	var door := prison.global_transform * Vector3(YARD_DOOR.x, PrisonLevel.FLOOR_TOP, YARD_DOOR.y)
	for inmate: TalentInmate in crawling.duplicate():
		var to := door - inmate.global_position
		to.y = 0.0
		if to.length() <= CRAWL_SPEED * delta:
			crawling.erase(inmate)
			inmate.hide()
			inmate.collision_layer = 0
			_runner(door, LaundryPlan.escape_route(YARD_DOOR + Vector2(0, 1.0)))
			continue
		inmate.global_position += to.normalized() * CRAWL_SPEED * delta
		inmate.face(door)


func _back_to_seat(inmate: TalentInmate) -> void:
	if not is_instance_valid(inmate) or not inmate.visible:
		return
	inmate.set_crawling(false)
	inmate.set_on_stage(true)
	inmate.global_transform = _seats[inmate]
	inmate.set_seated(true)


func _foil(trick: String) -> void:
	foiled += 1
	foiled_one.emit(trick)


## Off for the gate from `at` (world space) along `way` (level space), unless cuffed and walked to the punishment cell.
func _runner(at: Vector3, way: Array[Vector2]) -> BlackoutInmate:
	var runner := BlackoutInmate.new()
	runner.name = "Runner%d" % runners.size()
	runner.role = BlackoutInmate.Role.GATE
	runner.glow_eyes = false
	runner.prison = prison
	runner.route = way
	add_child(runner)
	runner.global_position = at
	runner.active = true
	runner.say("TALENT_RUNNER")
	runner.escaped.connect(_on_runner_escaped.unbind(1))
	BlackoutEscort.to_block(runner, prison).boarded.connect(_on_caught.bind(runner))
	runners.append(runner)
	return runner


func _on_caught(runner: BlackoutInmate) -> void:
	if runner.has_meta("caught"):
		return
	runner.set_meta("caught", true)
	caught += 1
	caught_one.emit(caught)


func _on_runner_escaped() -> void:
	escaped += 1
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_TALENT_ESCAPED")
	escaped_one.emit(escaped)
