class_name TrainWatchesRig
extends PawnRig

## The train's watches (allanamiento-empenos.md, "Los relojes del tren"): Don Regateo bought the watches stolen from
## the train for nothing and hid the suitcase (10 kg, the main evidence), the passenger list and a train ticket. The
## middle glass case is full of "watches of quality, just in", and all of them show the same time, the time of the
## robbery: every RING_EVERY seconds they ring together. Looking at them (a ClueSpot on the case's front) is the story's
## clue. Every number here is (propuesta).

const CASE := 1
const RING_EVERY := 30.0
const STOPPED_AT := "3:15"
## The front of the middle case (to the door, +Z), where a cop looks at the watches.
const FRONT := Vector3(0, 0.55, PawnShop.CASE_SIZE.z / 2 + 0.03)
const FRONT_SIZE := Vector3(1.9, 0.9, 0.06)

var watches: ClueSpot
var rings := 0
var _ring_left := RING_EVERY


func setup(place: PawnShop) -> void:
	super.setup(place)
	var at := PawnShop.CASES[CASE]
	watches = ClueSpot.new()
	watches.size = FRONT_SIZE
	watches.prompt = "PROMPT_PAWN_WATCHES"
	watches.text = tr("CLUE_TRAIN_WATCHES") % STOPPED_AT
	watches.position = at + FRONT
	watches.read.connect(place.raid.add_clue)
	place.add_child(watches)
	for i in 5:
		var face := Label3D.new()
		face.text = STOPPED_AT
		face.font_size = 28
		face.pixel_size = 0.003
		face.outline_size = 4
		face.modulate = Color(0.15, 0.12, 0.1)
		face.position = at + Vector3(-0.8 + i * 0.4, PawnShop.CASE_SIZE.y - 0.28, 0.2)
		face.rotation.x = -PI / 2
		place.add_child(face)
	var sign := Label3D.new()
	sign.text = "PAWN_WATCHES_SIGN"
	sign.font_size = 28
	sign.pixel_size = 0.004
	sign.outline_size = 8
	sign.double_sided = false
	sign.position = at + Vector3(0, 0.55, PawnShop.CASE_SIZE.z / 2 + 0.07)
	place.add_child(sign)


## All together, every RING_EVERY seconds.
func ring() -> void:
	rings += 1
	shop.say_at(shop.to_global(PawnShop.CASES[CASE] + Vector3(0, 1.8, 0)), "PAWN_WATCHES_RING")


func _physics_process(delta: float) -> void:
	_ring_left -= delta
	if _ring_left <= 0.0:
		_ring_left = RING_EVERY
		ring()
