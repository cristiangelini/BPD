class_name StrikeCall
extends OfficePrinter

## Don Chuza's weak spot at the bowling alley (allanamiento-bolera.md, "Su distracción, la chuza"): he never misses a
## strike. Ten pins down in one roll call him to that lane, where he celebrates the floor boss's fix time with his back
## to the alley. A cop's strike counts: after one the strikes rest REST seconds, and from the CATCH_ON-th one on he sees
## through it and gets angry instead (`caught_on`). A league player's strike calls him too, if it isn't resting, and
## doesn't count. Every number here is (propuesta).

## A strike on lane `lane`: he heads there (emitted before `jammed`).
signal called(lane: int)
## "Ustedes no son jugadores nuevos…": no celebration, only a complaint.
signal caught_on

const REST := 45.0
const CATCH_ON := 3

## The lane he celebrates at, and how many cop strikes he's seen.
var lane := -1
var calls := 0
var rest_left := 0.0


func _ready() -> void:
	pass


## Lane `on_lane`'s pins were counted: ten down is a strike, by a cop if `by_cop`.
func strike(on_lane: int, by_cop: bool) -> void:
	if is_jammed or rest_left > 0.0:
		return
	if by_cop:
		calls += 1
		rest_left = REST
		if calls >= CATCH_ON:
			caught_on.emit()
			return
	lane = on_lane
	is_jammed = true
	jobs += 1
	called.emit(on_lane)
	jammed.emit()


func print_copies(_cop: Cop = null) -> void:
	strike(0, false)


## The celebration is over.
func fix() -> void:
	is_jammed = false


func _process(delta: float) -> void:
	if not is_jammed:
		rest_left = maxf(rest_left - delta, 0.0)
