class_name AuctionPodium
extends StaticBody3D

## Don Martillo's podium (infiltracion-subasta.md, step 3, decision 177): a dark wood lectern with a gold plate and his
## golden gavel on top, which comes down on its block with a "toc" when a lot is sold (bang). Above it hangs the board
## with the lot's price (show_price), empty between lots. Every number here is (propuesta).

const MODEL := preload("res://assets/models/auction_podium.glb")
const GAVEL := preload("res://assets/models/auction_gavel.glb")
const TOP := 1.1
const SIZE := Vector3(1.2, 1.1, 0.5)
## How far the gavel lifts (radians) and how long a bang takes.
const LIFT := 0.9
const BANG_TIME := 0.35
## The price board, over the podium.
const BOARD_AT := Vector3(0, 2.25, 0)

var bangs := 0
var price := 0
var _gavel: Node3D
var _board: Label3D
var _toc: AudioStreamPlayer3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	_gavel = GAVEL.instantiate()
	_gavel.name = "Gavel"
	_gavel.position = Vector3(-0.35, TOP, -0.1)
	add_child(_gavel)
	_board = Label3D.new()
	_board.name = "PriceBoard"
	_board.font_size = 64
	_board.pixel_size = 0.006
	_board.outline_size = 12
	_board.modulate = Color(1.0, 0.85, 0.35)
	_board.position = BOARD_AT
	add_child(_board)
	_toc = AudioStreamPlayer3D.new()
	_toc.name = "Toc"
	_toc.stream = toc_stream()
	_toc.max_distance = 30.0
	add_child(_toc)
	show_price(0)


## The gavel lifts and comes down on its block, "toc".
func bang() -> void:
	bangs += 1
	var tween := create_tween()
	tween.tween_property(_gavel, "rotation:z", LIFT, BANG_TIME * 0.6)
	tween.tween_property(_gavel, "rotation:z", 0.0, BANG_TIME * 0.4)
	tween.tween_callback(_toc.play)


## The board shows `value` (0 empties it).
func show_price(value: int) -> void:
	price = value
	_board.text = (tr("AUCTION_PRICE") % value) if value > 0 else ""


## A short wooden knock.
static func toc_stream() -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * 0.12)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / rate
		var value := sin(TAU * 420.0 * t) * exp(-t * 45.0) * 0.8
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 30000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream
