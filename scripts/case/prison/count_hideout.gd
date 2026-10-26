class_name CountHideout
extends StaticBody3D

## One of the places in the prison where an inmate of the count can hide (carcel-recuento.md, step 5): the canteen's
## bin, the dirty laundry cart, the drinks machine, the stack of mash boxes, the yard's skip, the ball box by the hoop,
## the guard dog's kennel or the mattress against the south wall. One with someone in it (`occupant`, his number)
## snores and shakes now and then while a cop is within HEAR metres. E searches it (ActionSync runs it on every PC;
## CountPlan, on the host, decides). Its origin is on the floor. Every number here is (propuesta).

signal searched(hideout: CountHideout, cop: Cop)

enum Kind { BIN, CART, MACHINE, BOXES, SKIP, BALLS, KENNEL, MATTRESS }

## Each kind's size and colour.
const SIZES := {
	Kind.BIN: Vector3(0.6, 0.9, 0.6), Kind.CART: Vector3(1.2, 1.0, 0.7), Kind.MACHINE: Vector3(0.9, 1.9, 0.7),
	Kind.BOXES: Vector3(1.2, 1.3, 0.8), Kind.SKIP: Vector3(1.8, 1.2, 1.0), Kind.BALLS: Vector3(1.0, 0.8, 0.7),
	Kind.KENNEL: Vector3(1.1, 1.0, 1.1), Kind.MATTRESS: Vector3(1.9, 1.6, 0.25),
}
const COLORS := {
	Kind.BIN: Color(0.3, 0.45, 0.35), Kind.CART: Color(0.62, 0.66, 0.7), Kind.MACHINE: Color(0.8, 0.15, 0.15),
	Kind.BOXES: Color(0.7, 0.55, 0.35), Kind.SKIP: Color(0.25, 0.4, 0.6), Kind.BALLS: Color(0.5, 0.35, 0.2),
	Kind.KENNEL: Color(0.6, 0.4, 0.25), Kind.MATTRESS: Color(0.85, 0.85, 0.75),
}
const HEAR := 4.0
const SNORE_EVERY := 4.0
const SNORE_TIME := 1.6
const SHAKE := 0.05

var kind := Kind.BIN
## The number of the inmate in it, 0 when empty.
var occupant := 0
## A guest's copy (step 7): the host decides.
var follower := false
var _thing: Node3D
var _snore: Label3D
var _snore_left := 0.0
var _shown_left := 0.0


func _ready() -> void:
	add_to_group("count_hideouts")
	var size: Vector3 = SIZES[kind]
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position.y = size.y / 2
	add_child(shape)
	_thing = Node3D.new()
	_thing.name = "Thing"
	add_child(_thing)
	_build(size, COLORS[kind])
	_snore = Label3D.new()
	_snore.name = "Snore"
	_snore.text = "COUNT_SNORE"
	_snore.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_snore.pixel_size = 0.003
	_snore.outline_size = 8
	_snore.font_size = 48
	_snore.position.y = size.y + 0.4
	_snore.hide()
	add_child(_snore)


## The look of each kind: its body and a detail or two.
func _build(size: Vector3, color: Color) -> void:
	_thing.add_child(CopTool.piece(CopTool.box(size), color, Vector3(0, size.y / 2, 0)))
	var top := Vector3(0, size.y, 0)
	match kind:
		Kind.BIN, Kind.SKIP:
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(size.x + 0.06, 0.06, size.z + 0.06)), color.darkened(0.3),
				top))
		Kind.CART:
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(size.x - 0.1, 0.12, size.z - 0.1)), Color(0.9, 0.9, 0.95),
				top))
		Kind.MACHINE:
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(size.x * 0.6, size.y * 0.45, 0.02)),
				Color(0.95, 0.9, 0.85), Vector3(-0.1, size.y * 0.62, size.z / 2 + 0.01)))
		Kind.BOXES:
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(0.6, 0.45, 0.5)), color.lightened(0.15), top
				+ Vector3(0.2, 0.22, 0)))
		Kind.BALLS:
			for i in 3:
				_thing.add_child(CopTool.piece(CopTool.cylinder(0.12, 0.24), Color(0.95, 0.5, 0.1),
					top + Vector3(-0.3 + i * 0.3, 0.06, 0)))
		Kind.KENNEL:
			var roof := CopTool.piece(CopTool.box(Vector3(size.x + 0.1, 0.06, size.z * 0.75)), Color(0.7, 0.2, 0.15),
				top + Vector3(0, 0.15, 0))
			_thing.add_child(roof)
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(0.45, 0.6, 0.02)), Color(0.08, 0.06, 0.05),
				Vector3(0, 0.3, size.z / 2 + 0.01)))
		Kind.MATTRESS:
			for y in [0.4, 0.8, 1.2]:
				_thing.add_child(CopTool.piece(CopTool.box(Vector3(size.x - 0.1, 0.03, 0.02)), Color(0.55, 0.65, 0.8),
					Vector3(0, y, size.z / 2 + 0.01)))


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_COUNT_SEARCH"


func use(cop: Cop) -> void:
	searched.emit(self, cop)


## Someone in it snores now and then to a cop close by.
func _process(delta: float) -> void:
	if _shown_left > 0.0:
		_shown_left -= delta
		_thing.rotation.z = sin(_shown_left * 30.0) * SHAKE
		if _shown_left <= 0.0:
			_snore.hide()
			_thing.rotation.z = 0.0
	if occupant == 0:
		return
	_snore_left -= delta
	if _snore_left > 0.0:
		return
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(global_position) <= HEAR:
			snore()
			return


func snore() -> void:
	_snore_left = SNORE_EVERY
	_shown_left = SNORE_TIME
	_snore.show()


func snoring() -> bool:
	return _snore.visible


## For a guest's copy (NpcSync, step 7): who's in it.
func net_state() -> Array:
	return [occupant]


func apply_net_state(state: Variant) -> void:
	occupant = state[0]
