class_name FootballMatch
extends Node

## The charity match (politico-futbol.md, step 3, decision 179), the clock of the case: the players wait in their spots
## until the first cop steps onto the field, then 2 halves of HALF seconds with BREAK seconds between them (everyone
## back to their spots and the ball to the center). The veterans' nearest field player goes for the ball, the rest
## keep their spots; the deputy plays (FootballLustre); the advisors stand. The time shows under the scoreboard.
## `finished` at the end of the second half. Every number here is (propuesta).

signal started
signal half_time
signal finished

enum State { WAITING, FIRST, BREAK, SECOND, OVER }

const HALF := 180.0
const BREAK := 10.0
## The veterans' spots (the pitch's space, from the field's middle): they defend the east goal.
const VETERAN_SPOTS: Array[Vector3] = [Vector3(15, 0, 0), Vector3(10, 0, -6), Vector3(10, 0, 6), Vector3(4, 0, -4),
	Vector3(4, 0, 4), Vector3(-2, 0, 0)]
const VETERAN_LOOKS: Array[String] = ["abuelo", "cliente", "repartidor", "heladero", "armero", "sospechoso"]
## The last of them is the Tank (step 4).
const TANK := 5
const KEEPER_LOOK := "portero"
const ADVISOR_SPOTS: Array[Vector3] = [Vector3(-12, 0, -5), Vector3(-12, 0, 5)]
const ADVISOR_LOOKS: Array[String] = ["gerente", "abogado"]

var pitch: FootballPitch
var lustre: FootballLustre
var players: Array[FootballPlayer] = []
var tank: FootballPlayer
var state := State.WAITING
## Seconds left in this half (or the break).
var left := HALF
## Online, a guest's: the host's runs the clock.
var follower := false
var _clock: Label


func setup(the_pitch: FootballPitch, the_lustre: FootballLustre) -> void:
	pitch = the_pitch
	lustre = the_lustre
	for i in VETERAN_SPOTS.size():
		var tank_now := i == TANK
		_player("Tank" if tank_now else "Veteran%d" % i, "tank" if tank_now else "veteran", FootballScore.Team.VETERANS,
			VETERAN_LOOKS[i], VETERAN_SPOTS[i])
	_player("Keeper", "keeper", FootballScore.Team.VETERANS, KEEPER_LOOK,
		FootballPitch.goal_at(1.0) - FootballPitch.CENTER - Vector3(FootballPlayer.KEEPER_OUT, 0, 0))
	for i in ADVISOR_SPOTS.size():
		_player("Advisor%d" % i, "advisor", FootballScore.Team.LUSTRE, ADVISOR_LOOKS[i], ADVISOR_SPOTS[i])


func _player(player_name: String, role: String, team: int, look: String, spot: Vector3) -> void:
	var player := FootballPlayer.new()
	player.name = player_name
	player.role = role
	player.team = team
	player.look = look
	player.pitch = pitch
	player.home = FootballPitch.CENTER + spot
	player.position = player.home + Vector3.UP * 0.05
	# Facing the other goal.
	player.rotation.y = -PI / 2 if team == FootballScore.Team.LUSTRE else PI / 2
	pitch.add_child(player)
	players.append(player)
	if role == "tank":
		tank = player


func _ready() -> void:
	var hud := CanvasLayer.new()
	hud.name = "ClockHud"
	_clock = Label.new()
	_clock.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_clock.offset_top = 50.0
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clock.add_theme_constant_override("outline_size", 6)
	hud.add_child(_clock)
	add_child(hud)


func start() -> void:
	if state != State.WAITING:
		return
	state = State.FIRST
	left = HALF
	_play(true)
	started.emit()


func _physics_process(delta: float) -> void:
	_show()
	if follower:
		return
	match state:
		State.WAITING:
			for cop: Node3D in get_tree().get_nodes_in_group("cops"):
				if pitch.on_field(cop.global_position):
					start()
					return
		State.FIRST, State.SECOND:
			left -= delta
			_pick_chaser()
			if left <= 0.0:
				_end_half()
		State.BREAK:
			left -= delta
			if left <= 0.0:
				state = State.SECOND
				left = HALF
				_play(true)


func _end_half() -> void:
	_play(false)
	if state == State.FIRST:
		state = State.BREAK
		left = BREAK
		_back_to_spots()
		half_time.emit()
		for cop in get_tree().get_nodes_in_group("cops"):
			(cop as Cop).show_hint("HINT_FOOTBALL_HALF_TIME")
	else:
		state = State.OVER
		left = 0.0
		finished.emit()


func _play(on: bool) -> void:
	for player in players:
		player.playing = on
		player.chaser = false
	lustre.playing = on
	if pitch.referee:
		pitch.referee.playing = on


func _back_to_spots() -> void:
	for player in players:
		player.global_position = pitch.to_global(player.home + Vector3.UP * 0.05)
		player.velocity = Vector3.ZERO
	pitch.score.put_ball(pitch.score.center())


## The veterans' field player nearest the ball goes for it.
func _pick_chaser() -> void:
	var best: FootballPlayer = null
	var ball := pitch.ball.global_position
	for player in players:
		player.chaser = false
		if (player.role == "veteran" or player.role == "tank" and not player.charging) and (best == null or player.global_position.distance_to(ball)
				< best.global_position.distance_to(ball)):
			best = player
	if best:
		best.chaser = true


## Seconds played in the match so far.
func played() -> float:
	match state:
		State.FIRST:
			return HALF - left
		State.BREAK:
			return HALF
		State.SECOND:
			return HALF * 2 - left
		State.OVER:
			return HALF * 2
	return 0.0


func _show() -> void:
	if _clock == null:
		return
	match state:
		State.WAITING:
			_clock.text = "HUD_FOOTBALL_WAITING"
		State.BREAK:
			_clock.text = "HUD_FOOTBALL_BREAK"
		State.OVER:
			_clock.text = "HUD_FOOTBALL_OVER"
		_:
			var seconds := ceili(maxf(left, 0.0))
			_clock.text = tr("HUD_FOOTBALL_CLOCK") % [1 if state == State.FIRST else 2, seconds / 60, seconds % 60]
