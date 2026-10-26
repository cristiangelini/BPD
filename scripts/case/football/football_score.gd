class_name FootballScore
extends Node

## The goals and the scoreboard (politico-futbol.md, step 2, decision 179): the deputy's team attacks the east goal and
## the veterans the west one. The whole ball over a goal line, between the posts and under the bar, is a goal for the
## team attacking it (`scored`, with who touched it last); GOAL_PAUSE seconds later the ball is back on the center
## spot. A ball out over a touchline or a goal line comes back in after OUT_PAUSE seconds where it went out, a meter
## inside. A cop picking it up with their hands is a handball (`handball`). The scoreboard shows at the top of the
## screen. Online only the host's decides (step 6). Every number here is (propuesta).

signal scored(team: int, by: Node3D)
signal handball(cop: Cop)

## The teams: the deputy's and the veterans'.
enum Team { LUSTRE, VETERANS }

const GOAL_PAUSE := 3.0
const OUT_PAUSE := 1.0
## How far out a ball must be to count as out (m past the line).
const OUT_MARGIN := 0.5

var pitch: FootballPitch
var ball: FootballBall
## Goals per team (Team index).
var goals := [0, 0]
## Seconds until the ball is put back (after a goal or out); 0 when it's in play.
var restart_left := 0.0
var _restart_at := Vector3.ZERO
var _label: Label


func setup(the_pitch: FootballPitch, the_ball: FootballBall) -> void:
	pitch = the_pitch
	ball = the_ball
	ball.handled.connect(func(cop: Cop) -> void: handball.emit(cop))


func _ready() -> void:
	var hud := CanvasLayer.new()
	hud.name = "ScoreHud"
	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_label.offset_top = 12.0
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 28)
	_label.add_theme_constant_override("outline_size", 8)
	hud.add_child(_label)
	add_child(hud)
	_show()


## Where the center spot is, in the world.
func center() -> Vector3:
	return pitch.to_global(FootballPitch.CENTER + Vector3.UP * (FootballBall.RADIUS + 0.1))


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server() or ball == null:
		return
	if restart_left > 0.0:
		restart_left -= delta
		if restart_left <= 0.0:
			put_ball(_restart_at)
		return
	if ball.is_held():
		return
	var local := pitch.to_local(ball.global_position) - FootballPitch.CENTER
	var past := absf(local.x) - FootballPitch.HALF_LENGTH
	if past > FootballBall.RADIUS and absf(local.z) < FootballPitch.GOAL.x / 2 and local.y < FootballPitch.GOAL.y:
		goal(Team.LUSTRE if local.x > 0.0 else Team.VETERANS)
	elif past > OUT_MARGIN or absf(local.z) - FootballPitch.HALF_WIDTH > OUT_MARGIN:
		var back := Vector3(clampf(local.x, -FootballPitch.HALF_LENGTH + 1.0, FootballPitch.HALF_LENGTH - 1.0), 0,
			clampf(local.z, -FootballPitch.HALF_WIDTH + 1.0, FootballPitch.HALF_WIDTH - 1.0))
		restart_left = OUT_PAUSE
		_restart_at = pitch.to_global(FootballPitch.CENTER + back + Vector3.UP * (FootballBall.RADIUS + 0.1))


## A goal for `team`: counted, and the ball back on the center spot GOAL_PAUSE later.
func goal(team: int) -> void:
	goals[team] += 1
	restart_left = GOAL_PAUSE
	_restart_at = center()
	_show()
	scored.emit(team, ball.last_touch)
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_FOOTBALL_GOAL_LUSTRE" if team == Team.LUSTRE else "HINT_FOOTBALL_GOAL_VETERANS")


## The ball still at `at`, in play.
func put_ball(at: Vector3) -> void:
	restart_left = 0.0
	ball.global_position = at
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO


func _show() -> void:
	if _label:
		_label.text = tr("HUD_FOOTBALL_SCORE") % [goals[Team.LUSTRE], goals[Team.VETERANS]]
