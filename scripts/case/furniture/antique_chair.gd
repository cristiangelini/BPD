class_name AntiqueChair
extends StaticBody3D

## A dining chair of the furniture store sold as an antique (allanamiento-muebleria.md, "Las antigüedades de ayer"):
## E turns it upside down for FLIP_TIME seconds, showing its tag with an absurd price and, underneath, the stamp "Made
## last week". Every number here is (propuesta).

signal flipped(cop: Cop)

const FLIP_TIME := 4.0
## Upside down it rests on the top of its back, this high in its own space.
const BACK_TOP := 0.91
const SEAT_BOTTOM := 0.44

## What it costs (in installments), drawn by the store's seed.
var price := 0
var _standing: Transform3D
var _flip_left := 0.0
var _stamp: Label3D
var _tag: Label3D


func _ready() -> void:
	_stamp = _label(tr("FURNITURE_MADE_LAST_WEEK"), Vector3(0, SEAT_BOTTOM - 0.01, 0), 28)
	_stamp.rotation.x = -PI / 2
	_stamp.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	_stamp.modulate = Color(0.85, 0.2, 0.15)
	_stamp.hide()
	_tag = _label(tr("FURNITURE_ANTIQUE_PRICE") % price, Vector3(0, 1.4, 0), 24)
	_tag.hide()


func prompt_key(_cop: Cop) -> String:
	return "" if is_flipped() else "PROMPT_FLIP_CHAIR"


func is_flipped() -> bool:
	return _flip_left > 0.0


## Turns it upside down: the stamp underneath and the price tag for all to see.
func use(cop: Cop) -> void:
	if is_flipped():
		return
	_standing = transform
	_flip_left = FLIP_TIME
	transform = _standing * Transform3D(Basis(Vector3.RIGHT, PI), Vector3(0, BACK_TOP, 0))
	_tag.position = Vector3(0, BACK_TOP - 1.4, 0)
	_tag.show()
	_stamp.show()
	flipped.emit(cop)


func _physics_process(delta: float) -> void:
	if not is_flipped():
		return
	_flip_left -= delta
	if is_flipped():
		return
	transform = _standing
	_tag.hide()
	_stamp.hide()


func _label(text: String, at: Vector3, size: int) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.004
	label.outline_size = 8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	return label
