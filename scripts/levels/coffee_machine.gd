class_name CoffeeMachine
extends StaticBody3D

## The company coffee machine in Formularios Infinitos' kitchen (escena-oficina.md, "¿Un cafecito?"): an employee asked
## for a coffee walks here and queues behind whoever is at it. At the machine he makes it (BREW_SECONDS), then its
## screen says what he chose and he drinks it standing, the cup in his left hand or his right. If a cop is in the
## kitchen right then, his coffee goes to his file; if not, it has to be asked again. Then he walks back to his desk
## and the next one steps up. Every number here is (propuesta).

const MODEL := preload("res://assets/models/coffee_machine.glb")
const SIZE := Vector3(0.7, 1.6, 0.6)
const BREW_SECONDS := 8.0
const DRINK_SECONDS := 4.0
## Where the one making his coffee stands, in front of it and a bit aside (the screen shows past him), and how far
## apart the queue stands behind him.
const FRONT := Vector3(0.6, 0, 0.8)
const QUEUE_STEP := Vector3(1.2, 0, 0.2)

var office: FormsOffice
## The employees in line, the first one at the machine.
var line: Array[OfficeEmployee] = []
var brewing := false
## Seconds left to the coffee, while brewing, or to the last sip after.
var left := 0.0
var screen: Label3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	screen = Label3D.new()
	screen.name = "Screen"
	screen.position = Vector3(0, SIZE.y + 0.2, 0)
	screen.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	screen.pixel_size = 0.003
	screen.font_size = 36
	screen.modulate = Color(0.55, 1.0, 0.6)
	screen.outline_size = 8
	add_child(screen)


## Where the n-th in line stands, in the office's space.
func spot(n: int) -> Vector3:
	return position + FRONT + QUEUE_STEP * n


## "¿Un cafecito?": he walks here and gets in line.
func ask(employee: OfficeEmployee) -> void:
	if line.has(employee):
		return
	employee.on_break = true
	line.append(employee)
	employee.say("OFFICE_EMPLOYEE_COFFEE_YES")
	employee.walk(office.to_kitchen(employee.position, spot(line.size() - 1)))


func _physics_process(delta: float) -> void:
	# Online the host's machine serves; a guest's shows its screen (FormsOffice.net_state).
	if office and office.case and office.case.follower:
		return
	if line.is_empty() or line[0].walking():
		return
	var first := line[0]
	if not brewing and left <= 0.0:
		brewing = true
		left = BREW_SECONDS
		screen.text = "COFFEE_SCREEN_BREWING"
		first.rotation.y = atan2(-FRONT.x, -FRONT.z)
		return
	left -= delta
	if left > 0.0:
		return
	if brewing:
		_served(first)
	else:
		_leave(first)


## The coffee is ready: the screen says what he chose and he drinks it, the cup in his hand. A cop in the kitchen sees it.
func _served(employee: OfficeEmployee) -> void:
	brewing = false
	left = DRINK_SECONDS
	screen.text = "COFFEE_" + str(employee.traits.get("coffee", "black"))
	employee.hold_cup(true)
	employee.say("OFFICE_EMPLOYEE_SIPS")
	if employee.case and office.cop_in_kitchen():
		employee.case.employee_part(employee.index, "coffee")


## He's done: back to his desk, and the line steps up.
func _leave(employee: OfficeEmployee) -> void:
	line.pop_front()
	left = 0.0
	screen.text = ""
	employee.hold_cup(false)
	employee.heading_back = true
	employee.walk(office.from_kitchen(employee.position, office.stand_at(office.desk_of[employee.index])))
	for i in line.size():
		if line[i].walking():
			line[i].path[-1] = spot(i)
		else:
			line[i].walk([spot(i)])
