class_name FarmGoat
extends CharacterBody3D

## Tota, Don Florencio's goat (docs/diseno/allanamiento-granja.md, "La cabra Tota"): she wanders the yard and eats any
## paper she finds lying on the ground (a note, a receipt, a list: anything under PAPER_KG that is a ClueNote or has
## the "paper" meta). DIGEST seconds later she "gives it back" in the corral, a little chewed (the "chewed" meta: the
## case pays half for chewed evidence). Every number here is (propuesta).

signal ate(item: Grabbable)
signal gave_back(item: Grabbable)

const MODEL := preload("res://assets/models/farm_goat.glb")
const PAPER_KG := 0.5
const SPEED := 1.2
const SNIFF_RANGE := 6.0
const BITE := 0.6
## Lying on the ground: lower than this over her feet.
const ON_GROUND := 0.3
const DIGEST := 30.0
const WANDER_EVERY := 4.0
const SNIFF_EVERY := 0.5

## Where she wanders and where she gives things back, in the farm's space (set before she's added).
var yard := Rect2()
var give_back_at := Vector3.ZERO
var farm: Node3D
var rng := RandomNumberGenerator.new()
## What she ate, with the seconds left until she gives each back.
var eaten := {}
var _target := Vector3.ZERO
var _chasing: Grabbable
var _wander_left := 0.0
var _sniff_left := 0.0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.4, 0.8, 0.9)
	shape.shape = box
	shape.position.y = 0.4
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.position = Vector3(0, 1.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.hide()
	add_child(_bubble)
	_target = global_position


## Whether she'd eat it: light paper lying loose on the ground.
static func is_paper(item: Node) -> bool:
	var grab := item as Grabbable
	if not grab or grab.mass >= PAPER_KG:
		return false
	return grab is ClueNote or grab.has_meta("paper")


func _physics_process(delta: float) -> void:
	_digest(delta)
	_sniff_left -= delta
	if _sniff_left <= 0.0:
		_sniff_left = SNIFF_EVERY
		_chasing = _nearest_paper()
	var target := _target
	if _chasing:
		target = _chasing.global_position
		var flat := target - global_position
		flat.y = 0.0
		if flat.length() <= BITE:
			eat(_chasing)
			_chasing = null
	elif farm:
		_wander_left -= delta
		if _wander_left <= 0.0:
			_wander_left = WANDER_EVERY * rng.randf_range(0.6, 1.4)
			_target = farm.to_global(Vector3(rng.randf_range(yard.position.x, yard.end.x), 0,
				rng.randf_range(yard.position.y, yard.end.y)))
	var to := target - global_position
	to.y = 0.0
	var walk := to.normalized() * SPEED if to.length() > 0.3 else Vector3.ZERO
	velocity.x = walk.x
	velocity.z = walk.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	if walk != Vector3.ZERO:
		rotation.y = atan2(walk.x, walk.z)


## Gulp: it's gone until she gives it back.
func eat(item: Grabbable) -> void:
	if eaten.has(item) or item.is_held():
		return
	eaten[item] = DIGEST
	item.freeze = true
	item.visible = false
	item.process_mode = Node.PROCESS_MODE_DISABLED
	item.global_position = global_position + Vector3.DOWN * 5.0
	_say("GOAT_CHEW")
	ate.emit(item)


func _digest(delta: float) -> void:
	for item: Grabbable in eaten.keys():
		eaten[item] -= delta
		if eaten[item] > 0.0:
			continue
		eaten.erase(item)
		if not is_instance_valid(item):
			continue
		item.set_meta("chewed", true)
		item.process_mode = Node.PROCESS_MODE_INHERIT
		item.global_position = farm.to_global(give_back_at) if farm else global_position
		item.visible = true
		item.freeze = false
		_say("GOAT_BURP")
		gave_back.emit(item)


func _nearest_paper() -> Grabbable:
	var best: Grabbable
	var best_distance := SNIFF_RANGE
	for node in get_parent().get_children():
		var item := node as Grabbable
		if not item or eaten.has(item) or not is_paper(item) or item.is_held() or not item.visible:
			continue
		if item.global_position.y - global_position.y > ON_GROUND:
			continue
		var d := global_position.distance_to(item.global_position)
		if d < best_distance:
			best = item
			best_distance = d
	return best


func _say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(1.5).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
