class_name AquariumClues
extends Node

## The aquarium case's clues where they go (escena-acuario.md, "Las pistas"), put by Aquarium when the case comes: the
## prints on the big tank's glass (a diver wipes it after a while, and they're gone), the flipper's print on the
## kitchen's dry floor, the hair in the hood forgotten on the bench, the bitten sandwich in the igloo (a penguin eats it
## after a while) and the ticket in the till. The ink shows on the divers' hands, and Doña Tinta comes in the next step.
## Every number here is (propuesta).

## A diver wipes the big tank's glass this long after the cops get there, in seconds; a penguin eats the sandwich then
## too.
const WIPE_SECONDS := 240.0
## Where the flipper print can be: on the kitchen's dry floor, off the way from the door to the bucket.
const FOOTPRINT_SPOTS: Array[Vector3] = [Vector3(8.5, 0, 3.0), Vector3(11.5, 0, 3.2), Vector3(9.0, 0, 6.2)]
const PUDDLE := Color(0.5, 0.56, 0.62)
## The hood forgotten on the bench, at its west end.
const HOOD_AT := Aquarium.BENCH_AT + Vector3(-1.0, 0.46, 0)

var aquarium: Aquarium
var case: CrimeSceneCase
var glass: EmptyFrame
var till: AquariumTill
var sandwich: CrimeClueItem
var has_bite := false
var _elapsed := 0.0


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	glass = EmptyFrame.new(Vector2(Aquarium.BIG_TANK_SIZE.x - 0.2, Aquarium.BIG_TANK_SIZE.y - 0.2))
	glass.name = "TankGlass"
	glass.look = "TANK"
	glass.case = case
	glass.has_prints = plan.clues.has("prints")
	glass.position = Aquarium.BIG_TANK_AT + Vector3(0, 0.4 + Aquarium.BIG_TANK_SIZE.y / 2,
		Aquarium.BIG_TANK_SIZE.z / 2 + 0.04)
	aquarium.add_child(glass)
	if plan.clues.has("footprint"):
		var footprint := FlourPrint.new()
		footprint.name = "FlipperPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		footprint.dust = PUDDLE
		footprint.position = FOOTPRINT_SPOTS[absi(hash(["aquarium footprint", case.case_seed])) % FOOTPRINT_SPOTS.size()] \
			+ Vector3(0, Aquarium.FLOOR_TOP - 0.04, 0)
		aquarium.add_child(footprint)
		case.flour_print = footprint
	# The hood is there in every case; the hair in it only when it's a clue.
	var hood := MeshInstance3D.new()
	hood.name = "ForgottenHood"
	var dome := SphereMesh.new()
	dome.radius = 0.2
	dome.height = 0.2
	dome.is_hemisphere = true
	hood.mesh = dome
	hood.material_override = PlaceBuilder.new(aquarium).material(Color(0.11, 0.11, 0.14))
	hood.position = HOOD_AT
	aquarium.add_child(hood)
	if plan.clues.has("hair"):
		var hair := CrimeClueItem.new()
		hair.name = "Clue_hair"
		hair.kind = "hair"
		hair.look = "aquarium"
		hair.case = case
		hair.hair_color = CookTraits.HAIRS[who.hair]
		hair.position = HOOD_AT + Vector3(0.3, 0.0, 0)
		aquarium.add_child(hair)
		case.items["hair"] = hair
	has_bite = plan.clues.has("bite")
	till = AquariumTill.new()
	till.name = "Till"
	till.case = case
	till.has_ticket = plan.clues.has("ticket")
	till.position = Aquarium.TILL_AT + Vector3(0.4, 1.0, 0)
	aquarium.add_child(till)


## A search of a spot is over (Aquarium.searched): in the igloo, the bitten sandwich turns up too.
func searched(spot: String) -> void:
	if spot != "igloo" or not has_bite or sandwich or case.ruined.has("bite"):
		return
	sandwich = CrimeClueItem.new()
	sandwich.name = "Clue_bite"
	sandwich.kind = "bite"
	sandwich.look = "aquarium"
	sandwich.case = case
	var body := aquarium.loot_spots["igloo"] as Node3D
	sandwich.position = Vector3(body.position.x, Aquarium.FLOOR_TOP, body.position.z) + body.get_meta("out") \
		+ Vector3(0.5, 0, 0)
	aquarium.add_child(sandwich)
	case.items["bite"] = sandwich


func _physics_process(delta: float) -> void:
	if case.follower or not case.at_tent or _elapsed >= WIPE_SECONDS:
		return
	_elapsed += delta
	if _elapsed >= WIPE_SECONDS:
		wipe_the_glass()
		penguin_lunch()


## A diver's rag on the big tank's glass: whatever prints were on it are gone.
func wipe_the_glass() -> void:
	if glass.has_prints and not case.clues_found.has("prints"):
		glass.has_prints = false
		case.ruin("prints")


## A penguin finds the sandwich, in the igloo or out of it, unless it's bagged.
func penguin_lunch() -> void:
	if not has_bite or case.clues_found.has("bite"):
		return
	if sandwich and not sandwich.bagged:
		sandwich.spoiled = true
		sandwich.visible = false
	case.ruin("bite")
