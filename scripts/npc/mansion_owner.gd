class_name MansionOwner
extends MansionPerson

## Doña Clotilde Candelabro (escena-mansion.md, "La gente"): the owner, rich and president of the Mystery Club, who
## goes round the front rooms in her motorized wheelchair (hall, dining room, hall, lounge and back) saying who's going
## to be left out of the will; E on her, too. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_dona_clotilde.glb")
const SPEED := 0.8
## Seconds between the lines she says on her own as she goes.
const TALK_EVERY := 10.0
## Her round, in the mansion's space: through the hall's side doors into each front room and back.
const ROUTE: Array[Vector3] = [
	Vector3(1.5, 0, 7.5), Vector3(-5.0, 0, 7.0), Vector3(-7.0, 0, 9.5), Vector3(-14.0, 0, 9.5), Vector3(-7.0, 0, 9.5),
	Vector3(-5.0, 0, 7.0), Vector3(1.5, 0, 7.5), Vector3(5.0, 0, 7.0), Vector3(8.0, 0, 5.0), Vector3(13.0, 0, 5.0),
	Vector3(8.0, 0, 5.0), Vector3(5.0, 0, 7.0),
]

## The next point of her round.
var next := 1
var _talk_left := TALK_EVERY


func _init() -> void:
	model = MODEL
	prompt = "PROMPT_MANSION_OWNER"
	line_key = "CLOTILDE_LINE_"
	lines = 5


func _ready() -> void:
	super()
	add_to_group("mansion_owner")


func _physics_process(delta: float) -> void:
	super(delta)
	var target := ROUTE[next] + Vector3(0, position.y, 0)
	var to := target - position
	var step := SPEED * delta
	if to.length() <= step:
		position = target
		next = (next + 1) % ROUTE.size()
	else:
		position += to.normalized() * step
		rotation.y = atan2(to.x, to.z)
	_talk_left -= delta
	if _talk_left <= 0.0:
		_talk_left = TALK_EVERY
		say_next()
