class_name GardenPlant
extends StaticBody3D

## One of the 48 plants of the prison's garden (carcel-huerta.md, step 2): a lettuce, a carrot, a tomato plant or a
## pumpkin in its bed. Step 3: 3 of them are magic beans in disguise (`magic`): once they start they grow a stage
## every GROW_EVERY seconds out of the vegetable, through STAGES (sprout, bush, plant, vine and giant), violet from the
## second stage on, going "crrc... crrc..." to a cop within HEAR metres. The giant leans on the nearest stretch of the
## perimeter wall, over it (`top`). Step 4: E pulls it (`tugged`); pulled, it flies out of its bed (`pull_out`).
## Every number here is (propuesta).

signal grew(plant: GardenPlant, stage: int)
## Step 4: E on it (ActionSync runs it on every PC; GardenPlan, on the host, decides).
signal tugged(plant: GardenPlant, cop: Cop)

enum Kind { LETTUCE, CARROT, TOMATO, PUMPKIN }

const SIZE := Vector3(0.36, 0.4, 0.36)
const LEAF := Color(0.3, 0.62, 0.25)
const ORANGE := Color(0.95, 0.5, 0.12)
const RED := Color(0.85, 0.15, 0.12)
const STAKE := Color(0.55, 0.4, 0.22)
const STAGES := 5
const HEIGHTS: Array[float] = [0.0, 0.3, 0.75, 1.6, 3.0]
const BEAN := Color(0.45, 0.75, 0.25)
const VIOLET := Color(0.55, 0.25, 0.75)
const GROW_EVERY := 40.0
const HEAR := 5.0
const CREAK_EVERY := Vector2(2.5, 4.0)
const CREAK_TIME := 1.2
## The giant's top rests this high, just over the perimeter wall.
const OVER_WALL := PrisonLevel.FENCE_HEIGHT + 0.4
const FLY := 1.2
const FLY_TIME := 0.5
const SHAKE := 0.08

var kind := Kind.LETTUCE
## The bed it's in (0 to 11) and its place in it (0 to 3).
var bed := 0
var slot := 0
## Step 3: a magic bean, its stage (0: still just the vegetable) and when it grows next.
var magic := false
var stage := 0
var growing := false
var grow_left := GROW_EVERY
## A guest's copy (step 7): the host's one decides.
var follower := false
## The giant's top, in the prison's space, over the wall.
var top := Vector3.ZERO
var prison: PrisonLevel
var pulled := false
var _model: Node3D
var _stalk: Node3D
var _creak: Label3D
var _creak_left := 0.0
var _creak_shown := 0.0


func _ready() -> void:
	add_to_group("garden_plants")
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_model = build_model(kind)
	add_child(_model)
	_creak = Label3D.new()
	_creak.name = "Creak"
	_creak.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_creak.pixel_size = 0.003
	_creak.outline_size = 8
	_creak.font_size = 36
	_creak.modulate = Color(0.8, 1.0, 0.6)
	_creak.text = "GARDEN_CREAK"
	_creak.hide()
	add_child(_creak)


func prompt_key(_cop: Cop) -> String:
	return "" if pulled else "PROMPT_GARDEN_PULL"


func use(cop: Cop) -> void:
	if not pulled:
		tugged.emit(self, cop)


## Holding on and not coming out: a shake.
func shake() -> void:
	var wobble := create_tween()
	wobble.tween_property(self, "rotation:z", SHAKE, 0.06)
	wobble.tween_property(self, "rotation:z", -SHAKE, 0.12)
	wobble.tween_property(self, "rotation:z", 0.0, 0.06)


## Out of its bed: up in the air and gone.
func pull_out() -> void:
	if pulled:
		return
	pulled = true
	growing = false
	collision_layer = 0
	_creak.hide()
	var fly := create_tween()
	fly.tween_property(self, "position:y", position.y + FLY, FLY_TIME).set_ease(Tween.EASE_OUT)
	fly.parallel().tween_property(self, "rotation:x", PI, FLY_TIME)
	fly.tween_callback(hide)


## The magic bean starts growing (GardenPlan, when its turn comes).
func start_growing() -> void:
	if magic and stage == 0:
		growing = true
		grow_left = 0.0


func _physics_process(delta: float) -> void:
	if not growing or stage >= STAGES or follower:
		return
	grow_left -= delta
	if grow_left <= 0.0:
		grow_left = GROW_EVERY
		set_stage(stage + 1)


## The creak is each PC's own (a guest's copy has no physics of its own, step 7).
func _process(delta: float) -> void:
	if growing and not pulled:
		_tick_creak(delta)


## A cop near enough hears it now and then.
func _tick_creak(delta: float) -> void:
	if _creak_shown > 0.0:
		_creak_shown -= delta
		if _creak_shown <= 0.0:
			_creak.hide()
	_creak_left -= delta
	if _creak_left > 0.0 or stage == 0:
		return
	_creak_left = randf_range(CREAK_EVERY.x, CREAK_EVERY.y)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(global_position) <= HEAR:
			_creak.position.y = _height() + 0.3
			_creak.show()
			_creak_shown = CREAK_TIME
			return


