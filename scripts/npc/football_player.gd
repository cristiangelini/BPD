class_name FootballPlayer
extends CharacterBody3D

## Someone else on the pitch (politico-futbol.md, step 3, decision 179): a veteran of Los Veteranos del Barrio in a red
## bib, their goalkeeper, or one of the deputy's two advisors in a suit and a yellow bib, who don't run. FootballMatch
## says when they play and which veteran goes for the ball (`chaser`); the others keep to their spot (`home`, the
## pitch's space), moved along with the ball. A veteran with the ball at their feet kicks it toward the west goal; the
## keeper walks along the east goal's line and stops what comes slow enough; an advisor with the ball at their feet
## pushes it forward. Every number here is (propuesta).

const SAY_TIME := 3.0
const SPEEDS := {"veteran": 3.0, "keeper": 3.2, "advisor": 1.2}
## How far a field player's spot moves with the ball (share of the ball's x), and how close to it is "there".
const FOLLOW := 0.35
const THERE := 0.4
## A veteran's kick: power (m/s) and how far off the goal's middle it may go (m).
const SHOT := Vector2(11.0, 15.0)
const SPREAD := 3.5
const KICK_WAIT := 0.8
## The keeper: off the line by this much, along it within this much, and the slowest shot that beats him.
const KEEPER_OUT := 0.8
const KEEPER_SPAN := 2.6
const SAVE_REACH := 1.3
const SAVE_SPEED := 12.0
## A clearance or an advisor's push forward.
const CLEAR := Vector2(9.0, 4.0)
const PUSH := 8.0
const BIBS := {FootballScore.Team.LUSTRE: Color(0.98, 0.85, 0.15), FootballScore.Team.VETERANS: Color(0.88, 0.2, 0.2)}

@export var look := "abuelo"
## "veteran", "keeper" or "advisor".
var role := "veteran"
var team: int = FootballScore.Team.VETERANS
var pitch: FootballPitch
var home := Vector3.ZERO
var playing := false
## The one veteran going for the ball now (FootballMatch).
var chaser := false
## A guest's copy (NpcSync): the host's plays.
var follower := false
var _kick_wait := 0.0
var _rng := RandomNumberGenerator.new()
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("football_players")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = load("res://assets/models/npc_%s.glb" % look).instantiate()
	_model.name = "Model"
	# The models face +Z; they face -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	add_child(bib(BIBS[team]))
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)
	_rng.seed = hash(["football player", name])


## A team's bib over the belly of a pear-shaped body.
static func bib(color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.43
	mesh.bottom_radius = 0.5
	mesh.height = 0.42
	mesh.radial_segments = 12
	var vest := MeshInstance3D.new()
	vest.name = "Bib"
	vest.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	vest.material_override = material
	vest.position.y = 0.78
	return vest


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	_kick_wait = maxf(_kick_wait - delta, 0.0)
	if not playing or follower or pitch == null:
		_go(Vector3.ZERO)
		return
	match role:
		"keeper":
			_keep()
		"advisor":
			_advise()
		_:
			_play()


func _play() -> void:
	var ball := pitch.ball
	var target := pitch.to_global(home + Vector3(pitch.to_local(ball.global_position).x * FOLLOW, 0, 0))
	if chaser:
		target = ball.global_position
	if ball.at_feet(self) and _kick_wait <= 0.0:
		var goal := pitch.to_global(FootballPitch.goal_at(-1.0) + Vector3(0, 0.3, _rng.randf_range(-SPREAD, SPREAD)))
		_kick((goal - ball.global_position).normalized() + Vector3.UP * 0.1, _rng.randf_range(SHOT.x, SHOT.y))
	_walk_to(target)


func _keep() -> void:
	var ball := pitch.ball
	var local := pitch.to_local(ball.global_position)
	var line := FootballPitch.goal_at(1.0)
	var spot := Vector3(line.x - KEEPER_OUT, 0, clampf(local.z, line.z - KEEPER_SPAN, line.z + KEEPER_SPAN))
	_walk_to(pitch.to_global(spot))
	if _kick_wait <= 0.0 and ball.global_position.distance_to(global_position + Vector3.UP * 0.5) < SAVE_REACH \
			and not ball.is_held():
		if ball.linear_velocity.length() < SAVE_SPEED:
			say("FOOTBALL_KEEPER_SAVE")
			var away := pitch.global_basis.x * -1.0
			_kick((away * CLEAR.x + pitch.global_basis.z * _rng.randf_range(-3, 3) + Vector3.UP * CLEAR.y).normalized(),
				CLEAR.length())


func _advise() -> void:
	var ball := pitch.ball
	if ball.at_feet(self) and _kick_wait <= 0.0:
		_kick((pitch.global_basis.x + Vector3.UP * 0.05).normalized(), PUSH)
		say("FOOTBALL_ADVISOR_PUSH")
	_walk_to(pitch.to_global(home))


func _kick(direction: Vector3, power: float) -> void:
	_kick_wait = KICK_WAIT
	pitch.ball.kick(self, direction, power)


func _walk_to(at: Vector3) -> void:
	var to := at - global_position
	to.y = 0.0
	if to.length() < THERE:
		_go(Vector3.ZERO)
		_face(pitch.ball.global_position)
		return
	_go(to.normalized() * float(SPEEDS[role]))


func _go(wish: Vector3) -> void:
	if wish.length() > 0.05:
		look_at(global_position + wish, Vector3.UP)
	velocity.x = wish.x
	velocity.z = wish.z
	move_and_slide()


func _face(at: Vector3) -> void:
	var flat := Vector3(at.x, global_position.y, at.z)
	if flat.distance_to(global_position) > 0.1:
		look_at(flat, Vector3.UP)


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
