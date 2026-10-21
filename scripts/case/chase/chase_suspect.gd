class_name ChaseSuspect
extends CharacterBody3D

## The chase suspect once his vehicle is stopped (persecucion.md, "Cómo es el caso"): he gets out, gives up and
## stands by it complaining, until a cop cuffs him. Cuffed, the cops walk him to the patrol car like a raid's owner
## (OwnerEscort). What he says shows over his head.

const MODELS := {
	"ice_cream": preload("res://assets/models/npc_heladero.glb"),
	"moving_truck": preload("res://assets/models/npc_mudancero.glb"),
}
## Seconds a line stays over his head, and between two complaints.
const LINE_SECONDS := 3.0
const COMPLAIN_EVERY := 5.0

## Which suspect he is (ChaseCase.SUSPECTS): his model and his lines.
var kind := "ice_cream"
## Seconds of cuffs left (OwnerEscort keeps them on while he's walked).
var _cuffed_left := 0.0
var _since_line := 0.0
var _line := 0
var _bubble: Label3D


func _ready() -> void:
	add_to_group("chase_suspect")
	collision_layer = 8
	collision_mask = 7
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	add_child((MODELS[kind] as PackedScene).instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position.y = 1.9
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	_say(lines()[0])


## His complaints, as tr() keys.
func lines() -> Array[String]:
	var keys: Array[String] = []
	for i in 3:
		keys.append("CHASE_%s_LINE_%d" % [kind.to_upper(), i + 1])
	return keys


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	velocity.x = 0.0
	velocity.z = 0.0
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	_since_line += delta
	if _since_line >= COMPLAIN_EVERY:
		_line += 1
		_say(lines()[_line % lines().size()])


## Cuffed, E on him walks him to the patrol car (OwnerEscort); before that, nothing: cuff him first.
func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	return escort.prompt_key(cop) if escort and escort.handles_use() else ""


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)


## The handcuffs (Handcuffs.cuffable): he stays cuffed this long.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	_say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## OwnerEscort raises the owner's complaint when he's taken: this one has no meter.
func _raise(_points: float) -> void:
	pass


func _say(key: String, seconds := LINE_SECONDS) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == key:
			_bubble.hide())
