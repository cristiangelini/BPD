class_name FixedMatchRig
extends RinkRig

## The fixed match (allanamiento-pista.md, "El partido arreglado"): Doña Pirueta fixes the Saturday hockey matches
## with a remote for the scoreboard and takes the bets. The scoreboard over the ice changes the score on its own: every
## GOAL_EVERY seconds it adds a goal to one of the teams, and nobody is playing. The first goal a cop sees (one within
## SEE_RANGE of it) is the story's own clue, on the checklist. Every number here is (propuesta).

const GOAL_EVERY := 20.0
const SEE_RANGE := 18.0
## Where the two scores show, on the scoreboard's red panels (rink space).
const HOME_AT := Vector3(-0.8, 5.8, Rink.ICE_Z0 + 0.67)
const AWAY_AT := Vector3(0.8, 5.8, Rink.ICE_Z0 + 0.67)

var home := 0
var away := 0
var goals := 0
var seen := false
var home_label: Label3D
var away_label: Label3D
var _since := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: Rink) -> void:
	super.setup(place)
	_rng.seed = rink.case_seed * 31 + 7
	home_label = _digits(HOME_AT)
	away_label = _digits(AWAY_AT)
	_show()


func _digits(at: Vector3) -> Label3D:
	var label := Label3D.new()
	label.position = at
	label.pixel_size = 0.01
	label.font_size = 64
	label.outline_size = 0
	label.modulate = Color(1.0, 0.9, 0.8)
	rink.add_child(label)
	return label


func _show() -> void:
	home_label.text = str(home)
	away_label.text = str(away)


## Online the host's scoreboard scores, and the guests' shows it (Rink.net_state).
func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	_since += delta
	if _since >= GOAL_EVERY:
		goal()


## A goal for one of the teams, out of nowhere; the first one a cop sees is a clue.
func goal() -> void:
	_since = 0.0
	goals += 1
	var for_home := _rng.randi() % 2 == 0
	if for_home:
		home += 1
	else:
		away += 1
	_show()
	_cheer(for_home)
	if not seen and _a_cop_sees():
		seen = true
		rink.raid.add_clue(tr("CLUE_SCORE_CHANGES"))


func _cheer(for_home: bool) -> void:
	var at := rink.to_global((HOME_AT if for_home else AWAY_AT) + Vector3(0, 1.0, 0.3))
	rink.raid.float_label(tr("RINK_GOAL"), at, Color(1.0, 0.85, 0.2))


func net_state() -> Array:
	return [home, away, goals, seen]


func apply_net_state(state: Array) -> void:
	if state[2] > goals:
		_cheer(state[0] > home)
	home = state[0]
	away = state[1]
	goals = state[2]
	seen = state[3]
	_show()


func _a_cop_sees() -> bool:
	var board := rink.to_global((HOME_AT + AWAY_AT) / 2)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(board) <= SEE_RANGE:
			return true
	return false
