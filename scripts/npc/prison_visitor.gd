class_name PrisonVisitor
extends CharacterBody3D

## A visitor on the prison's visiting day (carcel-visitas.md, step 2): a grandma, a cousin, a girlfriend... waiting in
## line in the yard with something in their hands (VisitItem). At the head of the line they walk to the search table,
## leave it there and wait for a cop to let them in (E); nobody comes in WAIT_ALONE seconds and they go in alone. Going
## in they take back what they brought, if it's still on the table and wasn't opened, and walk to their seat in the
## canteen. Step 3: at the table, R and staying close FRISK_TIME seconds frisks them (what's in a pocket falls on the
## table); opening what they brought (VisitItem.use) finds what's inside, or breaks it and they cry. Every number here
## is (propuesta). Step 5: seated across from their inmate (VisitInmate), whoever still carries something hidden tries
## to slip it under the table every PASS_EVERY seconds when no cop is watching their table; it takes PASS_TIME
## seconds, and E on them meanwhile stops it. When the bell rings they leave through the gate.

signal at_table(visitor: PrisonVisitor)
signal went_in(visitor: PrisonVisitor)
## Something they hid was found (frisked, or opened in a cop's hands).
signal found(visitor: PrisonVisitor, contraband: Contraband)
## What they brought was opened with nothing in it.
signal cried(visitor: PrisonVisitor)
## Slipped something to their inmate under the table (step 5), or got stopped doing it.
signal passed(visitor: PrisonVisitor)
signal stopped(visitor: PrisonVisitor)

enum State { QUEUE, TABLE, IN, SEATED, LEAVING, GONE }

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
## Frisking (R): the cop stays this close for this long.
const FRISK_TIME := 2.0
const FRISK_REACH := 2.4
const CAUGHT_LINES := 3
const CRY_LINES := 3
## Their tells while in line or at the table (step 4): every so often, the ones hiding something look at it, whistle
## or sweat; a nervous innocent (VisitPlan.NERVOUS_ONE_IN) frets now and then too.
const TELL_EVERY := Vector2(8.0, 14.0)
const NERVOUS_EVERY := Vector2(15.0, 25.0)
const TELLS: Array[String] = ["VISITOR_TELL_LOOK", "VISITOR_TELL_WHISTLE", "VISITOR_TELL_SWEAT"]
const NERVOUS_LINES := 3
## The pass under the table (step 5): how often they try, how long it takes and how long they wait when watched.
const PASS_EVERY := Vector2(20.0, 40.0)
const PASS_TIME := 3.0
const PASS_RETRY := 5.0

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
## Frisked once already (step 3), and the cop frisking them now.
var frisked := false
var frisked_by: Cop
## Which Contraband.IN_POCKET kind a pocket hides (VisitPlan draws it).
var pocket_kind := 0
var _frisk_left := 0.0
## A nervous innocent (step 4), and the seed of everyone's tells.
var nervous := false
var tell_seed := 0
var _tell_left := -1.0
## Their inmate across the table (step 5), and the pass under it.
var inmate: VisitInmate
var passing := false
var _pass_left := -1.0
var _passing_left := 0.0
var _tells := RandomNumberGenerator.new()
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


## Seconds to their next tell, or -1 if they have none.
func _next_tell() -> float:
	if has_contraband():
		return _tells.randf_range(TELL_EVERY.x, TELL_EVERY.y)
	if nervous:
		return _tells.randf_range(NERVOUS_EVERY.x, NERVOUS_EVERY.y)
	return -1.0


func _tell(delta: float) -> void:
	if state == State.IN or state == State.SEATED or frisked_by:
		return
	if _tell_left < 0.0:
		_tells.seed = tell_seed
		_tell_left = _next_tell()
		if _tell_left < 0.0:
			_tell_left = INF
		return
	_tell_left -= delta
	if _tell_left > 0.0:
		return
	if has_contraband():
		say(TELLS[_tells.randi_range(0, TELLS.size() - 1)])
	elif nervous:
		say("VISITOR_NERVOUS_%d" % _tells.randi_range(1, NERVOUS_LINES))
	_tell_left = _next_tell()
	if _tell_left < 0.0:
		_tell_left = INF


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
	if passing:
		return "PROMPT_STOP_PASS"
	if state != State.TABLE:
		return ""
	return "PROMPT_LET_VISITOR_IN" if frisked else "PROMPT_VISITOR_AT_TABLE"


## Whether they still carry something hidden: in their pocket, or in what they brought back from the table.
func has_contraband() -> bool:
	return pocket_hidden or (item_hidden and is_carrying())


## R at the search table: the cop frisks them while staying close (the host counts).
func ask(cop: Cop) -> bool:
	if state != State.TABLE or frisked or frisked_by:
		return false
	frisked_by = cop
	_frisk_left = FRISK_TIME
	say("VISITOR_FRISKED", FRISK_TIME)
	return true


