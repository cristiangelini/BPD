class_name Politician
extends CharacterBody3D

## Deputy Pompeyo Lustre (proteccion-politico.md, step 1, decision 103): the annoying politician the cops guard at
## the plaza. He stands at the stage's lectern and gives his speech (PoliticianSpeech says the lines). Each egg or
## tomato that hits him is a stain on his suit (step 2): he complains into the microphone and, with STAINS_MAX of them,
## leaves furious (`furious`; the case is lost, decision 103). Step 5: his walks off the stage to greet the crowd and
## being led back by the hand (PoliticianWalks, "Walks"). Online the host's decides and a guest's follows it (NpcSync,
## net_state: his stains and where his walk is). Every number here is (propuesta).
## The double (politico-doble.md, decision 220): Rolo Calcado is another Politician with `impostor` on. Both wear the
## ten tells (DoubleTells, `dress`), the double three of his own; hidden in the crowd he wears a hat and a scarf
## (`disguise`) that cover them. Step 3: cuffed, the double is caught for good (his mustache falls off) and E walks him
## to the patrol car (OwnerEscort); cuffing the real deputy offends him, `wrong_cuff_stains` stains on his image, and the
## cuffs open at once.

signal stained(count: int)
signal furious
## The double got cuffed (politico-doble.md, step 3).
signal cuffed_now

const MODEL := preload("res://assets/models/npc_politico.glb")
const SAY_TIME := 6.0
const STAINS_MAX := 10
const STAIN_LINES := 6
## The stain left on him: the splat this small, stuck where it hit.
const STAIN_SCALE := 0.35
const HIDDEN_LINES := 3
## A stain on his image, not on his suit: the double's outrages (politico-doble.md, step 2). It leaves no mark.
const SHAME := "shame"
const SHAME_LINES := 3
const CAUGHT_LINES := 3
const WRONG_CUFF_LINES := 3
const HAT := Color(0.18, 0.16, 0.15)
const SCARF := Color(0.55, 0.2, 0.25)

var stains := 0
## Rolo Calcado, the double (politico-doble.md), and the tells he gets wrong.
var impostor := false
var fakes: Array[String] = []
var disguised := false
var tells: Node3D
## Cuffing the real deputy costs this many stains (only at the double's rally).
var wrong_cuff_stains := 0
## The double, cuffed: caught for good.
var caught := false
var _cuffed_left := 0.0
var _disguise: Node3D
## Each stain as [kind, where on him], so a guest's copy wears them in the same places.
var marks: Array = []

var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("politicians")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z; he faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.006
	_bubble.outline_size = 8
	_bubble.font_size = 40
	_bubble.width = 1000.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.modulate = Color(1, 0.95, 0.7)
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	if disguised:
		return "PROMPT_TALK_FAN"
	var walks := PoliticianWalks.of(self)
	if walks:
		return walks.prompt_key(cop)
	# On the bridge, the cops hold him back by the coat (BridgeCoat).
	var coat := get_node_or_null("Coat")
	return coat.prompt_key(cop) if coat else "PROMPT_TALK_POLITICIAN"


## E: he shakes the cop's hand and asks for their vote; off the stage, the cop takes him by the hand (PoliticianWalks).
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	if disguised:
		say("DOUBLE_HIDDEN_%d" % (randi() % HIDDEN_LINES))
		return
	var walks := PoliticianWalks.of(self)
	if walks and walks.use(cop):
		return
	var coat := get_node_or_null("Coat")
	if coat and coat.use(cop):
		return
	say("POLITICIAN_HANDSHAKE")


## The ten tells on him (DoubleTells): the real deputy's look, but `wrong` ones the double's.
func dress(wrong: Array[String]) -> void:
	fakes = wrong
	if tells:
		tells.free()
	tells = DoubleTells.dress(_model, fakes)
	tells.visible = not disguised


