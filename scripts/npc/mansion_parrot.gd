class_name MansionParrot
extends MansionPerson

## Lorenzo, doña Clotilde's parrot (escena-mansion.md, "La gente"), on his perch in the brass cage in the lounge. Every
## so often he squawks something he heard in the house; E on him, too. He's the witness (step 5b): give him a chocolate
## from the box and, if he saw it, he repeats what the culprit said ("¡Mis anteojos!" or "¡Qué bien veo!"). Shouted at,
## he's offended for good and only says insults. Every number here is (propuesta).

const CAGE := preload("res://assets/models/parrot_cage.glb")
const BIRD := preload("res://assets/models/loro.glb")
## Seconds between squawks on his own.
const SQUAWK_EVERY := 12.0
## His perch's height in the cage.
const PERCH := 1.25
## A shout counts from this close, in meters.
const SHOUT_REACH := 6.0
const INSULTS := 3

var case: CrimeSceneCase
## The witness is one of the case's clues.
var knows := false
var offended := false
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


func prompt_key(cop: Cop) -> String:
	return "PROMPT_PARROT_FEED" if _chocolates(cop) and not offended else prompt


## E on him: with the box of chocolates in hand, he eats one and tells what he saw; otherwise a squawk.
func use(cop: Cop) -> void:
	var box := _chocolates(cop)
	if box and not offended:
		feed(box)
	else:
		say_next()


func feed(box: DonutBox) -> void:
	if not box.eat_one():
		say("PARROT_LINE_1")
		return
	if knows and case:
		case.found("witness")
		say("PARROT_SAW_GLASSES" if case.culprit().glasses else "PARROT_SAW_NO_GLASSES", 6.0)
	else:
		say("PARROT_SAW_NOTHING")


## Shouted at: offended for good, and the witness is lost.
func offend() -> void:
	if offended:
		return
	offended = true
	line_key = "PARROT_INSULT_"
	lines = INSULTS
	say_next()
	if knows and case:
		case.ruin("witness")


func _chocolates(cop: Cop) -> DonutBox:
	if not cop:
		return null
	var held: Node = cop.get_node("Grabber").held
	return held as DonutBox if held is ChocolateBox else null


func _physics_process(delta: float) -> void:
	super(delta)
	_squawk_left -= delta
	if _squawk_left <= 0.0:
		_squawk_left = SQUAWK_EVERY
		say_next()
