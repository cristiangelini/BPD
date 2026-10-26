class_name AirportXray
extends Node

## The X-ray machine on show (politico-aeropuerto.md, step 3, decision 231): whatever the belt takes through it is
## on the big screen, with a caption under it, in front of the press. One of Lustre's suitcases makes them laugh (a
## teddy bear!); the odd one is a scandal on every front page (`scandal`, the case is lost, step 5). Every number here
## is (propuesta).

signal scandal(kind: String)

const CAPTION_TIME := 4.0
const LAUGHS := 3
const SCANDALS := 3

var airport: Airport
var scanned := 0
var _caption: Label3D
var _caption_left := 0.0


func setup(the_airport: Airport) -> void:
	airport = the_airport
	airport.belt.xrayed.connect(scan)
	_caption = Label3D.new()
	_caption.name = "XrayCaption"
	_caption.font_size = 40
	_caption.pixel_size = 0.006
	_caption.outline_size = 10
	_caption.width = 600.0
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Along the bottom of the screen, like a news ticker.
	_caption.position = Airport.SCREEN_AT + Vector3(0, -Airport.SCREEN.y / 2 + 0.22, 0.03)
	_caption.hide()
	airport.get_node("Built").add_child(_caption)


func caption() -> String:
	return _caption.text if _caption.visible else ""


## `suitcase` goes through the machine now.
func scan(suitcase: Suitcase) -> void:
	scanned += 1
	var odd := OddCargo.of(suitcase)
	_caption.text = "XRAY_%s" % (odd.kind.to_upper() if odd else "NORMAL")
	_caption.show()
	_caption_left = CAPTION_TIME
	for i in airport.press.size():
		airport.press[i].say("PRESS_SCANDAL_%d" % (i % SCANDALS + 1) if odd else "PRESS_LAUGH_%d" % (i % LAUGHS + 1))
	if odd:
		for cop in get_tree().get_nodes_in_group("cops"):
			(cop as Cop).show_hint("HINT_AIRPORT_SCANDAL")
		scandal.emit(odd.kind)


func _process(delta: float) -> void:
	if _caption_left > 0.0:
		_caption_left -= delta
		if _caption_left <= 0.0:
			_caption.hide()
