class_name ComisarioChairRig
extends FurnitureRig

## The comisario's armchair (allanamiento-muebleria.md, "El sillón del comisario"): Don Cajón sells what he steals from
## the station, starting with the comisario's own armchair, now in the shop window. The armchair itself is the main
## evidence (18 kg, one cop carries it); the photo of the comisario on it and the station's screwdriver are hidden. Its
## "Propiedad de la Comisaría" sticker is the story's own clue: a cop who comes close enough reads it (on the checklist
## the first time). And a cop who sits on it hears the comisario on the radio. Every number here is (propuesta).

const ARMCHAIR_SCENE := preload("res://scenes/props/comisario_armchair.tscn")
## In the shop window, left of the door, its back to the street so the sticker shows from inside.
const WINDOW_AT := Vector3(-5.0, FurnitureStore.FLOOR_TOP + 0.6, 10.6)
const READ_RANGE := 2.0
## The comisario doesn't call more often than this.
const CALL_EVERY := 8.0

var armchair: ComisarioArmchair
var sticker_read := false
var calls := 0
var _call_wait := 0.0


func setup(place: FurnitureStore) -> void:
	super.setup(place)
	armchair = ARMCHAIR_SCENE.instantiate()
	armchair.name = "ComisarioArmchair"
	armchair.position = WINDOW_AT
	place.add_child(armchair)
	place.main = armchair
	armchair.sat.connect(sit)


func _physics_process(delta: float) -> void:
	_call_wait = maxf(_call_wait - delta, 0.0)
	if sticker_read or not is_instance_valid(armchair):
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(armchair.global_position) <= READ_RANGE:
			read_sticker(cop)
			return


## `cop` reads the sticker on its back: the clue.
func read_sticker(cop: Cop) -> void:
	if sticker_read:
		return
	sticker_read = true
	cop.show_hint("HINT_STATION_STICKER")
	store.raid.add_clue(tr("CLUE_STATION_STICKER"))


## `cop` sat on the comisario's armchair: he knows, somehow, and says so on every cop's radio.
func sit(_cop: Cop) -> void:
	if _call_wait > 0.0:
		return
	_call_wait = CALL_EVERY
	calls += 1
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_COMISARIO_CHAIR_RADIO")
