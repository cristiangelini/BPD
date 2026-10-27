class_name RiggedContestRig
extends RadioRig

## The rigged contest (allanamiento-radio.md, "El concurso arreglado"): every contest of the station is won by don
## Volumen's cousin Tito. The urn with every slip saying the same name is hidden with the prize nobody got and the
## winners list; on air, every ANNOUNCE_EVERY seconds he announces "¡Y el ganador es... Tito, otra vez!", and a slip
## fell by the mailbox where the entries come in: reading it (E) is the story's own clue. Every number here is
## (propuesta).

const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
const ANNOUNCE_EVERY := 30.0
## The slip on the floor by the reception's mailbox.
const SLIP_AT := Vector3(7.4, RadioStation.FLOOR_TOP + 0.01, 6.7)

var slip: ClueNote
## Times he announced Tito on air.
var announced := 0
var _since := 0.0


func setup(place: RadioStation) -> void:
	super.setup(place)
	slip = NOTE_SCENE.instantiate()
	slip.name = "TitoSlip"
	slip.text = tr("CLUE_TITO_SLIP")
	slip.position = SLIP_AT
	slip.rotation.y = 0.6
	slip.read.connect(radio.raid.add_clue)
	radio.add_child(slip)


## On air, Tito wins again.
func announce() -> void:
	_since = 0.0
	if not radio.on_air:
		return
	announced += 1
	radio.say_on_air("RADIO_TITO_WINS")


func _process(delta: float) -> void:
	_since += delta
	if _since >= ANNOUNCE_EVERY:
		announce()
