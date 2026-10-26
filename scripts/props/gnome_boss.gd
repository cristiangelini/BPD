class_name GnomeBoss
extends HintedEvidence

## The boss gnome (ferreteria.md, "Los gnomos con relojes"): hollow and full of stolen watches, it looks like the
## other eleven in the yard but ticks. Close up (TICK_RANGE) a cop hears "tic tac" over it; the first time anyone does,
## it says so once (heard), for the case's clue list. Its value stays hidden until it's grabbed, or the number would
## give it away. Every number here is (propuesta).

signal heard

const TICK_EVERY := 1.0
const TICK_RANGE := 2.0
const MIX_RATE := 22050

var was_heard := false
var _tick_left := TICK_EVERY
var _tick: AudioStreamPlayer3D
var _tick_label: Label3D


func _ready() -> void:
	super._ready()
	_tick = AudioStreamPlayer3D.new()
	_tick.stream = tick_sound()
	_tick.max_distance = TICK_RANGE * 1.5
	_tick.unit_size = 1.0
	add_child(_tick)
	_tick_label = Label3D.new()
	_tick_label.text = "FX_TICK"
	_tick_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_tick_label.pixel_size = 0.003
	_tick_label.outline_size = 6
	_tick_label.position = Vector3(0, 0.65, 0)
	_tick_label.hide()
	add_child(_tick_label)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_tick_left -= delta
	if _tick_left <= 0.0:
		_tick_left = TICK_EVERY
		tick()


## One tick: always a little sound, and the "tic tac" over it while a cop stands close enough.
func tick() -> void:
	if is_broken:
		return
	_tick.play()
	if not a_cop_hears():
		return
	_tick_label.show()
	get_tree().create_timer(TICK_EVERY * 0.6).timeout.connect(_tick_label.hide)
	if not was_heard:
		was_heard = true
		heard.emit()


func a_cop_hears() -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= TICK_RANGE:
			return true
	return false


## A placeholder tick until there's real sound: a short dry click.
static func tick_sound() -> AudioStreamWAV:
	var samples := int(MIX_RATE * 0.03)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / samples
		data.encode_s16(i * 2, int(sin(TAU * 2400.0 * i / MIX_RATE) * (1.0 - t) * (1.0 - t) * 9000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.data = data
	return wav
