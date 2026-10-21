class_name OwnerEscort
extends Node

## Taking the place's owner away (interrogatorio.md, "El dueño del allanamiento", decision 93): E on the cuffed owner
## takes him by the arm and he shuffles after that cop, complaining all the way; walked up to the patrol car, he gets
## in the back and stays there, and the next shift is his interrogation (RaidCase.custody). It hangs off the owner
## (the grandpa, Marta or Ramiro) as "Escort" and moves him itself while he's taken. Every number here is (propuesta).

signal boarded

## Taking him by the arm raises the complaint this much at once, and he complains every COMPLAIN_EVERY seconds.
const TAKEN := 20.0
const COMPLAIN_EVERY := 6.0
const LINES := ["OWNER_ESCORT_1", "OWNER_ESCORT_2", "OWNER_ESCORT_3"]
## He walks this fast (m/s) and keeps this far behind the cop.
const SPEED := 1.2
const KEEP_AWAY := 1.4
## Walked this close to the patrol car's body (HALF_SIZE, its floor), he gets in.
const BOARD_REACH := 1.5
const HALF_SIZE := Vector2(1.1, 2.4)

## The owner, the car he gets into and the cop walking him, if any.
var npc: CharacterBody3D
var car: PatrolCar
var escorted_by: Cop
var in_car := false
## Online, a guest's copy: the host walks him and says when he's in the car (NpcSync); here he only rides along.
var follower := false
## What every cop is told once he's in the car (the chase suspect goes to a cell, not to an interrogation).
var in_car_hint := "HINT_OWNER_IN_CAR"
var _since_line := 0.0
var _line := 0


## The escort of `body`, if it has one.
static func of(body: Node) -> OwnerEscort:
	return body.get_node_or_null("Escort") as OwnerEscort


## Adds the escort to `owner_npc`, who can be taken to `patrol_car`.
static func attach(owner_npc: CharacterBody3D, patrol_car: PatrolCar) -> OwnerEscort:
	var escort := OwnerEscort.new()
	escort.name = "Escort"
	escort.npc = owner_npc
	escort.car = patrol_car
	owner_npc.add_child(escort)
	return escort


## E on the owner goes to the escort while he's cuffed or being walked (in the car, nothing).
func handles_use() -> bool:
	return in_car or escorted_by != null or npc.is_cuffed()


func prompt_key(cop: Cop) -> String:
	if in_car:
		return ""
	return "PROMPT_LET_GO_OWNER" if escorted_by == cop else "PROMPT_ESCORT_OWNER"


## E: takes him by the arm, or lets go of him (the cuffs stay on for a while).
func use(cop: Cop) -> void:
	if in_car or follower:
		return
	if escorted_by == cop:
		escorted_by = null
		npc.set("_cuffed_left", Handcuffs.SECONDS)
		npc.set_physics_process(true)
		return
	escorted_by = cop
	_since_line = 0.0
	# Every owner keeps the meter and the bubble the same way.
	npc.call("_raise", TAKEN)
	npc.call("_say", LINES[0], 3.0)
	npc.set_physics_process(false)


func _physics_process(delta: float) -> void:
	if in_car:
		npc.global_transform = car.prisoner_seat()
		return
	if not escorted_by or follower:
		return
	# Walked by a cop, the cuffs don't run out.
	npc.set("_cuffed_left", Handcuffs.SECONDS)
	if near_car():
		board()
		return
	var to := escorted_by.global_position - npc.global_position
	to.y = 0.0
	var wish := to.normalized() * SPEED if to.length() > KEEP_AWAY else Vector3.ZERO
	if wish.length() > 0.05:
		npc.look_at(npc.global_position + wish, Vector3.UP, true)
	npc.velocity.x = wish.x
	npc.velocity.z = wish.z
	npc.velocity.y = 0.0 if npc.is_on_floor() else npc.velocity.y - GameScale.GRAVITY * delta
	npc.move_and_slide()
	_since_line += delta
	if _since_line >= COMPLAIN_EVERY:
		_since_line = 0.0
		_line += 1
		npc.call("_say", LINES[_line % LINES.size()], 3.0)


## Whether he's within BOARD_REACH of the car's body, seen from above.
func near_car() -> bool:
	var local := car.to_local(npc.global_position)
	var outside := Vector2(maxf(absf(local.x) - HALF_SIZE.x, 0.0), maxf(absf(local.z) - HALF_SIZE.y, 0.0))
	return outside.length() < BOARD_REACH


## He gets in the back of the patrol car and stays there: no bumping into it as it drives.
func board() -> void:
	in_car = true
	escorted_by = null
	npc.collision_layer = 0
	npc.collision_mask = 0
	npc.global_transform = car.prisoner_seat()
	car.prisoner = npc
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(in_car_hint)
	boarded.emit()
