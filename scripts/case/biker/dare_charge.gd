class_name DareCharge
extends AnimatableBody3D

## The "don't move" dare's bike in the biker bar's patio (infiltracion-motos.md, step 3, decision 176): a biker on the
## heavy bike's twin waits at the far end of a lane painted on the floor, facing the line. charge() sends him at
## SPEED toward the line and he brakes STOP_SHORT before it (`braked`); back() puts him at the start again. Each PC
## moves its own from the same calls, so online the host only has to tell the guests when (step 6). Every number here
## is (propuesta).

signal braked

const BIKE := preload("res://assets/models/heavy_bike.glb")
const RIDER := preload("res://assets/models/npc_motoquero.glb")
const SPEED := 6.0
## How far before the line he stops (m).
const STOP_SHORT := 1.0
## How long the lane is, from the start to the line (m).
const LANE := 6.0

var charging := false
## Where he starts and where he stops, in the parent's space (set from the line on ready).
var start := Vector3.ZERO
var stop := Vector3.ZERO
var _engine: AudioStreamPlayer3D


func _ready() -> void:
	collision_layer = 1
	sync_to_physics = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = HeavyBike.SIZE
	shape.shape = box
	shape.position.y = HeavyBike.SIZE.y / 2
	add_child(shape)
	add_child(BIKE.instantiate())
	var rider: Node3D = RIDER.instantiate()
	rider.name = "Rider"
	rider.position = Vector3(0, 0.55, -0.25)
	rider.scale = Vector3.ONE * 1.0
	add_child(rider)
	start = position
	stop = position + transform.basis.z * (LANE - STOP_SHORT)
	_engine = AudioStreamPlayer3D.new()
	_engine.stream = engine_stream()
	_engine.max_distance = 30.0
	add_child(_engine)


## Off he goes toward the line.
func charge() -> void:
	position = start
	charging = true
	_engine.play()


## Back at the start, still.
func back() -> void:
	charging = false
	position = start
	_engine.stop()


## Where the line is, in the parent's space.
func line_at() -> Vector3:
	return start + transform.basis.z * LANE


func _physics_process(delta: float) -> void:
	if not charging:
		return
	var to := stop - position
	var step := SPEED * delta
	if to.length() <= step:
		position = stop
		charging = false
		_engine.stop()
		braked.emit()
		return
	position += to.normalized() * step


## A bike's engine: a low wobbling buzz that loops.
static func engine_stream() -> AudioStreamWAV:
	var rate := 22050
	var samples := rate
	var data := PackedByteArray()
	data.resize(samples * 2)
	var phase := 0.0
	for i in samples:
		var t := float(i) / rate
		phase += (55.0 + 8.0 * sin(TAU * 6.0 * t)) / rate
		var value := (fmod(phase, 1.0) * 2.0 - 1.0) * 0.35
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 30000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	return stream
