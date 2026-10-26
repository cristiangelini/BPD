class_name AirportBoarding
extends Node

## The boarding clock (politico-aeropuerto.md, step 4, decision 231): it starts with the belt and the gate closes
## BOARDING seconds later. The board over the gate counts down; with LAST_CALL left every cop is told. When it closes,
## the deputy boards if he's at the gate (`closed(true)`); anywhere else he misses the plane (`closed(false)`, in step
## 5 that loses the case). Every number here is (propuesta).

signal closed(on_time: bool)

const BOARDING := 240.0
const LAST_CALL := 60.0

var airport: Airport
var deputy: AirportDeputy
var left := BOARDING
var running := false
var done := false
## Online, a guest's: the host's says when it closes.
var follower := false
var _board: Label3D
var _called := false


func setup(the_airport: Airport, the_deputy: AirportDeputy, board: Label3D) -> void:
	airport = the_airport
	deputy = the_deputy
	_board = board
	_show()
	airport.belt.started.connect(start)


func start() -> void:
	if running or done:
		return
	running = true
	left = BOARDING
	deputy.start()


func _physics_process(delta: float) -> void:
	if not running or done:
		return
	left = maxf(left - delta, 0.0)
	_show()
	if follower:
		return
	if not _called and left <= LAST_CALL:
		_called = true
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			cop.show_hint("HINT_AIRPORT_LAST_CALL")
	if left <= 0.0:
		close()


## The gate closes now: he boards if he's there.
func close() -> void:
	if done:
		return
	done = true
	running = false
	var on_time := deputy.at_the_gate()
	if on_time:
		deputy.politician.hide()
		deputy.politician.process_mode = Node.PROCESS_MODE_DISABLED
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_AIRPORT_BOARDED" if on_time else "HINT_AIRPORT_MISSED")
	_show()
	closed.emit(on_time)


func _show() -> void:
	if _board == null:
		return
	if done:
		_board.text = tr("AIRPORT_BOARDING_CLOSED")
		return
	var seconds := ceili(left)
	_board.text = tr("AIRPORT_BOARDING_CLOCK") % ("%d:%02d" % [seconds / 60, seconds % 60])
