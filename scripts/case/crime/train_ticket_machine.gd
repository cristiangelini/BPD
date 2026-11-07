class_name TrainTicketMachine
extends StaticBody3D

## The ticket machine at the front of first class (escena-tren.md, "Las pistas"): E prints the cop a ticket, PRICE off
## the salary, one each. Picadora only talks to a cop who shows her one (TrainStaff). Every number here is (propuesta).

const SIZE := Vector3(0.5, 1.4, 0.4)
const PRICE := 5

var train: Train


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)


func prompt_key(cop: Cop) -> String:
	return "PROMPT_TRAIN_TICKET_HAVE" if train.has_ticket(cop) else "PROMPT_TRAIN_TICKET"


func use(cop: Cop) -> void:
	if train.has_ticket(cop):
		cop.show_hint("HINT_TRAIN_TICKET_ALREADY")
		return
	train.tickets[str(cop.name)] = true
	if train.case:
		train.case.spend(PRICE)
	cop.show_hint(tr("HINT_TRAIN_TICKET") % PRICE)
