class_name MuseumAlarm
extends Node3D

## The museum's alarm (escena-museo.md, "La alarma"): red lasers run between the busts' pedestals in the gallery. A
## cop who walks through one sets it off for a while: a red light blinks, Señora Pincel shouts and the six guards run
## "to the bathroom!" and squeeze in front of its door until it stops. The button on the security desk stops it
## sooner. It's a nuisance, it never loses the case. Every number here is (propuesta).

const SECONDS := 10.0
## A cop's middle this close to a laser's line breaks it, in meters.
const REACH := 0.2
const LASER_HEIGHT := 0.7
## How fast the guards run to the bathroom and back, in m/s.
const RUN_SPEED := 4.0
const BLINK := 0.4
const LASER := Color(1.0, 0.1, 0.1)
## The button on the security desk, beside the monitors.
const BUTTON_AT := Vector3(0.3, 0.02, 1.0)

var museum: Museum
var ringing := false
var left := 0.0
## The lasers, as pairs of points (the pedestals they run between).
var lasers: Array[Array] = []
var _light: OmniLight3D
var _blink_left := 0.0


func _ready() -> void:
	var builder := PlaceBuilder.new(self)
	for i in Museum.PEDESTALS.size() - 1:
		var from := Museum.PEDESTALS[i]
		var to := Museum.PEDESTALS[i + 1]
		lasers.append([from, to])
		var beam := BoxMesh.new()
		beam.size = Vector3(0.02, 0.02, from.distance_to(to))
		var way := to - from
		builder.mesh(beam, (from + to) / 2 + Vector3(0, LASER_HEIGHT, 0), LASER, Vector3(0, atan2(way.x, way.z), 0))
	_light = OmniLight3D.new()
	_light.name = "AlarmLight"
	_light.light_color = LASER
	_light.light_energy = 3.0
	_light.omni_range = 14.0
	_light.position = Vector3(3.5, Museum.ROOF - 0.6, -4.5)
	_light.visible = false
	add_child(_light)
	var button := AlarmButton.new()
	button.name = "AlarmButton"
	button.alarm = self
	button.position = Museum.DESK_AT + Vector3(0, Museum.DESK_SIZE.y, 0) + BUTTON_AT
	add_child(button)


## Whether a point in the museum's space (ignoring height) is on a laser's line.
func on_laser(at: Vector3) -> bool:
	var flat := Vector2(at.x, at.z)
	for laser in lasers:
		var from := Vector2(laser[0].x, laser[0].z)
		var to := Vector2(laser[1].x, laser[1].z)
		if Geometry2D.get_closest_point_to_segment(flat, from, to).distance_to(flat) <= REACH:
			return true
	return false


## Sets it off (or keeps it going): the light, the director's shout and the guards off to the bathroom.
func ring(cop: Cop = null) -> void:
	left = SECONDS
	if ringing:
		return
	ringing = true
	_light.visible = true
	if cop:
		cop.show_hint("HINT_ALARM_RINGS")
	museum.director.say("MUSEUM_DIRECTOR_ALARM")
	for guard in museum.guards:
		guard.say("GUARD_TO_BATHROOM", 2.0)


func stop(cop: Cop = null) -> void:
	if cop:
		cop.show_hint("HINT_ALARM_OFF" if ringing else "HINT_ALARM_QUIET")
	ringing = false
	left = 0.0
	_light.visible = false


## Where a guard squeezes in front of the bathroom's door, by his index.
static func crowd_spot(index: int) -> Vector3:
	return Vector3(Museum.GALLERY_X + 0.6 + 0.6 * (index / 3), 0, Museum.DOOR_BATHROOM_Z - 0.6 + 0.6 * (index % 3))


## One step of the guards running: to the bathroom while it rings, back to their row when it stops.
func run_guards(delta: float) -> void:
	for guard in museum.guards:
		if not guard.visible:
			continue
		var spot := crowd_spot(guard.index) if ringing else Museum.GUARDS_AT[guard.index]
		spot.y = guard.position.y
		guard.position = guard.position.move_toward(spot, RUN_SPEED * delta)


func _physics_process(delta: float) -> void:
	# Online the host's lasers decide; a guest's alarm follows (Museum.apply_net_state).
	var follower := museum.case != null and museum.case.follower
	if not follower:
		for node in get_tree().get_nodes_in_group("cops"):
			var cop := node as Cop
			if museum.in_gallery(cop.global_position) and on_laser(museum.to_local(cop.global_position)):
				ring(cop)
	if ringing:
		left -= delta
		_blink_left -= delta
		if _blink_left <= 0.0:
			_blink_left = BLINK
			_light.visible = not _light.visible
		if left <= 0.0 and not follower:
			stop()
	run_guards(delta)
