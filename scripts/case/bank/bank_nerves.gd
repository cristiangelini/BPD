class_name BankNerves
extends Node3D

## El Conejo's nerves in the town bank (robo-banco-pueblo.md, step 3, decision 127), a child of the robber, its bar
## over his head (green to red). They go from 0 to MAX: up NOISE with each noise he hears (a cop running within
## NOISE_REACH, the siren near, something falling hard; BankClerk.noise_at, once every LISTEN_EVERY), up SHOUT each
## time don Plácido shouts, up SCARE when he sees a cop, down CALM a second in silence; a promise kept on the phone
## takes KEPT off and a lie adds LIED. He holds the drill himself: from PEEK up he lets go of it and turns to peek at
## the corridor's door for PEEK_TIME (the drill stands still meanwhile). At MAX he bolts: out through the hall to the
## van (`bolted`; step 4 starts the getaway). Seeing a cop he gives up, as the base's rabbit, unless his nerves were
## already at BOLT_SCARED: then the fright makes him bolt instead. Online the host's decide (`follower`). Every number
## here is (propuesta).

signal bolted(robber: BankRobber)

const MAX := 100.0
const NOISE := 10.0
const NOISE_REACH := 8.0
const SIREN_REACH := 20.0
const LISTEN_EVERY := 1.0
const SHOUT := 20.0
const SCARE := 30.0
const CALM := 2.0
const KEPT := 30.0
const LIED := 20.0
const PEEK := 50.0
const PEEK_TIME := 8.0
## After a peek he goes back to the drill for at least this long before peeking again.
const PEEK_AGAIN := 6.0
const BOLT_SCARED := 70.0
## The bar over his head: its size and how high.
const BAR := Vector2(0.6, 0.07)
const BAR_HEIGHT := 2.05

var nerves := 0.0
var peek_left := 0.0
var bolting := false
var follower := false
var robber: BankRobber
var drill: BankDrill
var car: PatrolCar
var _listen_left := 0.0
var _peek_again := 0.0
var _home_yaw := 0.0
var _fill: MeshInstance3D
var _fill_mat: StandardMaterial3D


## Hooks him to the robber, the drill, the patrol car (its siren), don Plácido's shouts and the phone.
func setup(the_robber: BankRobber, the_drill: BankDrill, patrol_car: PatrolCar, clerk: BankClerk,
		phone: BankPhone) -> void:
	robber = the_robber
	drill = the_drill
	car = patrol_car
	_home_yaw = robber.rotation.y
	robber.spotted.connect(_on_spotted)
	if clerk:
		clerk.shouted.connect(func(_clerk: BankClerk, _why: String) -> void: add(SHOUT))
	if phone:
		phone.kept.connect(func(_request: String) -> void: add(-KEPT))
		phone.lied.connect(func(_request: String) -> void: add(LIED))


func _ready() -> void:
	name = "Nerves"
	position.y = BAR_HEIGHT
	var back := MeshInstance3D.new()
	var back_mesh := QuadMesh.new()
	back_mesh.size = BAR + Vector2(0.04, 0.04)
	back.mesh = back_mesh
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.1, 0.1, 0.1)
	dark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dark.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	back.material_override = dark
	add_child(back)
	_fill = MeshInstance3D.new()
	var fill_mesh := QuadMesh.new()
	fill_mesh.size = BAR
	_fill.mesh = fill_mesh
	_fill_mat = StandardMaterial3D.new()
	_fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_fill_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_fill_mat.billboard_keep_scale = true
	_fill_mat.render_priority = 1
	_fill.material_override = _fill_mat
	add_child(_fill)
	_show()


## Nerves up (or down, `points` < 0); at MAX he bolts.
func add(points: float) -> void:
	if follower or bolting or robber.is_cuffed():
		return
	nerves = clampf(nerves + points, 0.0, MAX)
	if nerves >= MAX:
		bolt()


func peeking() -> bool:
	return peek_left > 0.0


## Off he runs: through the hall and out to the van.
func bolt() -> void:
	if bolting:
		return
	bolting = true
	nerves = MAX
	peek_left = 0.0
	robber.rotation.y = _home_yaw
	robber.surrendered = false
	robber.say("ROBBER_CONEJO_BOLT")
	robber.running = true
	bolted.emit(robber)


## What a guest's bar shows (NpcSync turns and moves him): his nerves, and whether he bolted.
func net_state() -> Array:
	return [nerves, bolting]


func apply_net_state(state: Array) -> void:
	nerves = state[0]
	bolting = state[1]
	_show()


func _on_spotted(_robber: BankRobber, _cop: Node3D) -> void:
	if follower or bolting:
		return
	if nerves >= BOLT_SCARED:
		bolt()
		return
	add(SCARE)


func _physics_process(delta: float) -> void:
	_show()
	if follower or bolting or robber.is_cuffed():
		return
	_listen_left -= delta
	if _listen_left <= 0.0:
		_listen_left = LISTEN_EVERY
		if BankClerk.noise_at(robber, NOISE_REACH, SIREN_REACH, BankClerk.WAKE_FALL, car) != "":
			add(NOISE)
			if bolting:
				return
	nerves = maxf(nerves - CALM * delta, 0.0)
	_peek_again = maxf(_peek_again - delta, 0.0)
	if peeking():
		peek_left -= delta
		# He's not holding the drill.
		drill.paused_left = maxf(drill.paused_left, delta * 2.0)
		if peek_left <= 0.0:
			robber.rotation.y = _home_yaw
			_peek_again = PEEK_AGAIN
	elif nerves >= PEEK and _peek_again <= 0.0 and not robber.surrendered:
		peek_left = PEEK_TIME
		robber.rotation.y = _home_yaw + PI
		robber.say("ROBBER_CONEJO_PEEK")


func _show() -> void:
	if not _fill:
		return
	var part := nerves / MAX
	_fill.scale.x = maxf(part, 0.001)
	_fill_mat.albedo_color = Color(0.3, 0.8, 0.3).lerp(Color(0.9, 0.2, 0.2), part)
	visible = robber != null and robber.visible and not robber.is_cuffed()
