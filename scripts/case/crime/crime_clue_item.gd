class_name CrimeClueItem
extends Grabbable

## A clue the cops carry (escena-del-crimen.md, "Las pistas"): the plate of cream with a hair in it, the bitten slice
## and the stolen recipe. E with it in hand, aiming at the evidence bags (EvidenceBags), puts it in a bag: then it's
## found and safe. E anywhere else with food in hand eats it, and the clue is gone; the recipe gets ruined if coffee
## (CoffeeCup) ends up on it. At the circus (`look` "circus") the hair is a loose one on the pool's floor (not food; the
## pool's tap washes it away, Circus.open_tap) and the bite is in a raw fish. At the museum (`look` "museum") the hair is
## loose too, on the velvet rope's post, and the bite is in the guards' sandwich. At the hotel (`look` "hotel") the
## hair is loose on the suite's pillow and the bite is in the bonbon left on it. At the planetarium (`look`
## "planetarium") the hair is loose by a forgotten helmet and the bite is in a pouch of astronaut ice cream. Every number
## here is (propuesta).

## A coffee cup this close to the recipe wets it, in meters.
const WET_REACH := 0.4
const PLATE := Color(0.97, 0.96, 0.93)
const CREAM := Color(1.0, 0.97, 0.88)
const SPONGE := Color(0.93, 0.78, 0.5)
const PAPER := Color(0.95, 0.93, 0.85)
const WET := Color(0.55, 0.4, 0.28)
const BAG := Color(0.85, 0.9, 1.0, 0.4)
const FISH := Color(0.75, 0.8, 0.85)
const FISH_BELLY := Color(0.9, 0.9, 0.85)
const CHOCOLATE := Color(0.35, 0.2, 0.12)
const FOIL := Color(0.85, 0.68, 0.3)

## "hair", "bite" or "recipe".
var kind := "hair"
## "pastry", "circus", "museum", "hotel" or "planetarium": what the clue looks like.
var look := "pastry"
var case: CrimeSceneCase
## The culprit's hair color, for the hair in the cream.
var hair_color := Color.BLACK
var bagged := false
## Eaten (food) or wet (the recipe): it no longer says anything.
var spoiled := false
var _eaten_part: Node3D
var _paper: MeshInstance3D


func _ready() -> void:
	add_to_group("crime_clue_items")
	mass = 0.05 if kind == "recipe" else 0.4
	collision_layer = 4
	collision_mask = 15
	var size := {"hair": Vector3(0.32, 0.12, 0.32), "bite": Vector3(0.14, 0.1, 0.22),
		"recipe": Vector3(0.21, 0.02, 0.3)}[kind] as Vector3
	if _loose():
		size = {"hair": Vector3(0.24, 0.03, 0.24), "bite": Vector3(0.14, 0.1, 0.42)}.get(kind, size)
	elif look == "hotel":
		size = Vector3(0.08, 0.05, 0.08)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position.y = size.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	if _loose():
		_circus_look()
		return
	if look == "hotel":
		_bonbon(builder)
		return
	if look == "planetarium" and kind == "bite":
		_ice_cream()
		return
	match kind:
		"hair":
			var plate := CylinderMesh.new()
			plate.top_radius = 0.16
			plate.bottom_radius = 0.13
			plate.height = 0.02
			builder.mesh(plate, Vector3(0, 0.01, 0), PLATE)
			_eaten_part = Node3D.new()
			add_child(_eaten_part)
			var cream := PlaceBuilder.new(_eaten_part)
			var dollop := SphereMesh.new()
			dollop.radius = 0.08
			dollop.height = 0.09
			cream.mesh(dollop, Vector3(0, 0.05, 0), CREAM)
			cream.mesh_box(Vector3(0.02, 0.095, 0), Vector3(0.006, 0.004, 0.12), hair_color)
		"bite":
			builder.mesh_box(Vector3(0, 0.05, 0.02), Vector3(0.12, 0.1, 0.18), SPONGE)
			builder.mesh_box(Vector3(0, 0.1, 0.02), Vector3(0.125, 0.01, 0.185), CREAM)
			# The bite: a dark notch at the tip.
			builder.mesh_box(Vector3(0, 0.07, -0.07), Vector3(0.126, 0.05, 0.03), WET)
			_eaten_part = get_child(get_child_count() - 1) as Node3D
		"recipe":
			# Over the plaza's grass, which sits a few centimeters above the ground it stands on.
			builder.mesh_box(Vector3(0, 0.04, 0), Vector3(0.21, 0.005, 0.3), PAPER)
			_paper = get_child(get_child_count() - 1) as MeshInstance3D


