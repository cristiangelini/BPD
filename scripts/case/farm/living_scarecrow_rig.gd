class_name LivingScarecrowRig
extends FarmRaidRig

## The living scarecrow (allanamiento-granja.md, "El espantapájaros vivo"): Don Florencio hides his cousin, the
## fugitive Primo Bigote, inside the garden's scarecrow, and the loot of his robbery in a spare costume. The scarecrow
## changes place when nobody's looking: every MOVE_EVERY seconds, if no cop has it in sight, it's somewhere else in the
## garden. And a cop who stares at it up close for STARE seconds makes it sneeze: the cousin is inside (the story's own
## clue). Every number here is (propuesta).

signal moved(place: int)
signal sneezed(cop: Cop)

const MOVE_EVERY := 20.0
## Where it stands, in the farm's space: its own spot first, then around the garden.
const PLACES: Array[Vector3] = [FarmRaid.SCARECROW_AT, Vector3(9.0, 0, 12.6), Vector3(14.5, 0, 12.4),
	Vector3(10.0, 0, 16.6)]
## A cop sees it within SEE_RANGE m if it's within the cone of their view (the cosine of the half angle).
const SEE_RANGE := 30.0
const SEE_COS := 0.6
const STARE_RANGE := 4.0
const STARE_COS := 0.9
const STARE := 3.0
## Its head, over its foot.
const HEAD := 1.6

var place := 0
var _move_left := MOVE_EVERY
## Cop -> seconds staring at it.
var _stare := {}
var _clue_given := false


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	_move_left -= delta
	if _move_left <= 0.0:
		_move_left = MOVE_EVERY
		if not seen():
			move()
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if _looks_at(cop, STARE_RANGE, STARE_COS):
			_stare[cop] = float(_stare.get(cop, 0.0)) + delta
			if _stare[cop] >= STARE:
				_stare[cop] = 0.0
				sneeze(cop)
		else:
			_stare.erase(cop)


## Whether a cop has it in sight.
func seen() -> bool:
	for node in get_tree().get_nodes_in_group("cops"):
		if _looks_at(node as Cop, SEE_RANGE, SEE_COS):
			return true
	return false


func _looks_at(cop: Cop, reach: float, cosine: float) -> bool:
	var eye := cop.camera.global_position
	var to := farm.scarecrow.global_position + Vector3.UP * HEAD - eye
	if to.length() > reach:
		return false
	return -cop.camera.global_basis.z.dot(to.normalized()) >= cosine


## To the next place in the garden, while nobody's looking.
func move() -> void:
	_set_place((place + 1) % PLACES.size())


func _set_place(next: int) -> void:
	place = next
	farm.scarecrow.position = PLACES[place] + Vector3.UP * FarmRaid.GROUND
	moved.emit(place)


## ¡Achís! The cousin inside gives himself away (the clue, the first time).
func sneeze(cop: Cop) -> void:
	farm.raid.float_label(tr("FARM_SCARECROW_SNEEZE"), farm.scarecrow.global_position + Vector3.UP * (HEAD + 0.5),
		Color.WHITE)
	if not _clue_given:
		_clue_given = true
		farm.raid.add_clue(tr("CLUE_SCARECROW_SNEEZE"))
	sneezed.emit(cop)


func net_state() -> Variant:
	return place


func apply_net_state(state: Variant) -> void:
	if int(state) != place:
		_set_place(int(state))
