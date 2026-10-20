class_name SourdoughJar
extends Evidence

## Gertrudis, the prize sourdough, in her glass jar (panaderia.md, "La masa madre robada"). She bubbles and gurgles,
## louder up close, so a cop can find her by ear. She keeps growing: every GROW_EVERY seconds the jar weighs a bit
## more. The glass is fragile: a hit harder than SHATTER_SPEED breaks it whole. Every number here is (propuesta).

const GROW_EVERY := 60.0
const GROW_KG := 0.5
const MAX_KG := 6.0
const SHATTER_SPEED := 4.0
## A gurgle every BUBBLE_EVERY seconds, heard (and shown) up to HEAR_RANGE meters away.
const BUBBLE_EVERY := 1.6
const HEAR_RANGE := 7.0
const MIX_RATE := 22050

var _grow_left := GROW_EVERY
var _bubble_left := BUBBLE_EVERY
var _gurgle: AudioStreamPlayer3D
var _blub: Label3D


func _ready() -> void:
	super._ready()
	_gurgle = AudioStreamPlayer3D.new()
	_gurgle.stream = gurgle_sound()
	_gurgle.max_distance = HEAR_RANGE
	_gurgle.unit_size = 2.0
	add_child(_gurgle)
	_blub = Label3D.new()
	_blub.text = "FX_BLUB"
	_blub.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_blub.pixel_size = 0.003
	_blub.outline_size = 6
	_blub.modulate = Color(0.95, 0.9, 0.7)
	_blub.position = Vector3(0, 0.3, 0)
	_blub.hide()
	add_child(_blub)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_grow_left -= delta
	if _grow_left <= 0.0:
		_grow_left = GROW_EVERY
		grow()
	_bubble_left -= delta
	if _bubble_left <= 0.0:
		_bubble_left = BUBBLE_EVERY
		_bubble()


## A minute more of rising: heavier, up to MAX_KG.
func grow() -> void:
	mass = minf(mass + GROW_KG, MAX_KG)


## Too hard a hit breaks the glass, and Gertrudis with it.
func hit(speed: float) -> float:
	return super.hit(INF if speed > SHATTER_SPEED else speed)


func _bubble() -> void:
	if is_broken:
		return
	_gurgle.play()
	if not _a_cop_hears():
		return
	_blub.show()
	get_tree().create_timer(0.6).timeout.connect(_blub.hide)


func _a_cop_hears() -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= HEAR_RANGE:
			return true
	return false


## A placeholder gurgle until there's real sound: a short rising bloop.
static func gurgle_sound() -> AudioStreamWAV:
	var samples := int(MIX_RATE * 0.22)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var phase := 0.0
	for i in samples:
		var t := float(i) / samples
		phase += TAU * lerpf(180.0, 520.0, t * t) / MIX_RATE
		var envelope := sin(PI * t) * (1.0 - t * 0.5)
		data.encode_s16(i * 2, int(sin(phase) * envelope * 12000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.data = data
	return wav