func creaking() -> bool:
	return _creak.visible


func _height() -> float:
	return OVER_WALL if stage >= STAGES else HEIGHTS[stage]


## Grows to `to`: the stalk out of the vegetable, the leaves violet from stage 2, and the giant over the wall.
func set_stage(to: int) -> void:
	stage = clampi(to, 0, STAGES)
	if _stalk:
		_stalk.queue_free()
		_stalk = null
	if stage == 0:
		return
	_stalk = Node3D.new()
	_stalk.name = "Stalk"
	add_child(_stalk)
	var leaf := BEAN if stage < 2 else VIOLET
	if stage < STAGES:
		var height := HEIGHTS[stage]
		var radius := 0.02 + 0.03 * stage
		_stalk.add_child(CopTool.piece(CopTool.cylinder(radius, height), BEAN, Vector3(0, height / 2, 0)))
		for i in stage * 2:
			var at := Vector3(0.12 * (1 if i % 2 == 0 else -1), height * (i + 1) / (stage * 2 + 1), 0)
			_stalk.add_child(CopTool.piece(_ball(0.06 + 0.03 * stage, 0.04 + 0.01 * stage), leaf, at))
	else:
		top = _wall_top()
		var base := position
		var up := top - base
		var giant := CopTool.piece(CopTool.cylinder(0.22, up.length()), BEAN)
		giant.basis = Basis(Quaternion(Vector3.UP, up.normalized()))
		giant.position = up / 2
		_stalk.add_child(giant)
		for i in 9:
			var along := up * (i + 1) / 10.0 + Vector3(0.3 * (1 if i % 2 == 0 else -1), 0, 0)
			_stalk.add_child(CopTool.piece(_ball(0.3, 0.12), leaf, along))
		_stalk.add_child(CopTool.piece(_ball(0.6, 0.5), leaf, up))
	_stalk.position.y = 0.05
	var box := (get_child(0) as CollisionShape3D).shape as BoxShape3D
	box.size.y = maxf(SIZE.y, minf(_height(), 2.0))
	(get_child(0) as CollisionShape3D).position.y = box.size.y / 2
	grew.emit(self, stage)


## The nearest stretch of the perimeter wall from here, just over its top (in the parent's space, the prison's).
func _wall_top() -> Vector3:
	var to_east := PrisonLevel.HALF_X - position.x
	var to_south := PrisonLevel.HALF_Z - position.z
	if to_east < to_south:
		return Vector3(PrisonLevel.HALF_X, OVER_WALL, position.z)
	return Vector3(position.x, OVER_WALL, PrisonLevel.HALF_Z)


## What a guest's copy needs (NpcSync, step 7).
func net_state() -> Array:
	return [stage, growing, pulled]


func apply_net_state(state: Variant) -> void:
	growing = state[1]
	if state[2] and not pulled:
		pull_out()
	# NpcSync turns a guest's copy's processing off; the creak is local, so it comes back on while it grows.
	set_process(growing and not pulled)
	if state[0] != stage:
		set_stage(state[0])


static func build_model(of: Kind) -> Node3D:
	var root := Node3D.new()
	root.name = "Model"
	match of:
		Kind.LETTUCE:
			root.add_child(CopTool.piece(_ball(0.16, 0.2), LEAF, Vector3(0, 0.1, 0)))
			root.add_child(CopTool.piece(_ball(0.1, 0.14), LEAF.lightened(0.3), Vector3(0, 0.16, 0)))
		Kind.CARROT:
			for x: float in [-0.05, 0.0, 0.05]:
				root.add_child(CopTool.piece(CopTool.box(Vector3(0.03, 0.25, 0.03)), LEAF, Vector3(x, 0.17, 0),
					Vector3(0, 0, x * 5.0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.05, 0.06), ORANGE, Vector3(0, 0.03, 0)))
		Kind.TOMATO:
			root.add_child(CopTool.piece(CopTool.cylinder(0.015, 0.4), STAKE, Vector3(0, 0.2, 0)))
			root.add_child(CopTool.piece(_ball(0.12, 0.22), LEAF, Vector3(0, 0.22, 0)))
			for at: Vector3 in [Vector3(0.09, 0.2, 0.06), Vector3(-0.07, 0.27, 0.07), Vector3(0.02, 0.14, -0.1)]:
				root.add_child(CopTool.piece(_ball(0.04, 0.08), RED, at))
		Kind.PUMPKIN:
			root.add_child(CopTool.piece(_ball(0.15, 0.2), ORANGE, Vector3(0, 0.1, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.015, 0.06), STAKE, Vector3(0, 0.22, 0)))
			root.add_child(CopTool.piece(_ball(0.1, 0.04), LEAF, Vector3(0.14, 0.05, 0.08)))
	return root


static func _ball(radius: float, height: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	mesh.rings = 5
	return mesh
