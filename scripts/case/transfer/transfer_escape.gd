class_name TransferEscape
extends Node

## An inmate out of the transfer bus runs off along the sidewalk (traslado-presos.md, step 4, decision 105): the
## chase on foot starts where they landed (ChaseCase.begin, the inmate dragging their ball and chain). The bus stays
## where it is, with the others inside making the most of it. Caught and cuffed, the cops walk them back to the bus
## (OwnerEscort, to its whole body) and they sit in their own seat again, chained, with the plan from 0. Got away, they
## count as escaped (`escaped`; the end, step 5, takes the count). One chase at a time: whoever else gets out
## meanwhile waits in `waiting`, standing still, and runs as soon as that one is over. The host decides; online a
## guest's follows it (follow(), from TransferCase's snapshot) with a chase of its own that takes the host's.

## A chase is over: `caught`, or one more escaped.
signal chase_over(inmate: BusInmate, caught: bool)

var tricks: TransferTricks
var bus: PrisonBus
var level: Node3D
var city: Node3D
var case_seed := 0
## The chase running now, and who it's after.
var chase: ChaseCase
var running: BusInmate
var waiting: Array[BusInmate] = []
var escaped: Array[BusInmate] = []
var caught := 0
var follower := false
var online: CaseSync
var _chases := 0


func setup(on_tricks: TransferTricks, on_level: Node3D, on_city: Node3D, seed_value: int) -> void:
	tricks = on_tricks
	bus = tricks.plan.bus
	level = on_level
	city = on_city
	case_seed = seed_value
	tricks.went_out.connect(_on_went_out)


func _on_went_out(inmate: BusInmate) -> void:
	if follower or inmate == running or waiting.has(inmate):
		return
	waiting.append(inmate)
	if not chase:
		_next()


## The next one out runs: their body stays hidden, and the chase's runner (and then its suspect) stands in for them.
func _next() -> void:
	if waiting.is_empty():
		return
	_run(waiting.pop_front())


func _run(inmate: BusInmate) -> void:
	running = inmate
	var at := running.global_transform
	running.hide()
	running.process_mode = Node.PROCESS_MODE_DISABLED
	bus.return_seat = running.seat
	_chases += 1
	chase = ChaseCase.begin(level, SuspectCar.INMATE_ON_FOOT, at, bus, city, case_seed + _chases)
	chase.who = "transfer_inmate"
	chase.online = online
	chase.follower = follower
	chase.ended.connect(_on_chase_ended)
	# The host's hint reaches every player's cop already.
	if follower:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_TRANSFER_ESCAPED")


func _on_chase_ended(was_caught: bool) -> void:
	var inmate := running
	# The next chase makes its own runner instead of picking this one up by name (ChaseCase.begin). A guest's may be
	# gone already, with the host's.
	if is_instance_valid(chase.truck):
		chase.truck.name = "GoneRunner%d" % _chases
		if was_caught:
			chase.truck.queue_free()
	if was_caught:
		caught += 1
		# The chase's stand-in goes; the inmate himself is back in his seat.
		if is_instance_valid(chase.suspect):
			chase.suspect.queue_free()
		bus.prisoner = null
		inmate.back_on(bus)
		tricks.out.erase(inmate)
	elif not escaped.has(inmate):
		escaped.append(inmate)
	chase.queue_free()
	chase = null
	running = null
	chase_over.emit(inmate, was_caught)
	_next()


## Guest: the host's chase is after the inmate in seat `seat` (-1: nobody), and these seats got away. A chase that
## ended on the host while another started ends here too, the way the host's did.
func follow(seat: int, gone: Array, chase_state: Variant) -> void:
	var inmates := tricks.plan.inmates
	escaped.assign(gone.map(func(i: int) -> BusInmate: return inmates[i]))
	if running and running.seat != seat:
		chase._end(not escaped.has(running))
	if seat >= 0 and not running:
		_run(inmates[seat])
	if chase and chase_state is Dictionary:
		chase.apply_snapshot(chase_state)


## The seats that got away, for the guests.
func escaped_seats() -> Array:
	return escaped.map(func(inmate: BusInmate) -> int: return inmate.seat)
