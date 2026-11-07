extends BowlingRig

## The shoes on wheels (allanamiento-bolera.md, "Los zapatos con ruedas"): Don Chuza's team wears bowling shoes with
## tiny wheels in the sole, so they glide up to the foul line without a step. The first pair Pipo hands out is one of
## them: the cop wearing it rolls on by itself as soon as it walks, on any floor (the first time, the clue). The box of
## wheeled shoes, a skate taken apart and the manual are hidden. Every number here is (propuesta).

## Which of Pipo's pairs has the wheels, and how the cop in it rolls.
const WHEELED_PAIR := 0
const ROLL_PUSH := 2.5
const ROLL_TIME := 0.5
const ROLL_EVERY := 1.2
## The team on lane 1 glides to the line in this time.
const TEAM_LANE := 0
const GLIDE := 0.3

var noticed := false
## Cop -> seconds until it rolls again.
var _rolled := {}
## Host: where its copy of each guest's cop was last frame (a copy's velocity isn't the guest's walking).
var _last_at := {}


func shared() -> Array[String]:
	return ["noticed"]


func setup(place: Bowling) -> void:
	super.setup(place)
	alley.main = alley.hidden[0]
	for player: BowlPlayer in alley.players:
		if player.lane == TEAM_LANE:
			player.step_up = GLIDE


## Whether `cop` has the wheeled pair on.
func on_wheels(cop: Cop) -> bool:
	return alley.pipo.wearing.get(cop, -1) == WHEELED_PAIR


func _physics_process(delta: float) -> void:
	for cop: Variant in _rolled.keys():
		_rolled[cop] -= delta
		if _rolled[cop] <= 0.0 or not is_instance_valid(cop):
			_rolled.erase(cop)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var mine := is_mine(cop)
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if not mine:
			var at: Vector3 = _last_at.get(cop, cop.global_position)
			_last_at[cop] = cop.global_position
			flat = Vector3(cop.global_position.x - at.x, 0, cop.global_position.z - at.z) / maxf(delta, 0.001)
		if not on_wheels(cop) or flat.length() < 0.5:
			continue
		# The clue is the host's: online its copy of a guest's cop on wheels walking is enough.
		if not noticed and multiplayer.is_server():
			noticed = true
			alley.raid.add_clue(tr("BOWL_WHEELS_CLUE"))
		# Only this PC's own cop rolls away (a copy of another player's cop only follows).
		if not mine or _rolled.has(cop):
			continue
		_rolled[cop] = ROLL_EVERY
		cop.knock_back(flat.normalized() * ROLL_PUSH, ROLL_TIME)
		cop.show_hint("HINT_BOWL_WHEELS")
