class_name TvMakeupWalk
extends PoliticianWalks

## Lustre's trips to the makeup room (politico-debate.md, step 6, decision 230): at every ad break he leaves his
## lectern for the mirror in the makeup room, sits there MAKEUP seconds and walks back slowly, so on his own he's late
## for the next block (TvDebate counts it as a blunder). E takes him by the hand like at the plaza (PoliticianWalks)
## and, led near his lectern, he goes back to it; let go anywhere else, he goes back to the mirror. It hangs off the
## politician as "Walks". Every number here is (propuesta).

const MAKEUP := 8.0
const LINES := 3

## Through the makeup room's door to the mirror, in world space.
var to_mirror: Array[Vector3] = []
var _done := false
var _trip := 0


static func attach_to(speaker: Politician, spot: Vector3, path: Array[Vector3]) -> TvMakeupWalk:
	var walks := TvMakeupWalk.new()
	walks.name = "Walks"
	walks.politician = speaker
	walks.podium = spot
	walks.to_mirror = path
	walks.auto_walks = false
	speaker.add_child(walks)
	return walks


## The ad break: off to the mirror.
func walk_off() -> void:
	if state != State.SPEAKING:
		return
	_done = false
	politician.say("TV_LUSTRE_MAKEUP_%d" % (_trip % LINES + 1))
	_trip += 1
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_LUSTRE_MAKEUP")
	walked_off.emit()
	_greet_next()


## At the mirror (the "greeting"), and what comes after it: back to the lectern once made up, else to the mirror.
func _greet_next() -> void:
	_path.clear()
	if _done or (state == State.GREETING and _at_mirror()):
		_done = true
		state = State.RETURNING
		for i in range(to_mirror.size() - 2, -1, -1):
			_path.append(to_mirror[i])
		_path.append(podium)
		politician.say("TV_LUSTRE_MADE_UP")
		return
	state = State.WALKING
	_path.assign(to_mirror)


func _physics_process(delta: float) -> void:
	if state != State.WALKING:
		super(delta)
		return
	if _follow_path(delta):
		state = State.GREETING
		_greet_left = MAKEUP
		politician.say("TV_LUSTRE_MIRROR")


func _at_mirror() -> bool:
	var at := politician.global_position
	var mirror := to_mirror[-1]
	return Vector2(at.x - mirror.x, at.z - mirror.z).length() < ARRIVED * 2


## Away from his lectern: walking off, at the mirror, led or coming back.
func away() -> bool:
	return state != State.SPEAKING
