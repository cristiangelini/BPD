extends BowlingRig

## The magnet ball (allanamiento-bolera.md, "La bola con imán"): Don Chuza's team wins with a golden ball that has a
## magnet inside and a remote that knocks the pins down. One ball on the racks has a bit of that magnet: near the
## alley's metal bin it's pulled toward it and sticks with a «¡Clonc!» (the first time, the clue). And lane 1's pins
## fall by themselves when the league bowls there, before the ball gets to them. The golden ball, the remote and the
## bet list are hidden. Every number here is (propuesta).

## The metal bin, on the approach east of lane 6, and the pull of the magnetic ball near it.
const BIN_AT := Vector3(-3.4, Bowling.FLOOR_TOP, 6.6)
const BIN_SIZE := Vector3(0.42, 0.62, 0.42)
const PULL_RANGE := 1.2
const PULL := 40.0
const STICK := 0.4
## Lane 1's pins go down when a league ball is this far from them.
const REMOTE_LANE := 0
const REMOTE_AHEAD := 2.5
const PIN_PUSH := 0.4
const PIN_TIP := 0.3

var magnetic: BowlingBall
var stuck := false
var _knocked_for: BowlingBall


func shared() -> Array[String]:
	return ["stuck"]


func setup(place: Bowling) -> void:
	super.setup(place)
	alley.main = alley.hidden[0]
	magnetic = alley.balls[alley.case_seed % alley.balls.size()]
	var bin: Node3D = preload("res://assets/models/metal_bin.glb").instantiate()
	bin.position = BIN_AT
	alley.get_node("Built").add_child(bin)
	alley._solid(BIN_AT + Vector3(0, BIN_SIZE.y / 2, 0), BIN_SIZE)


func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server():
		return
	_pull()
	_remote()


## The magnetic ball near the bin is pulled toward it, and the first time it touches it, the clue.
func _pull() -> void:
	var to := alley.to_global(BIN_AT + Vector3.UP * BowlingBall.RADIUS) - magnetic.global_position
	to.y = 0.0
	var distance := to.length()
	if distance > PULL_RANGE:
		return
	magnetic.apply_central_force(to.normalized() * PULL)
	if distance < BIN_SIZE.x / 2 + STICK and not stuck:
		stuck = true
		alley._say(BIN_AT + Vector3.UP * 1.2, "BOWL_MAGNET_CLONC")
		alley.raid.add_clue(tr("BOWL_MAGNET_CLUE"))


## A league ball on lane 1 halfway to the pins: they all go down before it gets there.
func _remote() -> void:
	for player: BowlPlayer in alley.players:
		var ball := player.ball
		if player.lane != REMOTE_LANE or not ball or ball == _knocked_for:
			continue
		if alley.to_local(ball.global_position).z > Bowling.HEAD_PIN_Z + REMOTE_AHEAD:
			continue
		_knocked_for = ball
		knock_pins()


## Every pin of lane 1 tips back, as if something pulled them.
func knock_pins() -> void:
	for pin: RigidBody3D in alley.pins[REMOTE_LANE]:
		pin.sleeping = false
		pin.apply_central_impulse(alley.global_basis * Vector3(0, 0, -PIN_PUSH))
		pin.apply_torque_impulse(alley.global_basis * Vector3(-PIN_TIP, 0, 0))
