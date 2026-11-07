class_name PizzaOven
extends Area3D

## The mouth of Don Muzza's clay oven (docs/diseno/allanamiento-pizzeria.md, "El horno de barro"): what stays in it
## longer than BURN_TIME burns, once: evidence loses half its value, and paper (PAPER_KG or less) burns whole. A cop
## who puts a hand in (E) lets go of what they held. Put out (the oven tunnel story), nothing burns and E crawls in
## instead. Every number here is (propuesta).

## Something a cop just handled went in (Don Muzza minds it if he sees it).
signal fed(item: Grabbable)
signal burned(item: Grabbable)
## A cop crawled into the oven once it was put out.
signal crawled_in(cop: Cop)

const MOUTH_SIZE := Vector3(0.9, 0.45, 0.6)
const BURN_TIME := 3.0
const BURN_SHARE := 0.5
const PAPER_KG := 0.15
## How recently a cop must have let go of it for it to count as put in.
const PUT_IN := 2.0
const SMOKE := Color(0.3, 0.28, 0.27, 0.6)

var button: PushButton
## Burning; put out, it burns nothing and a cop can crawl in.
var lit := true
## Shows while something is in the mouth, so the cops see it coming.
var smoke: MeshInstance3D
## Grabbable -> seconds it has been in the mouth.
var _inside := {}
var _burned := {}


func _ready() -> void:
	collision_layer = 0
	collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = MOUTH_SIZE
	shape.shape = box
	add_child(shape)
	button = PushButton.new()
	button.prompt = "PROMPT_OVEN_HAND"
	button.position = Vector3(0, 0, MOUTH_SIZE.z / 2)
	add_child(button)
	for part in button.get_children():
		if part is MeshInstance3D:
			part.hide()
	button.pressed.connect(_hand_in)
	var puff := SphereMesh.new()
	puff.radius = 0.3
	puff.height = 0.5
	var material := StandardMaterial3D.new()
	material.albedo_color = SMOKE
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff.material = material
	smoke = MeshInstance3D.new()
	smoke.mesh = puff
	smoke.position = Vector3(0, MOUTH_SIZE.y, MOUTH_SIZE.z / 2)
	smoke.visible = false
	add_child(smoke)
	body_entered.connect(_on_entered)
	body_exited.connect(func(body: Node3D) -> void: _inside.erase(body))


func _on_entered(body: Node3D) -> void:
	var item := body as Grabbable
	if not item:
		return
	_inside[item] = 0.0
	if not item.handling_cops(PUT_IN).is_empty():
		fed.emit(item)


## The hand in the oven (or, put out, the whole cop): whatever the cop held drops, and it burns.
func _hand_in(cop: Cop) -> void:
	if not lit:
		crawled_in.emit(cop)
		return
	cop.get_node("Grabber").release()
	cop.show_hint("HINT_OVEN_HOT")


func _physics_process(delta: float) -> void:
	smoke.visible = lit and not _inside.is_empty()
	# The host burns things; PropSync shows the guests what is left.
	if not multiplayer.is_server() or not lit:
		return
	for item: Grabbable in _inside.keys():
		if not is_instance_valid(item):
			_inside.erase(item)
			continue
		_inside[item] += delta
		if _inside[item] >= BURN_TIME and not _burned.has(item):
			_burned[item] = true
			burn(item)


## Burns `item` once: half its value, or all of it if it is paper.
func burn(item: Grabbable) -> void:
	var evidence := item as Evidence
	if evidence and not evidence.is_broken:
		var loss := evidence.value if item.mass <= PAPER_KG else evidence.value * BURN_SHARE
		evidence.value -= loss
		evidence._show_value()
		evidence.damaged.emit(loss)
		if evidence.value <= 0.0:
			evidence.is_broken = true
			evidence.broken.emit()
	burned.emit(item)
