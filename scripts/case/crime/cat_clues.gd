class_name CatClues
extends Node

## The cat case's clues in the Monedero mansion (escena-gato.md, "Las pistas"), put by CatMansion when the case comes:
## the prints on the cat flap, the footprint in the laundry's litter tray, the hair on Duquesa's velvet armchair, the
## bitten cat biscuit by the jar and the diamond necklace hidden in one of the spots. The cats spoil two of them: one
## that comes by the flap covers the prints with mud, one that uses the litter tray covers the footprint. A cop who
## sits in the armchair (gets into it) loses the hair. Every number here is (propuesta).

## A loose cat this close to the flap (inside) or to the litter tray spoils its clue; a cop this close to the
## armchair's middle sat in it.
const FLAP_REACH := 0.7
const LITTER_REACH := 0.5
const ARMCHAIR_REACH := 0.55
const LITTER := Color(0.82, 0.78, 0.68)
const HAIR_AT := CatMansion.ARMCHAIR_AT + Vector3(0.1, 0.57, 0.12)
const BISCUIT_AT := CatMansion.BISCUITS_AT + Vector3(0.25, CatMansion.FLOOR_TOP + 0.01, 0.0)

var mansion: CatMansion
var case: CrimeSceneCase
var flap: EmptyFrame
var footprint: FlourPrint
var necklace: CatNecklace
## The spot the necklace is hidden in (a spot of CatMansion.search_spots), and whether it came out.
var necklace_spot := ""
var necklace_out := false
## The cops in Duquesa's armchair now, so each sit costs the señora's patience once.
var _sitting := {}


func _ready() -> void:
	var plan := case.plan
	flap = EmptyFrame.new(CatMansion.CAT_FLAP_SIZE)
	flap.name = "CatFlapPrints"
	flap.look = "CAT_FLAP"
	flap.case = case
	flap.has_prints = plan.clues.has("prints")
	flap.position = CatMansion.CAT_FLAP_AT + Vector3(0, 0, 0.13)
	mansion.add_child(flap)
	if plan.clues.has("footprint"):
		footprint = FlourPrint.new()
		footprint.name = "LitterPrint"
		footprint.case = case
		footprint.shoe = case.culprit().shoe
		footprint.dust = LITTER
		footprint.patch = Vector2(CatMansion.LITTER_SIZE.x - 0.12, CatMansion.LITTER_SIZE.z - 0.12)
		# On top of the litter, which fills the tray up to 0.14 m.
		footprint.position = CatMansion.LITTER_AT + Vector3(0, 0.1, 0)
		mansion.add_child(footprint)
		case.flour_print = footprint
	if plan.clues.has("hair"):
		_clue_item("hair", HAIR_AT)
	if plan.clues.has("bite"):
		_clue_item("bite", BISCUIT_AT)
	var kinds := CatMansion.HIDING_SPOTS.filter(func(kind: String) -> bool:
		return kind != mansion.duchess_spot.get_slice("_", 0))
	var kind: String = kinds[absi(hash("necklace spot %d" % case.case_seed)) % kinds.size()]
	necklace_spot = "suitcase_%d" % plan.culprit if kind == "suitcase" else kind


func _clue_item(kind: String, at: Vector3) -> void:
	var item := CrimeClueItem.new()
	item.name = "Clue_" + kind
	item.kind = kind
	item.look = "mansion"
	item.case = case
	item.hair_color = CookTraits.HAIRS[case.culprit().hair]
	item.position = at
	mansion.add_child(item)
	case.items[kind] = item


## Searching the necklace's spot: out it comes, on the floor in front of it.
func reveal_necklace(at: Vector3) -> void:
	necklace_out = true
	necklace = CatNecklace.new()
	necklace.name = "Necklace"
	necklace.case = case
	necklace.side = case.culprit().scratch
	mansion.add_child(necklace)
	necklace.global_position = at


func _physics_process(_delta: float) -> void:
	if case.follower:
		return
	for node in get_tree().get_nodes_in_group("mansion_cats"):
		var cat := node as MansionCat
		if cat.shut_in or cat.home or cat.crate or cat.is_held():
			continue
		if _near(cat, CatMansion.CAT_FLAP_AT, FLAP_REACH):
			muddy_flap()
		if footprint and not footprint.wiped and _near(cat, CatMansion.LITTER_AT, LITTER_REACH):
			footprint.wipe()
	for cop in get_tree().get_nodes_in_group("cops"):
		var sitting := _near(cop, CatMansion.ARMCHAIR_AT, ARMCHAIR_REACH)
		if sitting and not _sitting.has(cop):
			sat_in_armchair()
		if sitting:
			_sitting[cop] = true
		else:
			_sitting.erase(cop)
	if necklace and not necklace.worn and necklace.is_held() and mansion.lady and \
			_near(necklace, mansion.lady.position, MansionLady.TAKE_REACH):
		give_necklace()


## A cat came in through the flap with muddy paws: the prints on it are gone.
func muddy_flap() -> void:
	if flap.has_prints and not flap.touched and not case.clues_found.has("prints"):
		flap.touched = true
		case.ruin("prints")


## A cop got into Duquesa's armchair: the hair on it is gone, and the señora's patience goes down.
func sat_in_armchair() -> void:
	if mansion.patience:
		mansion.patience.lose("armchair")
	var hair: CrimeClueItem = case.items.get("hair")
	if hair and mansion.to_local(hair.global_position).distance_to(HAIR_AT) <= 0.3:
		hair.wash()


## The necklace brought to the señora: she takes it and puts it on.
func give_necklace() -> void:
	necklace.release_all()
	necklace.put_on()
	necklace.freeze = true
	necklace.collision_layer = 0
	necklace.reparent(mansion.lady)
	necklace.position = Vector3(0, 1.18, 0.12)
	mansion.lady.say("MANSION_LADY_NECKLACE")


func _near(node: Node3D, local: Vector3, reach: float) -> bool:
	var off := mansion.to_local(node.global_position) - local
	return Vector2(off.x, off.z).length() <= reach
