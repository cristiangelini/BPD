class_name MansionParrot
extends MansionPerson

## Lorenzo, doña Clotilde's parrot (escena-mansion.md, "La gente"), on his perch in the brass cage in the lounge. Every
## so often he squawks something he heard in the house; E on him, too. The witness comes with the case (step 5).
## Every number here is (propuesta).

const CAGE := preload("res://assets/models/parrot_cage.glb")
const BIRD := preload("res://assets/models/loro.glb")
## Seconds between squawks on his own.
const SQUAWK_EVERY := 12.0
## His perch's height in the cage.
const PERCH := 1.25

var _squawk_left := SQUAWK_EVERY


func _init() -> void:
	model = CAGE
	height = 2.0
	prompt = "PROMPT_MANSION_PARROT"
	line_key = "PARROT_LINE_"
	lines = 4


func _ready() -> void:
	super()
	add_to_group("mansion_parrot")
	var bird := BIRD.instantiate()
	bird.name = "Lorenzo"
	bird.position = Vector3(0, PERCH, 0)
	add_child(bird)


func _physics_process(delta: float) -> void:
	super(delta)
	_squawk_left -= delta
	if _squawk_left <= 0.0:
		_squawk_left = SQUAWK_EVERY
		say_next()
