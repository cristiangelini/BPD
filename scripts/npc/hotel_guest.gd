class_name HotelGuest
extends HotelStaff

## One of the six guests of the Hotel Gran Siesta (escena-hotel.md, "Los huéspedes iguales"): the same white bathrobe,
## slippers, towel on the head and cucumber slices on the eyes as the other five. Under the towel, their own hair;
## under the cucumbers, their glasses if they wear them; their teeth show when they bite. On them almost nothing shows:
## that's why their rooms are the clues (step 3). E on one: a line, a different one each time; asked for the towel,
## never ("¡recién me lavé el pelo!"). Every number here is (propuesta).

## Their place in the case's order (step 3: their traits and their room).
var index := 0


func _ready() -> void:
	who = "guest"
	super()
	add_to_group("hotel_guests")
	part("hair").visible = false
	part("glasses").visible = false
	part("teeth").visible = false


func use(_cop: Cop) -> void:
	say(line_key(index + _lines_said))
	_lines_said += 1
