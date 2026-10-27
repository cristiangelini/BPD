class_name RegularGuestRig
extends HotelRig

## The regular guest (hotel-allanamiento.md, "El huésped de siempre"): the hotel says it's full every night, but its
## guests are always the same man, señor Ramón, in another disguise. His costume trunk is the main evidence, hidden
## like the extras (the fake guest book and the spare wig). The story's own clue: in the guest book on the desk, the
## forty signatures are all in the same handwriting. Ramón crosses the lobby in a new disguise every 40 s; a cop who
## bumps into him knocks his mustache off and he runs away (RegularGuest). Every number here is (propuesta).

const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")

var ramon: RegularGuest
var book: ClueNote


func setup(place: HotelRaid) -> void:
	super.setup(place)
	ramon = RegularGuest.new()
	ramon.name = "Ramon"
	place.add_child(ramon)
	ramon.unmasked.connect(func(_at: Vector3) -> void: place.raid.add_clue(tr("CLUE_REGULAR_GUEST_MUSTACHE")))
	book = NOTE_SCENE.instantiate()
	book.prompt = "PROMPT_GUEST_BOOK"
	book.text = tr("CLUE_REGULAR_GUEST_BOOK")
	book.position = Hotel.BOOK_AT + Vector3(0, 0.06, 0)
	book.read.connect(place.raid.add_clue)
	place.add_child(book)
