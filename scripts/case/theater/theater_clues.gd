class_name TheaterClues
extends Node

## The theater case's clues where they go (escena-teatro.md, "Las pistas"), put by Theater when the case comes:
## - the prints on the glass of the mask's case (the usher wipes it after POLISH_SECONDS, and they're gone);
## - the talc footprint on the back of the stage (TalcPrint: the first scene change brings it into view, the next one
##   sweeps it away);
## - the hair in the wig left on a trapdoor on the way to the workshop (if the trapdoor opens before it's bagged, it
##   drops to the basement and is lost);
## - the bitten bonbon in the east box (searching the box finds it; the lady in the box wakes up after BOX_LADY_SECONDS
##   and eats it);
## - the scrap of sheet on a nail of the mask's case, with the culprit's embroidery (SheetScrap).
## The deep voice is in the ghosts' singing (TheaterGhost), and Don Susurro as a witness comes in the next step. Every
## number here is (propuesta).

const BOX_LADY_SECONDS := 180.0
const POLISH_SECONDS := 240.0
## The talc footprint, on the back of the stage east of the flat.
const FOOTPRINT_AT := Vector3(4.6, Theater.STAGE_TOP, -10.0)
## The wig on the trapdoor nearest the workshop, the hair by it.
const WIG_TRAPDOOR := 3
const WIG := Color(0.55, 0.3, 0.6)
const SCRAP_AT := Theater.MASK_CASE_AT + Vector3(0.42, 0.85, 0.2)

var theater: Theater
var case: CrimeSceneCase
var case_glass: EmptyFrame
var footprint: TalcPrint
var hair: CrimeClueItem
var wig: MeshInstance3D
## The bitten bonbon: made with the case (so every PC has it), hidden in the box until someone searches it.
var bonbon: CrimeClueItem
var bonbon_out := false
var scrap: SheetScrap
var _elapsed := 0.0


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	case_glass = EmptyFrame.new(Vector2(0.7, 0.7))
	case_glass.name = "MaskCasePrints"
	case_glass.look = "MASKCASE"
	case_glass.case = case
	case_glass.has_prints = plan.clues.has("prints")
	case_glass.position = Theater.MASK_CASE_AT + Vector3(0, 1.36, 0.36)
	theater.add_child(case_glass)
	if plan.clues.has("footprint"):
		footprint = TalcPrint.new()
		footprint.name = "TalcPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		footprint.position = FOOTPRINT_AT - Vector3(0, 0.04, 0)
		theater.add_child(footprint)
		case.flour_print = footprint
	var trap := Theater.TRAPDOORS[WIG_TRAPDOOR]
	var curls := SphereMesh.new()
	curls.radius = 0.18
	curls.height = 0.2
	wig = MeshInstance3D.new()
	wig.name = "Wig"
	wig.mesh = curls
	var material := StandardMaterial3D.new()
	material.albedo_color = WIG
	wig.material_override = material
	wig.position = trap + Vector3(-0.3, 0.08, 0.2)
	theater.add_child(wig)
	if plan.clues.has("hair"):
		hair = _item("hair", trap + Vector3(0.2, 0, -0.1))
		case.items["hair"] = hair
	if plan.clues.has("bite"):
		var spot := theater.loot_spots["box"] as Node3D
		bonbon = _item("bite", Vector3(spot.position.x, Theater.BOX_TOP, spot.position.z) + spot.get_meta("out"))
		bonbon.visible = false
		bonbon.freeze = true
		bonbon.collision_layer = 0
	if plan.clues.has("sheet"):
		scrap = SheetScrap.new(GhostTraits.EMBROIDERY_COLORS[who.embroidery])
		scrap.name = "SheetScrap"
		scrap.clues = self
		scrap.position = SCRAP_AT
		theater.add_child(scrap)
	theater.performance.changed.connect(_on_changed)


func _item(kind: String, at: Vector3) -> CrimeClueItem:
	var item := CrimeClueItem.new()
	item.name = "Clue_" + kind
	item.kind = kind
	item.look = "hotel"
	item.case = case
	item.hair_color = GhostTraits.HAIRS[case.culprit().hair]
	item.position = at
	theater.add_child(item)
	return item


## A search of a spot is over (Theater.searched): in the box, the bitten bonbon turns up.
func searched(spot: String) -> void:
	if spot != "box" or not bonbon or bonbon_out or case.ruined.has("bite"):
		return
	bonbon_out = true
	bonbon.visible = true
	bonbon.collision_layer = 4
	bonbon.freeze = false
	case.items["bite"] = bonbon


## E on the scrap: which embroidery is on it.
func look_at_scrap(cop: Cop) -> void:
	case.found("sheet")
	if cop:
		cop.show_hint(tr("HINT_SHEET_SCRAP") % tr("EMBROIDERY_" + str(case.culprit().embroidery)))


## A scene change: the first one brings the footprint into view; a later one sweeps it away. The trapdoors open, and
## the wig drops to the basement with the hair, unless it's bagged.
func _on_changed(first: bool) -> void:
	if footprint:
		if first:
			footprint.uncover()
		elif not case.clues_found.has("footprint"):
			footprint.cover()
	var trap := Theater.TRAPDOORS[WIG_TRAPDOOR]
	if wig.visible:
		wig.visible = false
	if hair and not hair.bagged and not case.clues_found.has("hair") and hair.holders.is_empty():
		var off := theater.to_local(hair.global_position) - trap
		if absf(off.x) < Theater.TRAPDOOR_SIZE / 2 and absf(off.z) < Theater.TRAPDOOR_SIZE / 2:
			hair.spoiled = true
			hair.visible = false
			hair.freeze = true
			hair.collision_layer = 0
			case.ruin("hair")


func _physics_process(delta: float) -> void:
	if case.follower or not case.at_tent or _elapsed >= POLISH_SECONDS:
		return
	var was := _elapsed
	_elapsed += delta
	if was < BOX_LADY_SECONDS and _elapsed >= BOX_LADY_SECONDS:
		box_lady_wakes()
	if _elapsed >= POLISH_SECONDS:
		polish()


## The lady in the box wakes up and eats the bonbon, in the box or out of it, unless it's bagged.
func box_lady_wakes() -> void:
	if not bonbon or case.clues_found.has("bite") or bonbon.bagged:
		return
	bonbon.spoiled = true
	bonbon.visible = false
	bonbon.collision_layer = 0
	case.ruin("bite")


## The usher wipes the case's glass: whatever prints were on it are gone.
func polish() -> void:
	if case_glass.has_prints and not case.clues_found.has("prints"):
		case_glass.has_prints = false
		case.ruin("prints")
