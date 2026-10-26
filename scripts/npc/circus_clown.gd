class_name CircusClown
extends StaticBody3D

## One of the six clowns of the Cascabel Brothers' circus (escena-circo.md, "Los payasos iguales"): the same wig,
## nose, white makeup, gloves and giant shoes as the other five. Under them, his own hair (tinted), his glasses (shown
## only without makeup), his real feet (stretched to his size) and his teeth. The cops make his file for the board by
## taking off what hides him (escena-circo.md, step 4), with E and what's in hand: the sponge scrubs off the makeup (a
## bit each time) so the photo is worth something; a donut or a loaf, he bites it (his teeth); the print kit pulls off a
## glove, but some have the infinite glove trick and there's another one under it; with empty hands, his nose honks
## (its note), the wig comes off (his hair; one won't until he gets something to eat) and a giant shoe comes off (his
## real size). Then his nose honks again each time. A part goes to the file of the numbered sign on his back
## (CrimeSceneCase.clown_part); with a sign in hand, E sticks it there. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_payaso.glb")
## Real feet sizes stretch the feet from this much (the smallest) to this much (the biggest).
const FEET_SCALE := Vector2(0.85, 1.3)
const JOKES := 6
## E with the sponge this many times cleans his face.
const SCRUBS := 3
## Seconds his teeth show after a bite.
const TEETH_SECONDS := 2.0

## ClownTraits.draw: name, hair, glasses, shoe, teeth, honk.
var traits := {}
## His caravan's number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
## The circus he works at: it keeps who wears which sign.
var circus: Circus
var makeup_on := true
var wig_on := true
var gloves_on := true
var shoe_on := true
var honked := false
## He won't take off the wig until he gets something to eat.
var stubborn := false
## Gloves still under the one he has on (the infinite glove trick).
var spare_gloves := 0
var _scrubbed := 0
var _teeth_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _jokes_told := 0
var _sign: Node3D


func _ready() -> void:
	add_to_group("circus_clowns")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", ClownTraits.HAIRS[traits.hair])
	part("teeth").visible = false
	var size := inverse_lerp(ClownTraits.SHOE_MIN, ClownTraits.SHOE_MAX, traits.shoe)
	(_model.find_child("legs", true, false) as Node3D).scale.z = lerpf(FEET_SCALE.x, FEET_SCALE.y, size)
	_show_disguise()
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	var held: Node = cop.get_node("Grabber").held
	if held is ClownSign:
		return "PROMPT_CLOWN_SIGN"
	if held is ClownSponge and makeup_on:
		return "PROMPT_CLOWN_SCRUB"
	if held is DonutBox or held is Bread:
		return "PROMPT_CLOWN_FEED"
	if cop.belt and cop.belt.held_tool() is PrintKit and gloves_on:
		return "PROMPT_CLOWN_GLOVE"
	if not honked:
		return "PROMPT_CLOWN_HONK"
	if wig_on:
		return "PROMPT_CLOWN_WIG"
	return "PROMPT_CLOWN_SHOE" if shoe_on else "PROMPT_CLOWN_HONK"


## E on him: what's in hand decides (the sponge, food, the print kit); with empty hands, the nose, the wig, a shoe and
## then the nose again.
func use(cop: Cop) -> void:
	var held: Node = cop.get_node("Grabber").held
	if held is ClownSign:
		var sign := held as ClownSign
		cop.get_node("Grabber").release()
		if circus:
			circus.stick_sign(sign.number, self)
		sign.queue_free()
	elif held is ClownSponge and makeup_on:
		scrub()
	elif held is DonutBox or held is Bread:
		feed(held)
	elif cop.belt and cop.belt.held_tool() is PrintKit and gloves_on:
		pull_glove()
	elif not honked:
		honk()
	elif wig_on:
		ask_wig()
	elif shoe_on:
		pull_shoe()
	else:
		honk()