## At the circus: a few loose hairs, and a fish with a bite out of its middle.
func _circus_look() -> void:
	_eaten_part = Node3D.new()
	add_child(_eaten_part)
	var part := PlaceBuilder.new(_eaten_part)
	match kind:
		"hair":
			var strand := BoxMesh.new()
			strand.size = Vector3(0.012, 0.012, 0.22)
			for i in 3:
				part.mesh(strand, Vector3(-0.04 + i * 0.04, 0.01, 0), hair_color, Vector3(0, 0.3 * (i - 1), 0))
		"bite":
			part.mesh_box(Vector3(0, 0.045, 0), Vector3(0.11, 0.09, 0.32), FISH)
			part.mesh_box(Vector3(0, 0.015, 0), Vector3(0.1, 0.03, 0.3), FISH_BELLY)
			var tail := BoxMesh.new()
			tail.size = Vector3(0.025, 0.09, 0.09)
			part.mesh(tail, Vector3(0, 0.045, 0.19), FISH, Vector3(PI / 4, 0, 0))
			# The bite: a dark notch in its side.
			part.mesh_box(Vector3(0.05, 0.05, -0.02), Vector3(0.03, 0.06, 0.08), WET)


## The planetarium's astronaut ice cream: a silver pouch, open, with the freeze-dried block bitten at one corner.
func _ice_cream() -> void:
	PlaceBuilder.new(self).mesh_box(Vector3(0, 0.01, 0.02), Vector3(0.13, 0.02, 0.2), Color(0.8, 0.82, 0.86))
	_eaten_part = Node3D.new()
	add_child(_eaten_part)
	var part := PlaceBuilder.new(_eaten_part)
	part.mesh_box(Vector3(0, 0.035, -0.01), Vector3(0.1, 0.03, 0.06), Color(0.95, 0.75, 0.8))
	part.mesh_box(Vector3(0, 0.035, 0.05), Vector3(0.1, 0.03, 0.06), CREAM)
	part.mesh_box(Vector3(0, 0.035, 0.11), Vector3(0.1, 0.03, 0.06), CHOCOLATE)
	# The bite: a dark notch at one corner.
	part.mesh_box(Vector3(0.035, 0.04, -0.03), Vector3(0.04, 0.04, 0.03), WET)


## The hotel's bonbon: a chocolate square in its gold foil, with a bite out of one corner.
func _bonbon(builder: PlaceBuilder) -> void:
	builder.mesh_box(Vector3(0, 0.004, 0), Vector3(0.08, 0.008, 0.08), FOIL)
	_eaten_part = Node3D.new()
	add_child(_eaten_part)
	var part := PlaceBuilder.new(_eaten_part)
	part.mesh_box(Vector3(0, 0.028, 0), Vector3(0.05, 0.04, 0.05), CHOCOLATE)
	part.mesh_box(Vector3(0.02, 0.04, 0.02), Vector3(0.02, 0.02, 0.02), SPONGE.lightened(0.3))


## The circus's look: its loose hair and its fish. The museum's, the hotel's and the planetarium's hair are loose too.
func _loose() -> bool:
	return look == "circus" or (look in ["museum", "hotel", "planetarium"] and kind == "hair")


## Food can be eaten (and the clue with it); the circus's loose hair can't.
func is_food() -> bool:
	return kind == "bite" or (kind == "hair" and look == "pastry")


func held_prompt_key(cop: Cop) -> String:
	if bagged:
		return "PROMPT_BAGGED_CLUE"
	if cop._usable_target() is EvidenceBags:
		return "PROMPT_BAG_CLUE"
	return "PROMPT_EAT_CLUE" if is_food() else "PROMPT_HOLDING"


## E with it in hand: into a bag if the cop aims at the bags; eaten if it's food; nothing otherwise.
func used_in_hand(cop: Cop, aimed: Node) -> void:
	if bagged:
		cop.show_hint("HINT_CLUE_BAGGED_ALREADY")
		return
	if aimed is EvidenceBags:
		bag(cop)
	elif is_food():
		eat(cop)


func bag(cop: Cop) -> void:
	if bagged:
		return
	bagged = true
	var builder := PlaceBuilder.new(self)
	var size := ((get_child(0) as CollisionShape3D).shape as BoxShape3D).size
	builder.mesh_box(Vector3(0, size.y / 2, 0), size + Vector3(0.06, 0.06, 0.06), BAG)
	if spoiled:
		cop.show_hint("HINT_CLUE_BAGGED_SPOILED")
	elif case:
		case.found(kind)


func eat(cop: Cop) -> void:
	if spoiled:
		cop.show_hint("HINT_CLUE_NOTHING_LEFT")
		return
	spoiled = true
	_eaten_part.visible = false
	cop.show_hint("HINT_CLUE_EATEN_" + kind + ("" if look == "pastry" else "_" + look))
	if case:
		case.ruin(kind)


## The pool's water carried it away (the circus's loose hair).
func wash() -> void:
	if bagged or spoiled:
		return
	spoiled = true
	_eaten_part.visible = false
	if case:
		case.ruin(kind)


func _physics_process(delta: float) -> void:
	super(delta)
	if kind != "recipe" or bagged or spoiled:
		return
	for cup in get_tree().get_nodes_in_group("coffee_cups"):
		if (cup as Node3D).global_position.distance_to(global_position) <= WET_REACH:
			wet()
			return


## Coffee on the recipe: the ink runs.
func wet() -> void:
	spoiled = true
	_paper.material_override = PlaceBuilder.new(self).material(WET)
	if case:
		case.ruin("recipe")
