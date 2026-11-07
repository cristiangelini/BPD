class_name FakeTicketsRig
extends CinemaRig

## The fake tickets (allanamiento-cine.md, "Las entradas truchas"): doña Bobina prints her own tickets and sells each
## seat twice. The ticket press is hidden with the "función agotada" stamp and the fake ticket book; the ticket booth
## says "AGOTADO" over a theater that's almost empty, and two neighbors with the same seat on their ticket argue over it
## side by side: a cop who gets close to them finds the story's own clue (on the checklist the first time). Every number
## here is (propuesta).

signal overheard(cop: Cop)

const NEAR := 2.0
const ARGUE_EVERY := 3.0
const ARGUMENT: Array[String] = ["CINEMA_SAME_SEAT_1", "CINEMA_SAME_SEAT_2", "CINEMA_SAME_SEAT_3",
	"CINEMA_SAME_SEAT_4"]

## The two neighbors who argue, the "AGOTADO" sign and the cops who already heard them.
var arguers: Array[CinemaSpectator] = []
var sold_out: Label3D
var heard_by := {}
var _until_line := 0.0
var _line := 0


func setup(place: Cinema) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["fake tickets", place.case_seed])
	var pairs: Array[int] = []
	for seat in Cinema.ROWS * Cinema.SEATS_PER_ROW:
		if seat % Cinema.SEATS_PER_ROW < Cinema.SEATS_PER_ROW - 1 and place.seat_free(seat) and place.seat_free(seat + 1):
			pairs.append(seat)
	var at := pairs[rng.randi_range(0, pairs.size() - 1)]
	for i in 2:
		var arguer := place.seat_spectator(at + i, (place.case_seed + i) % CinemaSpectator.MODELS.size())
		arguer.line_override = "CINEMA_SAME_SEAT_TICKET"
		arguers.append(arguer)
	sold_out = Label3D.new()
	sold_out.name = "SoldOut"
	sold_out.text = "CINEMA_SOLD_OUT"
	sold_out.font_size = 64
	sold_out.pixel_size = 0.008
	sold_out.outline_size = 10
	sold_out.modulate = Color(1.0, 0.25, 0.2)
	sold_out.position = Cinema.TICKETS_AT + Vector3(0, Cinema.TICKETS_SIZE.y + 0.9, Cinema.TICKETS_SIZE.z / 2 + 0.05)
	place.add_child(sold_out)
	var area := Area3D.new()
	area.name = "NearArgument"
	area.collision_layer = 0
	area.collision_mask = 2
	area.position = (arguers[0].position + arguers[1].position) / 2
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = NEAR
	shape.shape = ball
	area.add_child(shape)
	place.add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop:
			overhear(body))


## `cop` got close to the two who argue: what they hear and, the first time anyone does, the clue.
func overhear(cop: Cop) -> void:
	if heard_by.has(cop):
		return
	heard_by[cop] = true
	cop.show_hint("HINT_SAME_SEAT")
	if heard_by.size() == 1:
		cinema.raid.add_clue(tr("CLUE_SAME_SEAT"))
	overheard.emit(cop)


func _process(delta: float) -> void:
	_until_line -= delta
	if _until_line <= 0.0:
		_until_line = ARGUE_EVERY
		arguers[_line % 2].say(tr(ARGUMENT[_line % ARGUMENT.size()]), ARGUE_EVERY - 0.2)
		_line += 1