func _frisk(delta: float) -> void:
	if not is_instance_valid(frisked_by) or frisked_by.global_position.distance_to(global_position) > FRISK_REACH:
		frisked_by = null
		return
	_frisk_left -= delta
	if _frisk_left > 0.0:
		return
	var cop := frisked_by
	frisked_by = null
	frisked = true
	_waited = 0.0
	if not pocket_hidden:
		say("VISITOR_FRISK_CLEAN")
		cop.show_hint("HINT_VISIT_POCKETS_CLEAN", true)
		return
	pocket_hidden = false
	var contraband := Contraband.new()
	contraband.name = "Contraband"
	contraband.kind = Contraband.IN_POCKET[pocket_kind]
	prison.add_child(contraband, true)
	contraband.global_position = prison.global_transform * (VisitPlan.ITEM_ON_TABLE + Vector3(0, 0.1, 0.5))
	cop.show_hint("HINT_VISIT_FOUND_%s" % Contraband.Kind.keys()[contraband.kind], true)
	caught(contraband)


## Something of theirs was found (`from_item`: in what they brought): caught red-handed.
func caught(contraband: Contraband, from_item := false) -> void:
	say("VISITOR_CAUGHT_%d" % randi_range(1, CAUGHT_LINES))
	if from_item:
		item_hidden = false
	found.emit(self, contraband)


## What they brought was opened for nothing: they cry.
func broken(_what: VisitItem) -> void:
	say("VISITOR_CRY_%d" % randi_range(1, CRY_LINES))
	cried.emit(self)


## E at the search table: in they go. E while they slip something under the table: stopped (the host decides).
func use(cop: Cop) -> void:
	if passing:
		if multiplayer.is_server():
			stop_pass(cop)
		return
	if state == State.TABLE:
		go_in("VISITOR_THANKS")


## What they still hide, as a Contraband.Kind (the pocket first), or -1.
func hidden_kind() -> int:
	if pocket_hidden:
		return Contraband.IN_POCKET[pocket_kind]
	if item_hidden and is_carrying():
		return Contraband.IN_ITEM[item_kind]
	return -1


## Seated, while the visit lasts (VisitPlan): the pass under the table. `watched`: a cop is looking at their table.
func visit_tick(delta: float, watched: bool) -> void:
	if state != State.SEATED or not has_contraband() or not inmate:
		return
	if passing:
		_passing_left -= delta
		if _passing_left <= 0.0:
			_finish_pass()
		return
	if _pass_left < 0.0:
		_pass_left = _tells.randf_range(PASS_EVERY.x, PASS_EVERY.y)
	_pass_left -= delta
	if _pass_left > 0.0:
		return
	if watched:
		_pass_left = PASS_RETRY
		return
	passing = true
	_passing_left = PASS_TIME
	_carried.position = HANDS + Vector3(0, -0.5, -0.1)
	say("VISITOR_PSST", PASS_TIME)


func _finish_pass() -> void:
	passing = false
	_carried.position = HANDS
	inmate.receive(hidden_kind())
	_drop_hidden()
	passed.emit(self)


## Caught slipping it: the cop takes it.
func stop_pass(cop: Cop) -> void:
	passing = false
	_carried.position = HANDS
	_drop_hidden()
	_pass_left = -1.0
	say("VISITOR_STOPPED")
	cop.show_hint("HINT_VISIT_PASS_STOPPED", true)
	stopped.emit(self)


func _drop_hidden() -> void:
	if pocket_hidden:
		pocket_hidden = false
	else:
		item_hidden = false


## The bell: back out through the gate.
func leave() -> void:
	passing = false
	_carried.position = HANDS
	_model.position.y = 0.0
	state = State.LEAVING
	walk(VisitPlan.way_out(seat))
	say("VISITOR_BYE")


## Going in, with what they brought if it's still on the table (a cop holding it keeps it).
func go_in(line: String) -> void:
	state = State.IN
	frisked_by = null
	if is_instance_valid(item) and item.opened:
		# Opened, it stays on the table: nothing to take in.
		item_hidden = false
	elif is_instance_valid(item) and not item.is_held() and not item.is_queued_for_deletion():
		item.queue_free()
		_carried.show()
	elif not is_carrying():
		item_hidden = false
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
	item.set_down()
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
	_tell(delta)
	if state == State.TABLE:
		if frisked_by:
			_frisk(delta)
			return
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
		State.LEAVING:
			state = State.GONE
			hide()
			collision_layer = 0
		State.IN:
			state = State.SEATED
			_model.position.y = -SIT_DROP
			# Facing the table (it's to their -Z: they sit on its +Z side).
			look_at(global_position + prison.global_basis * Vector3(0, 0, -1), Vector3.UP)
