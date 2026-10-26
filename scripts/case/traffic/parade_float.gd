class_name ParadeFloat
extends RefCounted

## The parade check (control-desfile.md): the checkpoint's in the middle of a parade of slow floats, each a truck under
## a painted skirt with a theme on its front and masked dancers on its back, among a few city cars caught in it. One of
## the dancers is El Antifaz, who stole the parade queen's crown (step 4). Every number here is (propuesta).

## The themes riding on the floats' fronts, the names the radio gives them, and their models.
const THEMES: Array[String] = ["dragon", "ship", "cake", "castle", "volcano", "whale", "rocket"]
const THEME_NAMES: Array[String] = ["PARADE_THEME_DRAGON", "PARADE_THEME_SHIP", "PARADE_THEME_CAKE",
	"PARADE_THEME_CASTLE", "PARADE_THEME_VOLCANO", "PARADE_THEME_WHALE", "PARADE_THEME_ROCKET"]
const THEME_MODELS: Array[PackedScene] = [preload("res://assets/models/float_dragon.glb"),
	preload("res://assets/models/float_ship.glb"), preload("res://assets/models/float_cake.glb"),
	preload("res://assets/models/float_castle.glb"), preload("res://assets/models/float_volcano.glb"),
	preload("res://assets/models/float_whale.glb"), preload("res://assets/models/float_rocket.glb")]
## The floats' skirts and their dancers' costumes (a float's troupe all dress alike): not a clue.
const SKIRTS: Array[Color] = [Color("e84a9a"), Color("4ab0e8"), Color("f0a020"), Color("8a4ac8"), Color("3ab07a")]
## The dancers' masks (the antifaz) and the names the radio gives them.
const MASKS: Array[Color] = [Color("e0302a"), Color("2a6ad8"), Color("3aa04a"), Color("f0c830"), Color("f4f4f0")]
const MASK_NAMES: Array[String] = ["COLOR_RED", "COLOR_BLUE", "COLOR_GREEN", "COLOR_YELLOW", "COLOR_WHITE"]
## What the dancers hold in their hands, the names the radio gives them, and their models.
const HELD: Array[String] = ["pompoms", "maracas", "fan", "ribbon"]
const HELD_NAMES: Array[String] = ["PARADE_HELD_POMPOMS", "PARADE_HELD_MARACAS", "PARADE_HELD_FAN",
	"PARADE_HELD_RIBBON"]
const HELD_MODELS: Array[PackedScene] = [preload("res://assets/models/held_pompom.glb"),
	preload("res://assets/models/held_maracas.glb"), preload("res://assets/models/held_fan.glb"),
	preload("res://assets/models/held_ribbon.glb")]
## The numbers on the floats' signs.
const NUMBERS := Vector2i(1, 30)
## How many dance on each float.
const DANCERS := Vector2i(3, 5)
## Without a plan, about this share of the queue are floats; the rest, city cars caught in the parade.
const SHARE := 0.7
const FLOAT_MODEL := preload("res://assets/models/parade_float.glb")
const DANCER_MODEL := preload("res://assets/models/parade_dancer.glb")
const ARM_MODEL := preload("res://assets/models/parade_arm.glb")
## On the float (forward +Z): its size, its deck's height, the theme's place on the front and the dancers' places on
## the back (the first ones first), the signs on its sides and the banner over its front.
const SIZE := Vector3(2.3, 0.9, 4.6)
const DECK := 0.94
const THEME_AT := Vector3(0, DECK, 1.35)
const THEME_SIZE := Vector3(2.0, 1.6, 1.8)
const DANCER_AT: Array[Vector3] = [Vector3(-0.6, DECK, -1.9), Vector3(0.6, DECK, -1.9), Vector3(0, DECK, -1.1),
	Vector3(0, DECK, -1.9), Vector3(-0.6, DECK, -1.1)]
const DANCER_SCALE := 0.7
## On a dancer before its scale: its shoulders, where each arm hangs from, and its hand on the arm.
const SHOULDER := Vector3(0.3, 0.85, 0)
const HAND := Vector3(0.16, -0.22, 0.08)
const SIGN_AT := Vector3(1.17, 0.55, 0.4)


## A car's parade traits when no plan says them: from its plate, so every PC agrees. Empty for a city car.
static func traits_of(plate: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["parade traits", plate])
	if rng.randf() >= SHARE:
		return {}
	return draw(rng)


