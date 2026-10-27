class_name HotelBell
extends StaticBody3D

## The bell on the hotel's reception desk (hotel-allanamiento.md): E rings it, and it wakes don Bostezo, angry.

signal rung(at: Vector3)

const RADIUS := 0.09

var concierge: HotelConcierge


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = RADIUS
	shape.shape = sphere
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOTEL_BELL"


func use(_cop: Cop) -> void:
	if concierge:
		concierge.ring_bell()
	rung.emit(global_position)