## The double hidden in the crowd: a hat over his hair and a scarf over his face and tie, which hide his tells.
func disguise(on: bool) -> void:
	disguised = on
	if on and not _disguise:
		_disguise = Node3D.new()
		_disguise.name = "Disguise"
		_model.add_child(_disguise)
		_part(_disguise, _cylinder(0.24, 0.05), Vector3(0, 1.47, 0.02), HAT)
		_part(_disguise, _cylinder(0.17, 0.2), Vector3(0, 1.58, 0.02), HAT)
		_part(_disguise, _cylinder(0.25, 0.32), Vector3(0, 1.08, 0.02), SCARF)
	if _disguise:
		_disguise.visible = on
	if tells:
		tells.visible = not on


static func _part(parent: Node3D, mesh: Mesh, at: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	part.material_override = material
	part.position = at
	parent.add_child(part)


static func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	return mesh


## The handcuffs. The double is caught: no more hat and scarf, his mustache falls off and he owns up. The real deputy is
## offended: wrong_cuff_stains stains on his image, and the cuffs open at once.
func cuffed(seconds: float) -> void:
	if impostor:
		_cuffed_left = maxf(_cuffed_left, seconds)
		if caught:
			return
		caught = true
		_caught_look()
		say("DOUBLE_CAUGHT_%d" % (randi() % CAUGHT_LINES + 1))
		cuffed_now.emit()
		return
	for i in wrong_cuff_stains:
		stain(SHAME, global_position + Vector3.UP)
	if stains < STAINS_MAX:
		say("POLITICIAN_WRONG_CUFF_%d" % (randi() % WRONG_CUFF_LINES + 1))


## Only the double stays cuffed: walked by a cop or not, until he's in the patrol car.
func is_cuffed() -> bool:
	return caught


func _caught_look() -> void:
	disguise(false)
	if tells:
		tells.get_node("mustache").hide()


## What the escort calls (OwnerEscort): a line for `seconds`; he has no complaint meter.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key, seconds)


func _raise(_points: float) -> void:
	pass


## Off the stage greeting, or being led back.
func off_stage() -> bool:
	var walks := PoliticianWalks.of(self)
	return walks != null and walks.off_stage()


## An egg or a tomato hit him at `at` (world space).
func stain(kind: String, at: Vector3) -> void:
	if stains >= STAINS_MAX:
		return
	stains += 1
	_wear(kind, to_local(at))
	stained.emit(stains)
	if stains >= STAINS_MAX:
		say("POLITICIAN_FURIOUS")
		furious.emit()
	elif kind == SHAME:
		say("POLITICIAN_SHAMED_%d" % ((stains - 1) % SHAME_LINES + 1))
	else:
		say("POLITICIAN_STAIN_%d" % ((stains - 1) % STAIN_LINES + 1))


## Stain number `marks.size() + 1`: `kind`'s splat flat against his body where it hit (`local`), facing out from his
## middle.
func _wear(kind: String, local: Vector3) -> void:
	marks.append([kind, local])
	if kind == SHAME:
		return
	var mark: Node3D = RallyThrowable.SPLATS[kind].instantiate()
	mark.name = "Stain%d" % marks.size()
	add_child(mark)
	var out := Vector3(local.x, 0, local.z)
	if out.length() < 0.01:
		out = Vector3.BACK
	mark.position = Vector3(0, clampf(local.y, 0.3, 1.5), 0) + out.normalized() * 0.38
	mark.basis = Basis(Quaternion(Vector3.UP, out.normalized())).scaled(Vector3.ONE * STAIN_SCALE)


## What a guest's copy needs besides where he is and what he says (NpcSync): his stains and his walk's state.
func net_state() -> Array:
	var walks := PoliticianWalks.of(self)
	return [marks.duplicate(), walks.state if walks else 0, disguised, caught]


func apply_net_state(state: Variant) -> void:
	for i in range(marks.size(), (state[0] as Array).size()):
		_wear(state[0][i][0], state[0][i][1])
	stains = marks.size()
	if state[2] != disguised:
		disguise(state[2])
	if state[3] and not caught:
		caught = true
		_caught_look()
	var walks := PoliticianWalks.of(self)
	if walks:
		walks.state = state[1]
		if walks.state != PoliticianWalks.State.LED:
			walks.led_by = null


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
