class_name OfficeEmployee
extends OfficePerson

## One of the six employees of Formularios Infinitos (escena-oficina.md, "Los empleados iguales" and "Las fichas"): the
## same grey suit, tie and briefcase as the other five; his own hair (tinted), his glasses if he wears them, his shoes
## (stretched to his size) and his teeth (shown when he bites). The cops make his file with what's in hand: the
## camera's flash (his photo: glasses and shoes), the print kit (his prints), a cookie from the kitchen's tin, a donut
## or a loaf (he bites it: his teeth). With empty hands, "¿Un cafecito?": he goes to make one at the coffee machine
## (CoffeeMachine), and a cop who watches him there gets his coffee and his hand. Every number here is (propuesta).

## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
## Seconds his teeth show after a bite.
const TEETH_SECONDS := 2.0

## OfficeTraits.draw: name, hair, glasses, shoe, teeth, left, coffee.
var traits := {}
var case: CrimeSceneCase
## The kitchen's coffee machine, whether he's off for a coffee (then the desk bell skips him) and whether he's on his
## way back from it to his desk.
var coffee: CoffeeMachine
var on_break := false
var heading_back := false
var _teeth_left := 0.0


func _ready() -> void:
	who = "employee"
	super()
	add_to_group("office_employees")
	if traits.has("hair"):
		var material := StandardMaterial3D.new()
		material.albedo_color = OfficeTraits.HAIRS[traits.hair]
		for mesh in part("hair").find_children("*", "MeshInstance3D", true, false):
			(mesh as MeshInstance3D).material_override = material
	part("glasses").visible = traits.get("glasses", false)
	if traits.has("shoe"):
		var size := inverse_lerp(OfficeTraits.SHOE_MIN, OfficeTraits.SHOE_MAX, traits.shoe)
		part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	for id in ["teeth", "cup_left", "cup_right"]:
		part(id).visible = false


func prompt_key(cop: Cop) -> String:
	if _food(cop):
		return "PROMPT_GUARD_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_GUARD_PRINTS"
	return "PROMPT_OFFICE_COFFEE" if coffee and not on_break else super(cop)


## E on him: food in hand, he bites it; with empty hands he goes for a coffee, or says a line while he's on it.
func use(cop: Cop) -> void:
	var food := _food(cop)
	if food:
		feed(food)
	elif coffee and not on_break:
		coffee.ask(self)
	else:
		super(cop)


## Bites a cookie from the tin, a donut from the box or the loaf: his teeth for the file.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("OFFICE_NO_COOKIES")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("OFFICE_EMPLOYEE_BITES")
	_file("teeth")


## The camera's flash in his face (PhotoCamera): his photo, with his glasses and his shoes.
func photographed(_cop: Cop) -> void:
	say("OFFICE_EMPLOYEE_FLASH")
	_file("photo")


## The print kit on him (PrintKit): his prints.
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## Holds his coffee in his hand, the left or the right (or puts it away).
func hold_cup(holding: bool) -> void:
	part("cup_left").visible = holding and traits.get("left", false)
	part("cup_right").visible = holding and not traits.get("left", false)


## Online (NpcSync): what a guest's copy shows besides where he is: off for a coffee, the cup in his hand, his teeth.
func net_state() -> Array:
	return [on_break, part("cup_left").visible or part("cup_right").visible, part("teeth").visible]


func apply_net_state(state: Array) -> void:
	on_break = state[0]
	hold_cup(state[1])
	part("teeth").visible = state[2]


func _physics_process(delta: float) -> void:
	super(delta)
	if heading_back and not walking():
		heading_back = false
		on_break = false
		rotation.y = -PI / 2
	if _teeth_left > 0.0:
		_teeth_left -= delta
		part("teeth").visible = _teeth_left > 0.0


func _food(cop: Cop) -> Node:
	if not cop:
		return null
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox or held is Bread else null


func _file(what: String) -> void:
	if case:
		case.employee_part(index, what)
