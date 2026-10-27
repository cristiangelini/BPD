class_name TuxedoGuest
extends WeddingPerson

## Tito or one of his five groomsmen (escena-boda.md, "Los seis trajes iguales"): the same rented tuxedo, top hat and
## slicked hair. Under the hat, his own hair (tinted); his glasses, if he wears them; his rented shoes (stretched to his
## size); his teeth (shown when he bites) and his carnation: white for Tito, red for the groomsmen. The cops make his
## file for the board (step 3) with E and what's in hand: the camera's flash (his photo: glasses and shoes), the print
## kit (his prints), a donut or a loaf (he bites it: his teeth). With empty hands: first a sniff up close (his cologne),
## then the top hat comes off (his hair; one won't until he gets something to eat), then his lines. Each goes to his
## file (CrimeSceneCase.guard_part). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_tuxedo.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const RED_CARNATION := Color(0.85, 0.12, 0.18)
const GROOM_LINES := 4
const GROOMSMAN_LINES := 6
## Seconds his teeth show after a bite.
const TEETH_SECONDS := 2.0

## WeddingTraits.draw: name, hair, glasses, shoe, teeth, cologne, groom, stubborn.
var traits := {}
## His place in the case's traits, from 0 (Tito is 0).
var index := 0
var case: CrimeSceneCase
var sniffed := false
var hat_on := true
## He won't take off the top hat until he gets something to eat.
var stubborn := false
var _teeth_left := 0.0


func _ready() -> void:
	model = MODEL
	stubborn = traits.stubborn
	if traits.groom:
		line_key = "WEDDING_GROOM_LINE_"
		lines = GROOM_LINES
	else:
		line_key = "WEDDING_GROOMSMAN_LINE_"
		lines = GROOMSMAN_LINES
	super._ready()
	add_to_group("wedding_tuxedos")
	tint("hair", WeddingTraits.HAIRS[traits.hair])
	if not traits.groom:
		tint("carnation", RED_CARNATION)
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	var size := inverse_lerp(WeddingTraits.SHOE_MIN, WeddingTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)


func prompt_key(cop: Cop) -> String:
	if cop and _food(cop):
		return "PROMPT_TUXEDO_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_GUARD_PRINTS"
	if not sniffed:
		return "PROMPT_TUXEDO_SNIFF"
	if hat_on:
		return "PROMPT_TUXEDO_HAT"
	return "PROMPT_WEDDING_TALK"


## E on him: food in hand, he bites it; with empty hands, a sniff, the top hat and then his lines. (The print kit and
## the camera work on their own: dusted, photographed.)
func use(cop: Cop) -> void:
	var food := _food(cop) if cop else null
	if food:
		feed(food)
	elif not sniffed:
		sniff()
	elif hat_on:
		ask_hat()
	else:
		talk()


## Smelled up close: his cologne for the file.
func sniff() -> void:
	sniffed = true
	say(tr("TUXEDO_SNIFFED") + " " + tr("TUXEDO_SMELLS") % tr("COLOGNE_" + str(traits.cologne)))
	_file("cologne")


## Bites a donut from the box or the loaf: his teeth for the file. A stubborn one takes off the top hat for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("WEDDING_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("GUARD_BITES")
	_file("teeth")
	if stubborn:
		stubborn = false
		_take_off_hat()


func ask_hat() -> void:
	if stubborn:
		say("TUXEDO_HAT_NO")
		return
	_take_off_hat()


func _take_off_hat() -> void:
	hat_on = false
	part("hat").visible = false
	say("TUXEDO_HAT_OFF")
	_file("hair")


## The camera's flash in his face (PhotoCamera): his photo, with his glasses and his shoes.
func photographed(_cop: Cop) -> void:
	say("TUXEDO_PHOTO")
	_file("photo")


## The print kit on him (PrintKit): his prints.
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## Says the next of his lines; a groomsman, with an offset so the six don't all start with the same one.
func talk() -> void:
	say(line_key + str((index + _lines_said) % lines))
	_lines_said += 1


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _teeth_left > 0.0:
		_teeth_left -= delta
		part("teeth").visible = _teeth_left > 0.0


func _food(cop: Cop) -> Node:
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox or held is Bread else null


func _file(what: String) -> void:
	if case:
		case.guard_part(index, what)
