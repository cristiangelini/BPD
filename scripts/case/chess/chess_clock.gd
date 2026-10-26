class_name ChessClock
extends StaticBody3D

## The clock on each of the chess club's tables (infiltracion-ajedrez.md, step 3, decision 175): a face toward each
## player (white's toward +Z, black's toward -Z) and a button on top. Running, it counts down the side whose turn it
## is, TURN seconds each turn: E presses the button, the turn goes to the other side and its time starts again; at 0
## that side ran out of time (`flagged`). The host runs it (step 4 says who plays and when) and tells the guests every
## change of turn (step 6); in between each PC counts down on its own. Every number here is (propuesta).

signal pressed(cop: Cop, side: int)
signal flagged(side: int)

const MODEL := preload("res://assets/models/chess_clock.glb")
const TURN := 8.0
const WHITE := 0
const BLACK := 1
## Not running.
const STOPPED := -1

## Whose turn it is (WHITE, BLACK or STOPPED) and the seconds left of it.
var turn := STOPPED
var left := TURN
var _faces: Array[Label3D] = []
var _click: AudioStreamPlayer3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.24, 0.15, 0.1)
	shape.shape = box
	shape.position.y = 0.075
	add_child(shape)
	add_child(MODEL.instantiate())
	for side in 2:
		var face := Label3D.new()
		face.font_size = 40
		face.pixel_size = 0.0015
		face.outline_size = 0
		face.double_sided = false
		face.modulate = Color(0.1, 0.1, 0.12)
		face.position = Vector3(0, 0.065, 0.05 if side == WHITE else -0.05)
		face.rotation.y = 0.0 if side == WHITE else PI
		add_child(face)
		_faces.append(face)
	_click = AudioStreamPlayer3D.new()
	_click.stream = click_stream()
	_click.max_distance = 15.0
	add_child(_click)
	_refresh()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CHESS_CLOCK"


## Click; on the host the turn goes to the other side.
func use(cop: Cop) -> void:
	_click.play()
	if not multiplayer.is_server() or turn == STOPPED:
		return
	var side := turn
	_set_turn(1 - turn)
	pressed.emit(cop, side)


## Starts counting `side`'s turn.
func start(side: int) -> void:
	_set_turn(side)


func stop() -> void:
	_set_turn(STOPPED)


## The turn goes to `side` with its full time, on every PC.
func _set_turn(side: int) -> void:
	_turn_now(side)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_turn_now.rpc_id(peer, side)


@rpc("authority", "call_remote", "reliable")
func _turn_now(side: int) -> void:
	turn = side
	left = TURN
	_refresh()


func _process(delta: float) -> void:
	if turn == STOPPED:
		return
	left = maxf(left - delta, 0.0)
	if left <= 0.0 and multiplayer.is_server():
		var side := turn
		stop()
		flagged.emit(side)
	_refresh()


## Each face shows its side's seconds while it's its turn, and dashes otherwise.
func _refresh() -> void:
	for side in _faces.size():
		_faces[side].text = "0:%02d" % ceili(left) if side == turn else "-:--"


## The Net of this PC's multiplayer branch: the autoload in the game, each test PC's own in the online tests.
func _net() -> Node:
	var branch := multiplayer as SceneMultiplayer
	if branch and not branch.root_path.is_empty():
		var net := get_node_or_null(str(branch.root_path) + "/Net")
		if net:
			return net
	return Net


## A short wooden "tock".
static func click_stream() -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * 0.08)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / rate
		var value := sin(TAU * 900.0 * t) * 0.5 * exp(-60.0 * t)
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 30000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream
