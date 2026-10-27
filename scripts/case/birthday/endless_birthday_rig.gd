class_name EndlessBirthdayRig
extends BirthdayRaidRig

## The endless birthday (allanamiento-cumple.md, "El cumpleaños eterno"): Chispita rents the hall for "Tomasito's 7th
## birthday" every week and pays kid actors to be the guests; the album of the 52 parties is hidden. Tomasito, asked
## before the piñata breaks, says he turns seven again (the story's own clue, on the checklist), the guests ask for
## their pay when a cop talks to them, and at cake time they sing with a choreography: they hop in time. Every number
## here is (propuesta).

const WAGES := ["BIRTHDAY_KID_WAGES_1", "BIRTHDAY_KID_WAGES_2", "BIRTHDAY_KID_WAGES_3"]
const HOP := 0.15
const HOPS_PER_SECOND := 2.0

var _song_time := 0.0


func setup(place: BirthdayRaid) -> void:
	super.setup(place)
	place.tomasito_wait_line = "TOMASITO_SEVEN_AGAIN"
	place.tomasito_asked.connect(_on_tomasito_asked)
	for kid in place.kids.slice(1):
		kid.talked.connect(_ask_pay.bind(kid))


func _on_tomasito_asked(_cop: Cop) -> void:
	party.raid.add_clue(tr("CLUE_ENDLESS_BIRTHDAY"))


func _ask_pay(_cop: Cop, kid: PartyKid) -> void:
	kid.say(WAGES[kid.next_line % WAGES.size()])


## The rehearsed choreography: every guest hops at the same time while they sing.
func _process(delta: float) -> void:
	if not party or not party.singing():
		_song_time = 0.0
		return
	_song_time += delta
	var up := absf(sin(_song_time * PI * HOPS_PER_SECOND)) * HOP
	for kid in party.kids:
		if party.in_song(kid):
			kid.position.y = BirthdayRaid.FLOOR_TOP + up
