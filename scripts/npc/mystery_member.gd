class_name MysteryMember
extends MansionPerson

## One of the six members of the Mystery Club (escena-mansion.md, "Los socios iguales y sus fichas"), dressed as
## Detective Pipa like the other five: the checked cape, the deerstalker, the magnifying glass and the bubble pipe.
## Under the cap, their own hair (tinted); their glasses, if they wear them; their shoes (stretched to their size).
## The cops make their file (step 4) with E and what's in hand: the camera's flash (their photo: glasses and shoes),
## the print kit (their prints), a chocolate from doña Clotilde's box (they bite it: their teeth). With empty hands:
## first where they were at midnight (their alibi, a different opening each time), then the cap comes off (their
## hair; one won't until they get a chocolate). Each part given goes out by part_given, for the case's file (step 5).
## Every so often one goes through a secret passage to another room (Mansion.send_through): `room` is where they are
## now, not their alibi. Every number here is (propuesta).

## A part of their file was given: photo, prints, teeth, hair or midnight (their alibi).
signal part_given(index: int, part: String)

const MODEL := preload("res://assets/models/npc_socio_club.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 6
## Seconds their teeth show after a bite.
const TEETH_SECONDS := 2.0
## Meters a second along the way through a passage.
const WALK_SPEED := 1.6

## MemberTraits.draw: name, hair, glasses, shoe, teeth, room.
var traits := {}
## Their place in the case's order of traits.
var index := 0
var told_alibi := false
var cap_on := true
## They won't take off the cap until they get a chocolate.
var stubborn := false
## The parts of their file they already gave.
var given: Array[String] = []
## The room they're in now (Mansion.ROOMS); "" while in a passage.
var room := ""
## Their walk through a passage, while it lasts.
var walk: Tween
var _teeth_left := 0.0


func _init() -> void:
	model = MODEL
	prompt = "PROMPT_MANSION_MEMBER"


func _ready() -> void:
	super()
	add_to_group("mansion_members")
	var material := StandardMaterial3D.new()
	material.albedo_color = MemberTraits.HAIRS[traits.hair]
	for mesh in part("hair").find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	var size := inverse_lerp(MemberTraits.SHOE_MIN, MemberTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)


func prompt_key(cop: Cop) -> String:
	if _chocolates(cop):
		return "PROMPT_MEMBER_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_MEMBER_PRINTS"
	if told_alibi and cap_on:
		return "PROMPT_MEMBER_CAP"
	return prompt


## E on them: a chocolate in hand, they bite it; with empty hands, their alibi, the cap and then the alibi again.
## (The print kit and the camera work on their own: dusted, photographed.)
func use(cop: Cop) -> void:
	var box := _chocolates(cop)
	if box:
		feed(box)
	elif told_alibi and cap_on:
		ask_cap()
	else:
		alibi()


## Where they were at midnight, opened a different way each time.
func alibi() -> void:
	say(tr("MEMBER_LINE_%d" % ((index + _lines_said) % LINES)) + " " + tr("MEMBER_ALIBI_" + str(traits.room)), 5.0)
	_lines_said += 1
	told_alibi = true
	_give("midnight")


## Bites a chocolate from the box: their teeth for the file. A stubborn one takes off the cap for it.
func feed(box: DonutBox) -> void:
	if not box.eat_one():
		say("MEMBER_NO_CHOCOLATES")
		return
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("MEMBER_BITES")
	_give("teeth")
	if stubborn:
		stubborn = false
		_take_off_cap()


func ask_cap() -> void:
	if stubborn:
		say("MEMBER_CAP_NO")
		return
	_take_off_cap()


func _take_off_cap() -> void:
	cap_on = false
	part("cap").visible = false
	say("MEMBER_CAP_OFF")
	_give("hair")


## The camera's flash in their face (PhotoCamera): their photo, with their glasses and their shoes.
func photographed(_cop: Cop) -> void:
	say("MEMBER_NO_FLASH")
	_give("photo")


## The print kit on them (PrintKit): their prints.
func dusted(_cop: Cop) -> String:
	_give("prints")
	return tr("PRINTS_COOK") % traits.name


## Walks along these points (in the parent's space) and ends in `to_room`, then calls `done`.
func walk_along(points: Array[Vector3], to_room: String, done: Callable) -> void:
	room = ""
	walk = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var from := position
	for to in points:
		var face := to - from
		if face.length() > 0.01:
			walk.tween_property(self, "rotation:y", atan2(face.x, face.z), 0.0)
		walk.tween_property(self, "position", to, from.distance_to(to) / WALK_SPEED)
		from = to
	walk.tween_callback(func() -> void:
		room = to_room
		walk = null
		done.call())


func _give(what: String) -> void:
	if not given.has(what):
		given.append(what)
	part_given.emit(index, what)


func _chocolates(cop: Cop) -> DonutBox:
	if not cop:
		return null
	var held: Node = cop.get_node("Grabber").held
	return held as DonutBox if held is ChocolateBox else null


func _physics_process(delta: float) -> void:
	super(delta)
	if _teeth_left > 0.0:
		_teeth_left -= delta
		part("teeth").visible = _teeth_left > 0.0
