class_name RinkIce
extends Node

## How the rink's ice treats the cops (docs/diseno/allanamiento-pista.md, "El hielo", step 2). Without skates a cop on
## the ice slides: the walk changes only SLIP_ACCEL m/s² at a time, and turning hard while going fast is a fall. With
## the rental's skates the ice is easy and fast, and off it the cop waddles like a duck. Every number here is
## (propuesta).

## A cop fell on the ice (Doña Pirueta sees it, step 3).
signal fell(cop: Cop)
## A cop put on or took off the skates.
signal skates_changed(cop: Cop, on: bool)

const SLIP_ACCEL := 2.0
const SKATE_ACCEL := 10.0
const SKATE_FAST := 1.4
const SKATE_DUCK := 0.5
## Sliding this fast and wanting to go more than FALL_TURN away from it: down on the ice for FALL_SECONDS.
const FALL_SPEED := 2.5
const FALL_TURN := deg_to_rad(100.0)
const FALL_SECONDS := 1.2
## How high over the ice a cop's feet still count as on it.
const ON_ICE_HEIGHT := 0.3

var rink: Rink
## The cops with skates on (id -> true).
var skaters := {}
var falls := 0


func has_skates(cop: Cop) -> bool:
	return skaters.has(cop.get_instance_id())


## The rental: skates on, or back on the counter.
func toggle_skates(cop: Cop) -> void:
	var on := not has_skates(cop)
	if on:
		skaters[cop.get_instance_id()] = true
	else:
		skaters.erase(cop.get_instance_id())
	cop.show_hint("HINT_RINK_SKATES_ON" if on else "HINT_RINK_SKATES_OFF")
	skates_changed.emit(cop, on)


func is_on_ice(cop: Cop) -> bool:
	var at := rink.to_local(cop.global_position)
	return Rink.on_ice(at) and at.y < Rink.ICE_TOP + ON_ICE_HEIGHT


func _physics_process(_delta: float) -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop == null or not rink.is_ancestor_of(cop):
			continue
		var on_ice := is_on_ice(cop)
		var skates := has_skates(cop)
		cop.slide_accel = (SKATE_ACCEL if skates else SLIP_ACCEL) if on_ice else 0.0
		cop.skate_factor = (SKATE_FAST if on_ice else SKATE_DUCK) if skates else 1.0
		if on_ice and not skates and not cop.is_staggered() and _turns_too_hard(cop):
			fall(cop)


func _turns_too_hard(cop: Cop) -> bool:
	if cop.slide.length() < FALL_SPEED or cop.walk_wish.length() < 0.1:
		return false
	return cop.slide.angle_to(cop.walk_wish) > FALL_TURN


## Down on the ice: it keeps half its slide and can't move for a moment.
func fall(cop: Cop) -> void:
	falls += 1
	cop.knock_back(cop.slide * 0.5, FALL_SECONDS)
	cop.slide = Vector3.ZERO
	cop.show_hint("HINT_RINK_FELL")
	fell.emit(cop)
