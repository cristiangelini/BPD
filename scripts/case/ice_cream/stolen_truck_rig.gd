class_name StolenTruckRig
extends IceCreamRig

## The stolen truck (allanamiento-heladeria.md, "El camión robado"): the ice cream truck in the yard was stolen from
## another shop and painted over. Its original plate is hidden with the can of fresh paint and the truck's papers with
## somebody else's name; a "wet paint" sign hangs on the truck's side (reading it, E, is the story's own clue), and every
## JINGLE_EVERY seconds the truck plays the other shop's jingle by itself. Every number here is (propuesta).

const JINGLE_EVERY := 35.0
const JINGLE_SECONDS := 5.0
## The sign on the truck's side facing the kitchen's back door, and where the jingle shows over its roof.
const PAINT_AT := Vector3(IceCreamShop.TRUCK_AT.x, 1.4, IceCreamShop.TRUCK_AT.z + 1.15)
const JINGLE_AT := Vector3(IceCreamShop.TRUCK_AT.x, 3.3, IceCreamShop.TRUCK_AT.z)

var paint_sign: ClueSpot
## Times the jingle played by itself.
var jingles := 0
var _jingle: Label3D
var _since := 0.0
var _left := 0.0


func setup(place: IceCreamShop) -> void:
	super.setup(place)
	paint_sign = sign_spot(PAINT_AT, 0.0, "ICE_WET_PAINT", tr("CLUE_FRESH_PAINT"), Vector3(0.6, 0.3, 0.06), 32)
	paint_sign.name = "WetPaint"
	_jingle = Label3D.new()
	_jingle.name = "Jingle"
	_jingle.position = JINGLE_AT
	_jingle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_jingle.pixel_size = 0.005
	_jingle.no_depth_test = true
	_jingle.outline_size = 8
	_jingle.font_size = 40
	_jingle.modulate = Color(1.0, 0.85, 0.95)
	_jingle.visible = false
	shop.add_child(_jingle)


## The truck plays the other shop's jingle, by itself.
func play_jingle() -> void:
	_since = 0.0
	jingles += 1
	_jingle.text = tr("ICE_TRUCK_JINGLE")
	_jingle.visible = true
	_left = JINGLE_SECONDS


func jingle_text() -> String:
	return _jingle.text if _jingle.visible else ""


func _process(delta: float) -> void:
	_since += delta
	if _since >= JINGLE_EVERY:
		play_jingle()
	if _jingle.visible:
		_left -= delta
		if _left <= 0.0:
			_jingle.visible = false
