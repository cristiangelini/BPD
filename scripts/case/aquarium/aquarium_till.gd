class_name AquariumTill
extends StaticBody3D

## The gift shop's till (escena-acuario.md, "Las pistas"): its drawer sticks. E opens it, and if the ticket is one of the
## case's clues, it's in there (who bought a plush starfish at 3 in the morning), for a cop to take and bag. E again
## slams the drawer shut and it jams for good: a ticket still inside is lost. Every number here is (propuesta).

const SIZE := Vector3(0.5, 0.3, 0.4)
const METAL := Color(0.6, 0.62, 0.66)
const DRAWER := Color(0.45, 0.47, 0.5)
## Where the ticket pops out to, on the counter by the drawer, and how close to there it still counts as in the drawer,
## in meters.
const TICKET_AT := Vector3(-0.5, 0.02, 0.15)
const INSIDE_REACH := 0.35

var case: CrimeSceneCase
var has_ticket := false
var opened := false
var jammed := false
var ticket: CrimeClueItem
var _drawer: Node3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, SIZE.y / 2 + 0.03, 0), SIZE - Vector3(0, 0.06, 0), METAL)
	builder.mesh_box(Vector3(0, SIZE.y + 0.05, -0.08), Vector3(0.3, 0.1, 0.05), METAL.darkened(0.3))
	_drawer = Node3D.new()
	add_child(_drawer)
	PlaceBuilder.new(_drawer).mesh_box(Vector3(0, 0.03, 0), Vector3(SIZE.x - 0.04, 0.06, SIZE.z - 0.04), DRAWER)


func prompt_key(_cop: Cop) -> String:
	if jammed:
		return "PROMPT_TILL_JAMMED"
	return "PROMPT_TILL_SHUT" if opened else "PROMPT_TILL_OPEN"


## E: opens the drawer (the ticket in it, if there is one), or slams it shut and jams it.
func use(cop: Cop) -> void:
	if jammed:
		if cop:
			cop.show_hint("HINT_TILL_JAMMED")
		return
	if not opened:
		open(cop)
	else:
		jam(cop)


func open(cop: Cop) -> void:
	opened = true
	_drawer.position.z = SIZE.z * 0.8
	if has_ticket and case:
		ticket = CrimeClueItem.new()
		ticket.name = "Clue_ticket"
		ticket.kind = "ticket"
		ticket.look = "aquarium"
		ticket.case = case
		ticket.position = position + TICKET_AT
		get_parent().add_child(ticket)
		case.items["ticket"] = ticket
	if cop:
		cop.show_hint("HINT_TILL_TICKET" if has_ticket else "HINT_TILL_EMPTY")


## The drawer slammed shut for good; a ticket nobody took out goes with it.
func jam(cop: Cop) -> void:
	jammed = true
	_drawer.position.z = 0.0
	if cop:
		cop.show_hint("HINT_TILL_SLAMMED")
	if ticket and not ticket.bagged and ticket.global_position.distance_to(to_global(TICKET_AT)) < INSIDE_REACH:
		ticket.queue_free()
		ticket = null
		if case:
			case.ruin("ticket")
