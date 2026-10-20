class_name BakeryCustomer
extends CharacterBody3D

## A customer of the bakery (docs/diseno/panaderia.md, "La panadera"): walks in from the sidewalk along `route`,
## waits at the counter until Marta serves them, and walks back out. A scare (a cop bumping them, a door rammed down)
## makes them run out without paying. Every number here is (propuesta).

## Reached the counter: Marta can serve them now.
signal arrived
signal fled
signal gone
## A cop ran into them: the whole shop gets scared.
signal bumped

enum State { ENTERING, WAITING, LEAVING, FLEEING }

const MODELS: Array[PackedScene] = [
	preload("res://assets/models/npc_cliente.glb"), preload("res://assets/models/npc_clienta.glb"),
]
const SPEED := 1.3
const FLEE_SPEED := 4.0
const STRUCK_SPEED := 2.0

## Points in the bakery's space from the sidewalk to this customer's place at the counter.
var route: Array[Vector3] = []
var state := State.ENTERING
var paid := false
## Which customer model it wears (set_look).
var look := 0
var _next := 0
## Cuffed by a cop: stays put, and runs off once free (herramientas.md).
var _cuffed_left := 0.0

@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	$Bump.body_entered.connect(_on_bump)
	_bubble.hide()


## Which of the customer models to wear.
func set_look(index: int) -> void:
	look = index
	var old: Node3D = $Model
	var fresh: Node3D = MODELS[index % MODELS.size()].instantiate()
	fresh.transform = old.transform
	remove_child(old)
	old.queue_free()
	fresh.name = "Model"
	add_child(fresh)


func served() -> void:
	paid = true
	_say("CUSTOMER_THANKS")
	_leave(State.LEAVING)


func scare() -> void:
	if state == State.FLEEING or paid:
		return
	_say("CUSTOMER_SCARED")
	_leave(State.FLEEING)
	fled.emit()


func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	_say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func _leave(how: State) -> void:
	if state == State.ENTERING or state == State.WAITING:
		_next = maxi(_next - 1, 0)
	state = how


func _physics_process(delta: float) -> void:
	var wish := Vector3.ZERO
	if is_cuffed():
		_cuffed_left -= delta
		if not is_cuffed():
			scare()
	elif state != State.WAITING:
		var target := route[_next]
		wish = target - global_position
		wish.y = 0.0
		if wish.length() < 0.2:
			_arrive()
			wish = Vector3.ZERO
		else:
			wish = wish.normalized() * (FLEE_SPEED if state == State.FLEEING else SPEED)
			look_at(global_position + wish, Vector3.UP, true)
	velocity.x = wish.x
	velocity.z = wish.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()


func _arrive() -> void:
	if state == State.ENTERING:
		if _next == route.size() - 1:
			state = State.WAITING
			arrived.emit()
		else:
			_next += 1
	elif _next == 0:
		gone.emit()
		queue_free()
	else:
		_next -= 1


func _on_bump(body: Node3D) -> void:
	if body is Cop and (body as Cop).velocity.length() > STRUCK_SPEED:
		bumped.emit()


func _say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	get_tree().create_timer(3.0).timeout.connect(_bubble.hide)
