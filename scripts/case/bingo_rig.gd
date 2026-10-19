class_name BingoRig
extends StoryRig

## The bingo's own pieces (investigacion.md): the safe's combination on the kitchen calendar and in the cookie tin,
## the crumbs from the kitchen counter to the safe, and the bingo cards in the drawers.

## Evidence order in bingo_story.tres: book, cage, safe.
const CAGE := 1
const SAFE := 2
const TIN_SCENE := preload("res://scenes/props/cookie_tin_clue.tscn")
const CALENDAR_SCENE := preload("res://scenes/props/wall_calendar.tscn")
const CRUMB_STEP := 0.35
const CRUMB := Color(0.86, 0.66, 0.36)

## The safe's combination, like "4-7-1", written on the calendar and inside the cookie tin.
var combination := ""
var calendar: WallCalendar
var cookie_tin: ClueNote
var _house: GrandpaHouse


func setup(house: GrandpaHouse) -> void:
	_house = house
	var rng := RandomNumberGenerator.new()
	rng.seed = house.case_seed * 7 + 3
	combination = "%d-%d-%d" % [rng.randi_range(1, 9), rng.randi_range(0, 9), rng.randi_range(0, 9)]
	calendar = CALENDAR_SCENE.instantiate()
	calendar.text = house.tr("CLUE_CALENDAR") % combination
	calendar.position = GrandpaHouse.CALENDAR_AT
	calendar.rotation.y = PI
	calendar.read.connect(_on_code_found)
	house.get_node("Built").add_child(calendar)
	cookie_tin = TIN_SCENE.instantiate()
	cookie_tin.text = house.tr("CLUE_TIN") % combination
	cookie_tin.read.connect(_on_code_found)


## The crumbs go from the kitchen counter to the safe, and the cookie tin waits at their end.
func place_trails(house: GrandpaHouse, map: RID) -> void:
	var marks := house.trail(map, GrandpaHouse.CRUMBS_FROM, safe().global_position, CRUMB_STEP, false, CRUMB)
	house.trails[house.tr("CLUE_CRUMBS")] = marks
	var tin_at: Vector3 = marks[marks.size() - 1].global_position if not marks.is_empty() else GrandpaHouse.CRUMBS_FROM
	cookie_tin.position = tin_at + Vector3.UP * 0.1
	house.get_node("Evidence").add_child(cookie_tin)


func trail_item() -> int:
	return SAFE


func extras(house: GrandpaHouse) -> Array[Dictionary]:
	var car := house.car
	var cards := house.drawer_evidence
	var delivered_cards := cards.filter(func(c: Evidence) -> bool: return car.is_delivered(c)).size()
	return [
		{"text": "OBJ_EXTRA_CAGE", "done": car.is_delivered(house.evidence[CAGE] as Evidence)},
		{"text": "OBJ_EXTRA_SAFE", "done": car.is_delivered(safe()) or (safe().bundle != null and car.is_delivered(safe().bundle))},
		{"text": house.tr("OBJ_EXTRA_CARDS") % [delivered_cards, cards.size()],
			"done": not cards.is_empty() and delivered_cards == cards.size()},
	]


func safe() -> SafeBox:
	return _house.evidence[SAFE]


func _on_code_found(text: String) -> void:
	_house.add_clue(text)
	safe().code_known = true
