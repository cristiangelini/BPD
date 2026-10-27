class_name TunerRig
extends KaraokeRig

## The tuning microphone (allanamiento-karaoke.md, "El micrófono afinador"): Rosaura sings perfectly only with her
## golden microphone, which has a tuner inside. One of the booths' microphones (drawn with the seed) has the spare
## tuner in it: a cop holding it "sings" perfectly, golden notes over the microphone, and the first time that's the
## clue. With any other microphone Rosaura sings off key, so in a duet she squeals. The golden microphone, the spare
## tuner chip and the manual are hidden. Every number here is (propuesta).

const GOLD := Color(1.0, 0.82, 0.2)
## How often Rosaura squeals off key while she sings a duet.
const OFF_KEY_EVERY := 3.0

## The booth microphone with the tuner inside (an index into karaoke.mics), and whether a cop noticed.
var tuned := 2
var noticed := false
## Whether a cop holds the tuned microphone now, and how many times Rosaura squealed (online, from the host).
var singing := false
var squeals := 0
var _squealed := 0
var _notes: Label3D
var _off_key_left := 0.0


func shared() -> Array[String]:
	return ["noticed", "singing", "squeals"]


func apply_net_state(state: Variant) -> void:
	super.apply_net_state(state)
	_notes.visible = singing
	if squeals > _squealed:
		_squealed = squeals
		_squeal()


func setup(place: Karaoke) -> void:
	super.setup(place)
	karaoke.main = karaoke.hidden[0]
	tuned = 2 + karaoke.case_seed % (Karaoke.MIC_STANDS.size() - 2)
	_notes = Label3D.new()
	_notes.text = tr("KARAOKE_TUNER_SING")
	_notes.modulate = GOLD
	_notes.font_size = 40
	_notes.pixel_size = 0.006
	_notes.outline_size = 10
	_notes.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_notes.no_depth_test = true
	_notes.position = Vector3.UP * 0.5
	_notes.hide()
	karaoke.mics[tuned].add_child(_notes)


## A cop holding the tuned microphone sings perfectly; the first time, the clue.
func _sing(cops: Array[Cop]) -> void:
	singing = not cops.is_empty()
	_notes.visible = singing
	if cops.is_empty() or noticed:
		return
	noticed = true
	karaoke.raid.add_clue(tr("KARAOKE_TUNER_CLUE"))


## Online the host sees who holds the microphone and Rosaura sing; the guests' rig shows it from its state.
func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	_sing(karaoke.mics[tuned].handling_cops(0.0))
	var boss := karaoke.owner_boss
	if not boss.is_fixing() or boss.errand() != "printer":
		_off_key_left = 0.0
		return
	_off_key_left -= delta
	if _off_key_left <= 0.0:
		_off_key_left = OFF_KEY_EVERY
		squeals += 1
		_squealed = squeals
		_squeal()


func _squeal() -> void:
	karaoke._say(karaoke.to_local(karaoke.owner_boss.global_position) + Vector3.UP * 2.8, "DIVA_OFF_KEY", 2.0)
