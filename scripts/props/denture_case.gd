class_name DentureCase
extends Evidence

## The case of rented dentures from the care home (historias.md, "Dentaduras del geriátrico"). The dentures inside
## chatter, louder up close, so a cop can find the case by ear. Every number here is (propuesta).

## A chatter every CLACK_EVERY seconds, heard (and shown) up to HEAR_RANGE meters away.
const CLACK_EVERY := 2.0
const HEAR_RANGE := 7.0
const MIX_RATE := 22050

var _clack_left := CLACK_EVERY
var _sound: AudioStreamPlayer3D
var _clack_label: Label3D


func _ready() -> void:
	super._ready()
	_sound = AudioStreamPlayer3D.new()
	_sound.stream = chatter_sound()
	_sound.max_distance = HEAR_RANGE
	_sound.unit_size = 2.0
	add_child(_sound)
	_clack_label = Label3D.new()
	_clack_label.text = "FX_CLACK"
	_clack_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_clack_label.pixel_size = 0.003
	_clack_label.outline_size = 6
	_clack_label.modulate = Color(1, 1, 0.9)
	_clack_label.position = Vector3(0, 0.35, 0)
	_clack_label.hide()
	add_child(_clack_label)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_clack_left -= delta
	if _clack_left <= 0.0:
		_clack_left = CLACK_EVERY
		chatter()


func chatter() -> void:
	if is_broken:
		return
	_sound.play()
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= HEAR_RANGE:
			_clack_label.show()
			get_tree().create_timer(0.7).timeout.connect(_clack_label.hide)
			return


## A placeholder chatter until there's real sound: four quick clicks.
static func chatter_sound() -> AudioStreamWAV:
	var samples := int(MIX_RATE * 0.4)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in samples:
		var t := fmod(float(i) / MIX_RATE, 0.1)
		var envelope := exp(-t * 90.0)
		data.encode_s16(i * 2, int(rng.randf_range(-1.0, 1.0) * envelope * 14000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.data = data
	return wav