## A float's theme (one of THEMES), its skirt (one of SKIRTS), its sign's number and its dancers, each with a mask
## (one of MASKS) and what they hold (one of HELD).
static func draw(rng: RandomNumberGenerator) -> Dictionary:
	var dancers: Array = []
	for i in rng.randi_range(DANCERS.x, DANCERS.y):
		dancers.append({"mask": rng.randi() % MASKS.size(), "held": rng.randi() % HELD.size()})
	return {"theme": THEMES[rng.randi() % THEMES.size()], "skirt": rng.randi() % SKIRTS.size(),
		"number": rng.randi_range(NUMBERS.x, NUMBERS.y), "dancers": dancers}


## The name the radio gives `theme`.
static func theme_name(theme: String) -> String:
	return THEME_NAMES[maxi(THEMES.find(theme), 0)]


## Builds `car` (a QueueCar) as the float in `traits`: its body to bump into, the skirted truck, its theme on the
## front, its number on both sides and its dancers on the back, the driver hidden under the skirt.
static func build(car: QueueCar, traits: Dictionary) -> void:
	car._add_box(SIZE, Vector3(0, SIZE.y / 2 + 0.05, 0))
	car._add_box(THEME_SIZE, THEME_AT + Vector3(0, THEME_SIZE.y / 2, 0))
	var skirt := StandardMaterial3D.new()
	skirt.albedo_color = SKIRTS[int(traits.get("skirt", 0)) % SKIRTS.size()]
	var model: Node3D = FLOAT_MODEL.instantiate()
	model.name = "Model"
	car.add_child(model)
	QueueCar._paint(model, skirt)
	var theme: Node3D = THEME_MODELS[maxi(THEMES.find(traits.get("theme", "")), 0)].instantiate()
	theme.name = "Theme"
	theme.position = THEME_AT
	car.add_child(theme)
	for side: float in [1.0, -1.0]:
		var sign := _label(car.tr("PARADE_SIGN") % int(traits.get("number", 1)), 64, Color(0.98, 0.85, 0.3))
		sign.name = "Sign" if side > 0.0 else "SignLeft"
		sign.position = Vector3(side * SIGN_AT.x, SIGN_AT.y, SIGN_AT.z)
		sign.rotation.y = side * PI / 2
		car.add_child(sign)
	var troupe := Node3D.new()
	troupe.name = "Dancers"
	car.add_child(troupe)
	var dancers: Array = traits.get("dancers", [])
	for i in mini(dancers.size(), DANCER_AT.size()):
		var dancer := _dancer(dancers[i], skirt)
		dancer.name = "Dancer%d" % i
		dancer.position = DANCER_AT[i]
		troupe.add_child(dancer)


## One dancer, facing back toward the cops behind the float: the body with its mask, and its two arms, each with what
## it holds in the hand.
static func _dancer(traits: Dictionary, costume: Material) -> Node3D:
	var dancer := Node3D.new()
	dancer.scale = Vector3.ONE * DANCER_SCALE
	dancer.rotation.y = PI
	var body: Node3D = DANCER_MODEL.instantiate()
	body.name = "Body"
	dancer.add_child(body)
	QueueCar._paint(body, costume)
	var mask := StandardMaterial3D.new()
	mask.albedo_color = MASKS[int(traits.get("mask", 0)) % MASKS.size()]
	for part in body.find_children("mask*", "MeshInstance3D", true, false):
		(part as MeshInstance3D).material_override = mask
	for part in body.find_children("*", "MeshInstance3D", true, false):
		if part.get_parent().name == "mask":
			(part as MeshInstance3D).material_override = mask
	for side: float in [1.0, -1.0]:
		var arm: Node3D = ARM_MODEL.instantiate()
		arm.name = "ArmRight" if side > 0.0 else "ArmLeft"
		arm.position = Vector3(side * SHOULDER.x, SHOULDER.y, SHOULDER.z)
		arm.scale.x = side
		dancer.add_child(arm)
		var held: Node3D = HELD_MODELS[int(traits.get("held", 0)) % HELD.size()].instantiate()
		held.name = "Held"
		held.position = HAND
		arm.add_child(held)
		QueueCar._paint(arm, costume)
	return dancer


## The dancers on `car`'s float, the first one first; empty for a city car.
static func dancers_of(car: Node3D) -> Array[Node3D]:
	var out: Array[Node3D] = []
	var troupe := car.get_node_or_null("Dancers")
	if troupe:
		for dancer in troupe.get_children():
			out.append(dancer as Node3D)
	return out


static func _label(text: String, size: int, color: Color) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.004
	label.modulate = color
	label.outline_modulate = Color(0.1, 0.08, 0.06)
	label.outline_size = 14
	return label
