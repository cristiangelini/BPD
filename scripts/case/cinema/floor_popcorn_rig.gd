class_name FloorPopcornRig
extends CinemaRig

## The floor popcorn (allanamiento-cine.md, "Las palomitas del piso"): doña Bobina sweeps the popcorn off the theater's
## floor and sells it again as fresh. The sack of swept popcorn is hidden with the "reciclaje" broom and the "recién
## hechas" sign; on the candy counter a bowl of it waits, and a cop who eats one spits it out (a joke over their head,
## every time) and finds the story's own clue the first time.

## The bowl on the counter, at its west end, away from the popcorn machine.
const BOWL_AT := Vector3(3.4, 1.12, 9.6)

var bowl: CounterPopcorn


func setup(place: Cinema) -> void:
	super.setup(place)
	bowl = CounterPopcorn.new()
	bowl.name = "CounterPopcorn"
	bowl.position = BOWL_AT + Vector3(0, Cinema.FLOOR_TOP, 0)
	bowl.text = "HINT_FLOOR_POPCORN"
	place.add_child(bowl)
	bowl.read.connect(func(_text: String) -> void: place.raid.add_clue(tr("CLUE_FLOOR_POPCORN")))
	bowl.eaten.connect(func(cop: Cop) -> void:
		place._say(place.to_local(cop.global_position) + Vector3(0, 2.1, 0), "CINEMA_SPIT"))
