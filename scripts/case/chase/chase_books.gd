class_name ChaseBooks
extends RigidBody3D

## A pile of books that falls out of the back of the library's bookmobile (escena-biblioteca.md, "El tablero y el
## final"; ChaseDrops): it lies in the street, in the patrol car's way. E (anyone on foot) picks it up, no harm done;
## the patrol car going over it fast ruins it, and every ruined pile is the library's fine, off the salary
## (CrimeSceneCase.book_pile_ruined). Every number here is (propuesta).

const MODEL := preload("res://assets/models/chase_books.glb")
const SIZE := Vector3(0.5, 0.32, 0.43)
const MASS := 6.0
## The patrol car this close to its middle, at this speed or more (m/s), runs it over.
const REACH := 1.6
const RUIN_SPEED := 2.0

## The patrol car that can run over it.
var car: Node3D
var ruined := false
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_books")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PICK_UP_BOOKS"


## E: picked up, to go back to the library. No fine.
func use(cop: Cop) -> void:
	if cop:
		cop.show_hint("HINT_BOOKS_PICKED_UP")
	queue_free()


## Run over: "¡Libro dañado!", and the library's case hears of it.
func run_over() -> void:
	if ruined:
		return
	ruined = true
	get_tree().call_group("crime_scene", "book_pile_ruined")
	queue_free()


func _physics_process(delta: float) -> void:
	if ruined or not is_instance_valid(car):
		return
	var at := car.global_position
	var speed := 0.0 if _car_at == Vector3.INF else (at - _car_at).length() / delta
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and speed >= RUIN_SPEED:
		run_over()
