class_name AirportBelt
extends Node

## The check-in belt (politico-aeropuerto.md, step 2, decision 231): the 13 suitcases wait in a pile between the
## counter and the belt. Once a cop walks into the terminal, every SEND_EVERY seconds the clerk puts the next one in
## line still in the pile on the belt, which carries whatever lies on it east at SPEED through the X-ray machine
## (`xrayed`, step 3) and, at its end, into the plane's hold (`loaded`). The cops can take suitcases off the pile or
## the belt at any time. The counter's scale shows the weight of what's on it. Every number here is (propuesta).

signal started
signal sent(suitcase: Suitcase)
signal xrayed(suitcase: Suitcase)
signal loaded(suitcase: Suitcase)

const SEND_EVERY := 15.0
const SPEED := 1.1
## Where the clerk puts them, this far along from the belt's west end; how far off the pile one can be and still be
## "in the pile".
const SEND_AT := 0.6
const PILE_REACH := 0.6
const PILE_ROW := 7
const PILE_STEP := 0.8
const PILE_X := -13.2
const PILE_Z: Array[float] = [13.45, 14.0]
## What counts as lying on the belt: this far off its middle line, and this high over its top.
const ON_BELT := 0.6
const ABOVE := 0.6
const CENTER_PULL := 2.0

var airport: Airport
## In the order the clerk sends them.
var line: Array[Suitcase] = []
var piled: Array[Vector3] = []
var running := false
var left := SEND_EVERY
var loaded_count := 0
## Online, a guest's: the host's runs the belt.
var follower := false
var _readout: Label3D
var _on_scale: Array[Suitcase] = []


func setup(the_airport: Airport, suitcases: Array[Suitcase], readout: Label3D) -> void:
	airport = the_airport
	line = suitcases
	_readout = readout
	for suitcase in line:
		piled.append(airport.to_local(suitcase.global_position))


static func pile_spot(i: int) -> Vector3:
	return Vector3(PILE_X + (i % PILE_ROW) * PILE_STEP, Airport.FLOOR_TOP + Suitcase.SIZE.y / 2 + 0.02,
		PILE_Z[i / PILE_ROW])


func start() -> void:
	if running:
		return
	running = true
	left = SEND_EVERY
	started.emit()


## The next one in line still in the pile goes on the belt now.
func send_next() -> void:
	left = SEND_EVERY
	for i in line.size():
		var suitcase := line[i]
		if not suitcase.visible or suitcase.is_held() or suitcase.has_meta("sent"):
			continue
		if airport.to_local(suitcase.global_position).distance_to(piled[i]) > PILE_REACH:
			continue
		put_on(suitcase)
		sent.emit(suitcase)
		return


## `suitcase` on the belt's start now (the clerk, or the porter's trick in step 5).
func put_on(suitcase: Suitcase) -> void:
	suitcase.set_meta("sent", true)
	suitcase.global_transform = airport.global_transform * Transform3D(Basis.IDENTITY,
		Vector3(Airport.BELT_X.x + SEND_AT, Airport.BELT_TOP + Suitcase.SIZE.y / 2 + 0.05, Airport.BELT_Z))
	suitcase.linear_velocity = Vector3.ZERO
	suitcase.angular_velocity = Vector3.ZERO


func on_belt(suitcase: Suitcase) -> bool:
	var at := airport.to_local(suitcase.global_position)
	return absf(at.z - Airport.BELT_Z) < ON_BELT and at.y > Airport.BELT_TOP and at.y < Airport.BELT_TOP + ABOVE \
		and at.x > Airport.BELT_X.x and at.x < Airport.BELT_X.y


func _physics_process(delta: float) -> void:
	_weigh()
	if follower:
		return
	if not running:
		for cop: Node3D in get_tree().get_nodes_in_group("cops"):
			if airport.in_terminal(cop.global_position):
				start()
				break
		return
	left -= delta
	if left <= 0.0:
		send_next()
	for suitcase in line:
		if not suitcase.visible or suitcase.is_held() or not on_belt(suitcase):
			continue
		var at := airport.to_local(suitcase.global_position)
		var off := Airport.BELT_Z - at.z
		var velocity := airport.global_basis * Vector3(SPEED, 0, off * CENTER_PULL)
		suitcase.linear_velocity.x = velocity.x
		suitcase.linear_velocity.z = velocity.z
		suitcase.angular_velocity = Vector3.ZERO
		if at.x > Airport.XRAY_AT.x and not suitcase.has_meta("xrayed"):
			suitcase.set_meta("xrayed", true)
			xrayed.emit(suitcase)
		if at.x > Airport.BELT_X.y - Suitcase.SIZE.x / 2:
			_load(suitcase)


## Off the belt's end and into the plane's hold: it's gone from the terminal.
func _load(suitcase: Suitcase) -> void:
	loaded_count += 1
	suitcase.hide()
	suitcase.freeze = true
	suitcase.collision_layer = 0
	suitcase.global_position = airport.to_global(Airport.PLANE_AT + Vector3.UP * 0.5)
	loaded.emit(suitcase)


## The scale in front of the counter shows what's lying on it.
func _weigh() -> void:
	if _readout == null:
		return
	var kg := 0.0
	var pan := Airport.COUNTER_AT + Airport.SCALE_AT
	var on: Array[Suitcase] = []
	for suitcase in line:
		if not suitcase.visible or suitcase.is_held():
			continue
		var at := airport.to_local(suitcase.global_position)
		if absf(at.x - pan.x) < Airport.SCALE_PAN / 2 and absf(at.z - pan.z) < Airport.SCALE_PAN / 2 and at.y < 0.8:
			kg += suitcase.weight()
			on.append(suitcase)
			# The odd one's weight gives it away (step 3).
			var odd := OddCargo.of(suitcase)
			if odd and not _on_scale.has(suitcase):
				odd.weighed()
	_on_scale = on
	_readout.text = "%d kg" % roundi(kg)
