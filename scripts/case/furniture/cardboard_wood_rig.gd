class_name CardboardWoodRig
extends FurnitureRig

## The cardboard wood (allanamiento-muebleria.md, "La madera de cartón"): Don Cajón sells cardboard furniture with a
## wood-look sticker as solid oak. The "Madera maciza" stamp is hidden with the roll of sticker and the cardboard
## invoices. One of the two "oak" wardrobes (drawn with the seed) weighs 3 kg: one cop alone pulls it over, the story's
## own clue (on the checklist the first time). And the showroom pieces weigh next to nothing: the dining room's chairs
## can be picked up and fly off when a cop walks into them. Every number here is (propuesta).

signal lifted(cop: Cop)

## What a cardboard chair weighs, and how hard a cop walking into it sends it flying.
const CHAIR_KG := 1.5
const BUMP_SPEED := 5.0
const BUMP_UP := 3.5
const CARDBOARD := Color(0.8, 0.62, 0.4)

## The cardboard wardrobe (an index of FurnitureStore.WARDROBES), and how many times one cop pulled it over.
var light_wardrobe := -1
var lifts := 0
## The dining room's chairs, now light enough to fly.
var light_chairs: Array[Grabbable] = []


func setup(place: FurnitureStore) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["cardboard wood", place.case_seed])
	light_wardrobe = rng.randi_range(0, FurnitureStore.WARDROBES.size() - 1)
	var wardrobe := place.wardrobes[light_wardrobe]
	wardrobe.light = true
	wardrobe.pulled_alone.connect(lift)
	for chair in place.chairs:
		light_chairs.append(_light_chair(chair))
	place.chairs.clear()


## `cop` pulled the cardboard wardrobe over alone: it weighs nothing and, the first time, that's the clue.
func lift(cop: Cop) -> void:
	lifts += 1
	var wardrobe := store.wardrobes[light_wardrobe]
	store.raid.float_label(tr("FURNITURE_LIGHT"), wardrobe.global_position + Vector3.UP * 2.4, CARDBOARD)
	cop.show_hint("HINT_WARDROBE_LIGHT")
	if lifts == 1:
		store.raid.add_clue(tr("CLUE_LIGHT_WARDROBE"))
	lifted.emit(cop)


## A light chair where `chair` stood (that one goes): grabbable, and it flies off when a cop walks into it.
func _light_chair(chair: StaticBody3D) -> Grabbable:
	var light := Grabbable.new()
	light.name = "CardboardChair"
	light.mass = CHAIR_KG
	light.collision_layer = 4
	light.collision_mask = 15
	for spec: Array in FurnitureStore.CHAIR_SHAPES:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = spec[1]
		shape.shape = box
		shape.position = spec[0]
		light.add_child(shape)
	light.add_child(FurnitureStore.CHAIR_MODEL.instantiate())
	var bump := Area3D.new()
	bump.collision_layer = 0
	bump.collision_mask = 2
	var reach := CollisionShape3D.new()
	var around := BoxShape3D.new()
	around.size = Vector3(0.6, 1.0, 0.6)
	reach.shape = around
	reach.position.y = 0.5
	bump.add_child(reach)
	light.add_child(bump)
	bump.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop and not light.is_held():
			kick(light, body))
	light.transform = chair.transform
	store.add_child(light)
	chair.queue_free()
	return light


## A cop walked into `chair`: it flies off the other way.
func kick(chair: Grabbable, cop: Node3D) -> void:
	var away := chair.global_position - cop.global_position
	away.y = 0.0
	away = away.normalized() if away.length() > 0.01 else Vector3.FORWARD
	chair.linear_velocity = away * BUMP_SPEED + Vector3.UP * BUMP_UP
	chair.angular_velocity = Vector3(away.z, 0, -away.x) * 6.0
