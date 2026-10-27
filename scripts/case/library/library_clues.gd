class_name LibraryClues
extends Node

## The library case's clues where they go (escena-biblioteca.md, "Las pistas"), put by Library when the case comes:
## the prints on the display case's glass (Doña Sigilo dusts it after a while, and they're gone), the slipper's
## footprint on the waxed parquet, the hair on the reading armchair and the bitten cookie inside the hollow book. The
## gold dust, the bookmark and Tomasito come in the next step. Every number here is (propuesta).

## Doña Sigilo runs her feather duster over the display case this long after the cops get there, in seconds.
const DUSTER_SECONDS := 240.0
## Where the footprint can be: on the reading room's parquet, off the straight way from the door to the case.
const FOOTPRINT_SPOTS: Array[Vector3] = [Vector3(2.6, 0, 0.4), Vector3(-2.6, 0, -2.4), Vector3(3.0, 0, -2.8)]
const WAX := Color(0.62, 0.44, 0.27)
## The hollow book, on the middle table.
const HOLLOW_BOOK_AT := Vector3(-1.0, 0, -5.5)

var library: Library
var case: CrimeSceneCase
var glass: EmptyFrame
var hollow_book: HollowBook
var _elapsed := 0.0


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	glass = EmptyFrame.new(Vector2(Library.CASE_SIZE.x - 0.16, 0.42))
	glass.name = "CaseGlass"
	glass.look = "GLASS"
	glass.case = case
	glass.has_prints = plan.clues.has("prints")
	glass.position = Library.CASE_AT + Vector3(0, 1.15, Library.CASE_SIZE.z / 2 + 0.04)
	library.add_child(glass)
	if plan.clues.has("footprint"):
		var footprint := FlourPrint.new()
		footprint.name = "WaxPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		footprint.dust = WAX.darkened(0.15)
		footprint.position = FOOTPRINT_SPOTS[absi(hash(["library footprint", case.case_seed])) % FOOTPRINT_SPOTS.size()] \
			+ Vector3(0, Library.FLOOR_TOP - 0.04, 0)
		library.add_child(footprint)
		case.flour_print = footprint
	if plan.clues.has("hair"):
		var hair := CrimeClueItem.new()
		hair.name = "Clue_hair"
		hair.kind = "hair"
		hair.look = "library"
		hair.case = case
		hair.hair_color = CookTraits.HAIRS[who.hair]
		hair.position = Library.ARMCHAIR_AT + Vector3(0.05, Library.FLOOR_TOP + 0.5, 0)
		library.add_child(hair)
		case.items["hair"] = hair
	hollow_book = HollowBook.new()
	hollow_book.name = "HollowBook"
	hollow_book.library = library
	hollow_book.case = case
	hollow_book.has_bite = plan.clues.has("bite")
	hollow_book.position = HOLLOW_BOOK_AT + Vector3(0, Library.TABLE_SIZE.y, 0)
	library.add_child(hollow_book)


func _physics_process(delta: float) -> void:
	if case.follower or not case.at_tent or _elapsed >= DUSTER_SECONDS:
		return
	_elapsed += delta
	if _elapsed >= DUSTER_SECONDS:
		dust_the_case()


## Doña Sigilo's feather duster on the display case: whatever prints were on the glass are gone.
func dust_the_case() -> void:
	if glass.has_prints and not case.clues_found.has("prints"):
		glass.has_prints = false
		case.ruin("prints")