## A joke, a different one each time (in an order that starts at his number).
func joke() -> void:
	say("CLOWN_JOKE_%d" % ((index + _jokes_told) % JOKES))
	_jokes_told += 1


## One scrub with the sponge; after SCRUBS, his face is clean and his glasses show (if he wears them).
func scrub() -> void:
	_scrubbed += 1
	if _scrubbed < SCRUBS:
		say("CLOWN_SCRUB")
		return
	makeup_on = false
	_show_disguise()
	say("CLOWN_FACE_CLEAN")


## Bites a donut from the box or the loaf: his teeth show for the file. A stubborn one takes off the wig for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("CLOWN_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("CLOWN_BITES")
	_file("teeth")
	if stubborn:
		stubborn = false
		_take_off_wig()


## Pulls a glove off: another one under it while he has spares, then his bare hands.
func pull_glove() -> void:
	if spare_gloves > 0:
		spare_gloves -= 1
		say("CLOWN_GLOVE_TRICK")
		return
	gloves_on = false
	part("gloves").visible = false
	say("CLOWN_GLOVES_OFF")


## Squeezes his red nose: it honks his note.
func honk() -> void:
	honked = true
	say("CLOWN_HONK_" + str(traits.honk))
	_file("honk")


func ask_wig() -> void:
	if stubborn:
		say("CLOWN_WIG_NO")
		return
	_take_off_wig()


func _take_off_wig() -> void:
	wig_on = false
	_show_disguise()
	say("CLOWN_WIG_OFF")
	_file("hair")


## Pulls off a giant shoe: his real foot, his real size.
func pull_shoe() -> void:
	shoe_on = false
	part("shoe_right").visible = false
	say(tr("CLOWN_SHOE_OFF") % traits.shoe)
	_file("shoe")


## The camera's flash: with the makeup on they're all the same and the photo isn't worth anything.
func photographed(_cop: Cop) -> void:
	if makeup_on:
		say("CLOWN_PHOTO_MAKEUP")
		return
	say("CLOWN_PHOTO")
	_file("photo")


## The print kit on him (PrintKit): a glove print until his hands are bare, then his prints.
func dusted(_cop: Cop) -> String:
	if gloves_on:
		return "PRINTS_GLOVE"
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## Whether he looks like the other five: makeup and wig on, gloves and both giant shoes too.
func disguised() -> bool:
	return makeup_on and wig_on


## What shows depends on what he still has on: his glasses only without the white makeup, his hair only without the
## wig.
func _show_disguise() -> void:
	part("makeup").visible = makeup_on
	part("glasses").visible = traits.glasses and not makeup_on
	part("wig").visible = wig_on
	part("hair").visible = not wig_on
	part("gloves").visible = gloves_on
	part("shoe_right").visible = shoe_on


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	if _teeth_left > 0.0:
		_teeth_left -= delta
		part("teeth").visible = _teeth_left > 0.0
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


func _file(what: String) -> void:
	if case:
		case.clown_part(index, what)


## The sign with this number on his back (-1 takes it off).
func show_sign(number: int) -> void:
	if _sign:
		_sign.queue_free()
		_sign = null
	if number < 0:
		return
	_sign = Node3D.new()
	_sign.name = "Sign"
	_sign.position = Vector3(0, 0.95, -0.43)
	_sign.rotation.y = PI
	add_child(_sign)
	var paper := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = ClownSign.SIZE
	paper.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = ClownSign.PAPER
	paper.material_override = material
	_sign.add_child(paper)
	var label := Label3D.new()
	label.text = str(number + 1)
	label.font_size = 96
	label.pixel_size = 0.002
	label.modulate = Color(0.1, 0.1, 0.12)
	label.outline_size = 0
	label.position = Vector3(0, 0, ClownSign.SIZE.z / 2 + 0.002)
	_sign.add_child(label)


func has_sign() -> bool:
	return _sign != null


## A part of his model by name (makeup, wig, hair, glasses, gloves, shoe_left, shoe_right, nose, teeth, legs...).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
