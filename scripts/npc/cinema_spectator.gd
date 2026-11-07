class_name CinemaSpectator
extends StaticBody3D

## One of the six neighbors watching the film at the "Cine Butaca Floja" (docs/diseno/allanamiento-cine.md, "El
## lugar"): they don't leave because the police came in ("¡Ya pagué la entrada!"). A cop or a prop bumping into them
## fast, or a cop standing between them and the screen for BLOCK_SECONDS, gets a "¡Shhh!": the cinema counts it (doña
## Bobina's complaint, step 3), at most once every SHUSH_COOLDOWN seconds each. Every number here is (propuesta).

signal shushed

## The neighbors' looks, one each.
const MODELS: Array[String] = ["res://assets/models/npc_vecina.glb", "res://assets/models/npc_senora.glb",
	"res://assets/models/npc_cliente.glb", "res://assets/models/npc_clienta.glb", "res://assets/models/npc_abuelo.glb",
	"res://assets/models/npc_alumno.glb"]
const LINES := 4
## Sitting: the model this much lower than standing, so the seat holds it.
const SIT_DROP := 0.45
const BUMP_SPEED := 2.0
## A cop this close in front of them, up to this far toward the screen, blocks their view.
const BLOCK_WIDTH := 0.8
const BLOCK_REACH := 4.0
const BLOCK_SECONDS := 3.0
const SHUSH_COOLDOWN := 10.0

## Their look (an index into MODELS) and the seat they sit in, in the cinema's list.
var look := 0
var seat := 0
var shushes := 0
## A line of their own, said instead of the usual ones (a story's neighbor sets it).
var line_override := ""
var _since_shush := SHUSH_COOLDOWN
var _blocked := 0.0
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("cinema_spectators")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 1.3, 0.6)
	shape.shape = box
	shape.position.y = 0.65
	add_child(shape)
	var model: Node3D = (load(MODELS[look % MODELS.size()]) as PackedScene).instantiate()
	model.position.y = -SIT_DROP
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.8, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.hide()
	add_child(_bubble)
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 2 | 4
	var reach := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.9
	reach.shape = sphere
	reach.position.y = 0.6
	area.add_child(reach)
	add_child(area)
	area.body_entered.connect(_on_bump)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CINEMA_SPECTATOR"


## E: they answer without taking their eyes off the screen.
func use(_cop: Cop) -> void:
	if line_override != "":
		say(line_override)
		return
	say("CINEMA_SPECTATOR_LINE_%d" % ((look + _lines_said) % LINES))
	_lines_said += 1


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


## "¡Shhh!": counted once every SHUSH_COOLDOWN seconds.
func shush() -> bool:
	if _since_shush < SHUSH_COOLDOWN:
		return false
	_since_shush = 0.0
	shushes += 1
	say("CINEMA_SHUSH")
	shushed.emit()
	return true


func _on_bump(body: Node3D) -> void:
	var speed := 0.0
	if body is Cop:
		speed = (body as Cop).velocity.length()
	elif body is RigidBody3D:
		speed = (body as RigidBody3D).linear_velocity.length()
	if speed > BUMP_SPEED:
		shush()


## Whether a cop stands in front of them, between them and the screen (+Z in the cinema); a seated one doesn't.
func view_blocked() -> bool:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop is Cop and (cop as Cop).seated_in:
			continue
		var off := (get_parent() as Node3D).to_local(cop.global_position) - position
		if off.z > 0.3 and off.z < BLOCK_REACH and absf(off.x) < BLOCK_WIDTH and absf(off.y) < 2.0:
			return true
	return false


func _physics_process(delta: float) -> void:
	_since_shush += delta
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	_blocked = _blocked + delta if view_blocked() else 0.0
	if _blocked >= BLOCK_SECONDS:
		_blocked = 0.0
		shush()
