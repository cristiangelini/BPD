class_name RallyFan
extends CharacterBody3D

## Someone in the crowd at deputy Lustre's rally (proteccion-politico.md, step 2, decision 103): a neighbor standing in
## front of the stage. Most cheer now and then; a `heckler` hides a market bag of eggs and tomatoes and throws one at
## the politician when RallyCrowd says so (throw_at). Step 4: the heckler's bag shows eggs and tomatoes (a few innocents
## carry a shopping bag that looks the same from afar, with bread and a leek), and after the first throw their hands
## are dirty with yolk and tomato; a cop who sees them throw marks them for everyone. Anyone can be cuffed: an innocent
## protests, and a cuffed heckler doesn't throw and E walks them to the patrol car (OwnerEscort). Every number here is
## (propuesta).

signal threw(fan: RallyFan, throwable: RallyThrowable)
## The handcuffs closed on them.
signal cuffed_now(fan: RallyFan)

const SCALES := {"abuelo": 0.82, "abuela": 0.8}
const SAY_TIME := 4.0
## Where the throw leaves from: about their raised hand.
const HAND := Vector3(0.25, 1.5, 0)
## Seconds in the air: a high arc the cops can see coming.
const FLIGHT := 1.3
## Their hands, in their own space (the model is turned to face -Z), before the look's scale.
const HANDS: Array[Vector3] = [Vector3(-0.49, 0.64, -0.09), Vector3(0.49, 0.64, -0.09)]
const BAG_MODELS := {
	"market": preload("res://assets/models/rally_market_bag.glb"),
	"shopping": preload("res://assets/models/rally_shopping_bag.glb"),
}
const DIRTY_HAND := preload("res://assets/models/rally_dirty_hand.glb")
## The bag and the goo show bigger than life, so they can be spotted from a few meters.
const LOOK_SCALE := 1.6
const LINES := 4
const PROTESTS := 3
const EXCUSES := 3

@export var look := "vecina"
var heckler := false
## "market" (eggs and tomatoes), "shopping" (bread and a leek) or "" for none.
var bag := ""
## Their hands show the goo of a throw.
var dirty := false
## A cop saw them throw: a mark over their head for everyone.
var marked := false
## A guest's copy (NpcSync): the host's decides whether the cuffs closed.
var follower := false
var _cuffed_left := 0.0
var _next_line := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("rally_fans")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = load("res://assets/models/npc_%s.glb" % look).instantiate()
	_model.scale = Vector3.ONE * SCALES.get(look, 1.0)
	# The models face +Z; the fan faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.8, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	if not bag.is_empty():
		carry_bag(bag)


## Hangs `kind`'s bag ("market" or "shopping") from their left hand.
func carry_bag(kind: String) -> void:
	bag = kind
	if not is_node_ready():
		return
	var old := get_node_or_null("Bag")
	if old:
		old.free()
	var model: Node3D = BAG_MODELS[kind].instantiate()
	model.name = "Bag"
	model.scale = Vector3.ONE * LOOK_SCALE
	model.position = HANDS[0] * SCALES.get(look, 1.0)
	add_child(model)


## Yolk and tomato on both hands, for good.
func get_dirty() -> void:
	if dirty:
		return
	dirty = true
	for i in HANDS.size():
		var goo: Node3D = DIRTY_HAND.instantiate()
		goo.name = "DirtyHand%d" % i
		goo.scale = Vector3.ONE * LOOK_SCALE
		goo.position = HANDS[i] * SCALES.get(look, 1.0)
		add_child(goo)


## A cop saw them throw: a red mark over their head that everyone sees.
func mark() -> void:
	if marked:
		return
	marked = true
	var sign := Label3D.new()
	sign.name = "Mark"
	sign.text = "!"
	sign.font_size = 120
	sign.pixel_size = 0.004
	sign.outline_size = 16
	sign.modulate = Color(0.95, 0.15, 0.15)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.no_depth_test = true
	sign.position = Vector3(0, 2.0, 0)
	add_child(sign)


## Throws a `kind` ("egg" or "tomato") to land on `target` (world space). Returns what flies.
func throw_at(target: Vector3, kind: String) -> RallyThrowable:
	var thrown := RallyThrowable.new()
	thrown.kind = kind
	get_parent().add_child(thrown, true)
	thrown.launch(global_transform * HAND, target, FLIGHT)
	add_collision_exception_with(thrown)
	thrown.add_collision_exception_with(self)
	get_dirty()
	threw.emit(self, thrown)
	return thrown


## The handcuffs: a heckler stops throwing and makes excuses, an innocent protests.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	if follower:
		return
	if heckler:
		say("HECKLER_CUFFED_%d" % (_next_line % EXCUSES + 1))
	else:
		say("FAN_WRONG_CUFF_%d" % (_next_line % PROTESTS + 1))
	_next_line += 1
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## Walked to the patrol car and sitting in it.
func in_car() -> bool:
	var escort := OwnerEscort.of(self)
	return escort != null and escort.in_car


## Whether they can throw now: neither cuffed nor taken away.
func free_to_throw() -> bool:
	var escort := OwnerEscort.of(self)
	return not is_cuffed() and not (escort and (escort.in_car or escort.escorted_by))


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_FAN"


## E on a fan: the same small talk from anyone, so talking gives no one away; cuffed, the escort to the patrol car.
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	say("FAN_TALK_%d" % (_next_line % LINES + 1))
	_next_line += 1


## What the escort calls (OwnerEscort): a line for `seconds`; fans have no complaint meter.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key)
	_bubble_left = seconds


func _raise(_points: float) -> void:
	pass


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)


func _process(delta: float) -> void:
	# The escort turns them with their +Z ahead.
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and (escort.escorted_by or escort.in_car) else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
