class_name FakeTicketsRig
extends FairRig

## The fake tickets (allanamiento-parque.md, "Los boletos falsos"): Don Tómbola prints his own tickets and sells them
## all over the city. The printing machine is hidden; tickets lie on the paths, and reading two of them shows they all
## have the same number, the story's own clue (on the checklist). In the ticket booth something whirs by itself every
## PRINT_EVERY seconds and spits out another one. The rolls of uncut tickets and the "Válido" stamp are hidden too.
## Every number here is (propuesta).

const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
const PINK := Color(0.96, 0.63, 0.75)
## The tickets lying on the paths.
const TICKETS: Array[Vector3] = [
	Vector3(0.8, Fair.FLOOR_TOP, 19.0), Vector3(-1.2, Fair.FLOOR_TOP, 13.0), Vector3(1.5, Fair.FLOOR_TOP, -0.5),
	Vector3(-7.0, Fair.FLOOR_TOP, -8.5),
]
const PRINT_EVERY := 20.0
## At most this many printed tickets lie around at once.
const PRINTED_MAX := 6
## Where the booth spits them out: its window, to the arch.
const SPIT_AT := Fair.TICKETS_AT + Vector3(-0.4, 1.3, 1.3)

var tickets: Array[ClueNote] = []
var printed := 0
var reads := 0
var _since_print := 0.0


func setup(place: Fair) -> void:
	super.setup(place)
	for at in TICKETS:
		var ticket := _ticket()
		ticket.position = at + Vector3.UP * 0.01
		ticket.rotation.y = at.x
		place.add_child(ticket)


func _physics_process(delta: float) -> void:
	_since_print += delta
	if _since_print >= PRINT_EVERY:
		print_ticket()


## The booth whirs and spits out a ticket.
func print_ticket() -> void:
	_since_print = 0.0
	fair.raid.float_label(tr("FAIR_PRINTER_WHIR"), fair.to_global(SPIT_AT + Vector3.UP * 0.6), Color(0.96, 0.63, 0.75))
	if printed >= PRINTED_MAX:
		return
	printed += 1
	var ticket := _ticket()
	fair.add_child(ticket)
	ticket.global_position = fair.to_global(SPIT_AT)
	ticket.linear_velocity = fair.global_basis * Vector3(0, 1.5, 3.0)


func _ticket() -> ClueNote:
	var ticket: ClueNote = NOTE_SCENE.instantiate()
	ticket.name = "Ticket"
	ticket.text = tr("FAIR_TICKET")
	var paper := StandardMaterial3D.new()
	paper.albedo_color = PINK
	(ticket.get_node("Mesh") as MeshInstance3D).material_override = paper
	ticket.read.connect(_on_read)
	tickets.append(ticket)
	return ticket


## The second ticket read has the same number as the first.
func _on_read(_text: String) -> void:
	reads += 1
	if reads == 2:
		fair.raid.add_clue(tr("CLUE_SAME_TICKETS"))
