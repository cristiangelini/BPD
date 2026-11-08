class_name FakeToysRig
extends ToyStoreRig

## The fake toys (allanamiento-jugueteria.md, "Los juguetes truchos"): don Cucho sells copies as originals. The box of
## "Barbi" dolls with the misspelled label is hidden with the "ORIGINAL" stamp and the doll factory's invoice; in the
## collectors' case a robot's tag says "Transformes" (reading it, E, is the story's own clue), and every TALK_EVERY
## seconds a doll on a shelf says "Soy el original" in a funny voice. Every number here is (propuesta).

const TALK_EVERY := 35.0
## The robot's tag, on the collectors' case's glass, facing the salon (-X).
const TAG_AT := Vector3(ToyStore.CASE_AT.x - 0.33, ToyStore.FLOOR_TOP + 1.2, ToyStore.CASE_AT.z + 0.6)

var robot_tag: ClueSpot
## Times a doll spoke, and the shelf it spoke from last.
var talks := 0
var last_shelf := -1
var _since := 0.0


func setup(place: ToyStore) -> void:
	super.setup(place)
	robot_tag = sign_spot(TAG_AT, -PI / 2, "TOY_TRANSFORMES", tr("CLUE_TRANSFORMES"), Vector3(0.6, 0.22, 0.04))
	robot_tag.name = "RobotTag"


## A doll on a shelf drawn with the seed says it's the original.
func talk() -> void:
	_since = 0.0
	talks += 1
	last_shelf = (store.case_seed + talks) % ToyStore.SHELVES.size()
	var shelf: Vector3 = ToyStore.SHELVES[last_shelf]
	store.say(shelf + Vector3(0, ToyStore.SHELF_SIZE.y + 0.3, 0), "TOY_SOY_ORIGINAL")


func _process(delta: float) -> void:
	_since += delta
	if _since >= TALK_EVERY:
		talk()
