class_name RiggedGamesRig
extends FairRig

## The rigged games (allanamiento-parque.md, "Los juegos amañados"): nobody ever wins at La Vuelta Loca because of a
## giant magnet at the foot of the cans booth's counter. It's the main evidence (8 kg, two of you). While it's there the
## cans never fall, so Nube has nothing to tell, the booth's balls swerve down to the floor and the strength tester's
## mallet creeps towards the booth, the story's own clue (on the checklist the first time it has moved). Carried away
## from the booth, it lets go of everything. The glued cans and the manual are hidden. Every number here is (propuesta).

const MAGNET_SCENE := preload("res://scenes/props/fair_magnet.tscn")
## On the ground at the foot of the cans booth's counter, half under its edge.
const MAGNET_AT := Fair.CANS_AT + Vector3(0.9, 0.09, 1.3)
## Farther than this from its spot, the magnet no longer reaches the booth.
const REACH := 2.5
## Metal this close to the booth is pulled towards it (N), and a moving ball in it down to the floor (m/s²).
const PULL_RANGE := 9.0
const PULL := 60.0
const BALL_DOWN := 25.0
## The mallet moved this far by itself is the clue.
const CREPT := 0.5

var magnet: Evidence
var active := true
var crept := false
var _mallet_home: Vector3


func setup(place: Fair) -> void:
	super.setup(place)
	magnet = MAGNET_SCENE.instantiate()
	magnet.name = "Magnet"
	magnet.position = MAGNET_AT
	place.add_child(magnet)
	place.main = magnet
	_mallet_home = place.tester.mallet.position
	_grip(true)


func _physics_process(_delta: float) -> void:
	if not active:
		return
	if fair.to_local(magnet.global_position).distance_to(MAGNET_AT) > REACH:
		active = false
		_grip(false)
		fair.raid.float_label(tr("FAIR_MAGNET_OFF"), fair.to_global(Fair.CANS_AT + Vector3(0, 2.4, 0)),
			Color(0.6, 0.85, 1.0))
		return
	# Online the host pulls and the guests' balls and mallet only follow it (PropSync).
	if not multiplayer.is_server():
		return
	var booth := fair.to_global(MAGNET_AT)
	for ball in fair.cans_booth.balls:
		if not ball.is_held() and ball.linear_velocity.length() > 1.0 and ball.global_position.distance_to(booth) < 4.0:
			ball.apply_central_force(Vector3.DOWN * ball.mass * BALL_DOWN)
	var mallet := fair.tester.mallet
	if mallet.is_held():
		return
	var to := booth - mallet.global_position
	to.y = 0.0
	if to.length() < PULL_RANGE and to.length() > 1.0:
		mallet.sleeping = false
		mallet.apply_central_force(to.normalized() * PULL)
	if not crept and mallet.let_go_at < 0 and mallet.position.distance_to(_mallet_home) > CREPT:
		crept = true
		fair.raid.add_clue(tr("CLUE_MALLET_CREEPS"))


## The cans stuck to the shelf while the magnet holds them, or loose again (online, a guest's cans stay frozen).
func _grip(hold: bool) -> void:
	for can in fair.cans_booth.cans:
		can.freeze = hold or not multiplayer.is_server()
