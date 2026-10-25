class_name PrisonVisitor
extends CharacterBody3D

## A visitor on the prison's visiting day (carcel-visitas.md, step 2): a grandma, a cousin, a girlfriend... waiting in
## line in the yard with something in their hands (VisitItem). At the head of the line they walk to the search table,
## leave it there and wait for a cop to let them in (E); nobody comes in WAIT_ALONE seconds and they go in alone. Going
## in they take back what they brought, if it's still on the table, and walk to their seat in the canteen. Every
## number here is (propuesta).

signal at_table(visitor: PrisonVisitor)
signal went_in(visitor: PrisonVisitor)

enum State { QUEUE, TABLE, IN, SEATED }

## The looks, one per visitor (the NPCs' bodies, decision 72): grandma, grandpa, mom, girlfriend, cousin, uncle,
## neighbor, lady.
const LOOKS: Array[String] = ["npc_abuela", "npc_abuelo", "npc_senora", "npc_clienta", "npc_cliente", "npc_portero",
	"npc_mudancero", "npc_vecina"]
const SPEED := 1.4
const REACH := 0.3
const WAIT_ALONE := 40.0
const HELLO_LINES := 4
const SAY_TIME := 3.0
## Where the carried thing sits in their hands, from their feet (their front is -Z).
const HANDS := Vector3(0, 0.85, -0.42)
## Seated, they sit on the bench this much lower (PrisonInmate.SIT_DROP).
const SIT_DROP := 0.35

var look := 0
var item_kind := VisitItem.Kind.CAKE
## Something hidden in what they bring, or in a pocket (VisitPlan draws them; found in step 3).
var item_hidden := false
var pocket_hidden := false
var prison: PrisonLevel
var state := State.QUEUE
## Their seat in the canteen (level space x, z) and the way there from the search table.
var seat := Vector2.ZERO
## What they left on the search table, while it's there.
var item: VisitItem
var route: Array[Vector2] = []
## A guest's copy (step 7): the host walks them.
var follower := false
var _next := 0
var _waited := 0.0
var _model: Node3D
var _carried: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("prison_visitors")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = (load("res://assets/models/%s.glb" % LOOKS[look]) as PackedScene).instantiate()
	# The models face +Z; the visitor's front is -Z, like the other NPCs placed by code.
	_model.rotation.y = PI
	add_child(_model)
	_carried = VisitItem.build_model(item_kind)
	_carried.name = "Carried"
	_carried.position = HANDS
	add_child(_carried)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.85, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## Whether they still have what they brought in their hands.
func is_carrying() -> bool:
	return _carried.visible


## Walk `points` (level space), once.
func walk(points: Array[Vector2]) -> void:
	route = points
	_next = 0


func walking() -> bool:
	return _next < route.size()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_LET_VISITOR_IN" if state == State.TABLE else ""


## E at the search table: in they go.
func use(_cop: Cop) -> void:
	if state == State.TABLE:
		go_in("VISITOR_THANKS")


## Going in, with what they brought if it's still on the table (a cop holding it keeps it).
func go_in(line: String) -> void:
	state = State.IN
	if is_instance_valid(item) and not item.is_held() and not item.is_queued_for_deletion():
		item.queue_free()
		_carried.show()
	elif not is_carrying():
		line = "VISITOR_MY_THING"
	item = null
	say(line)
	walk(VisitPlan.way_in(seat))
	went_in.emit(self)


## At the search table: what they bring goes on it, and they say hello.
func _arrive_at_table() -> void:
	state = State.TABLE
	_waited = 0.0
	_carried.hide()
	item = VisitItem.new()
	item.name = "VisitItem"
	item.kind = item_kind
	item.hidden = item_hidden
	item.visitor = self
	prison.add_child(item, true)
	item.global_position = prison.global_transform * VisitPlan.ITEM_ON_TABLE
	say("VISITOR_HELLO_%d" % randi_range(1, HELLO_LINES))
	at_table.emit(self)


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	if follower:
		return
	if state == State.TABLE:
		_waited += delta
		if _waited >= WAIT_ALONE:
			go_in("VISITOR_GOES_ALONE")
		return
	if not walking():
		velocity = Vector3.ZERO
		return
	var local := prison.global_transform.affine_inverse() * global_position
	var to := route[_next] - Vector2(local.x, local.z)
	if to.length() < REACH:
		_next += 1
		if not walking():
			_arrived()
		return
	var step := to.normalized() * SPEED
	velocity = prison.global_basis * Vector3(step.x, 0, step.y)
	velocity.y = 0.0
	look_at(global_position + velocity, Vector3.UP)
	move_and_slide()


func _arrived() -> void:
	velocity = Vector3.ZERO
	match state:
		State.QUEUE:
			if route[-1] == VisitPlan.TABLE_SPOT:
				_arrive_at_table()
		State.IN:
			state = State.SEATED
			_model.position.y = -SIT_DROP
			# Facing the table (it's to their -Z: they sit on its +Z side).
			look_at(global_position + prison.global_basis * Vector3(0, 0, -1), Vector3.UP)
