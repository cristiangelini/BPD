class_name PartyPhoto
extends Node3D

## The costume party's group photo (infiltracion-fiesta.md, step 3, decision 171): every so often the señora Serpentina
## calls "¡Foto grupal!" and everyone walks to the photo steps; CALL seconds later she counts "3, 2, 1" and the flash
## goes off. A cop on the steps holds still through the count; one who moves, or who isn't on the steps at the flash,
## makes the guests who see it suspicious (`missed`, to ClubSuspicion). While the others pose, the boss slips into the
## office to count the jewels (its door opens): a cop who skipped the photo and is in there sees him (`boss_seen`, the
## clue of step 4). Each PC judges its own cop and tells the host; the host decides when and tells the guests. Every
## number here is (propuesta).

signal photo_called
signal flashed
signal missed(cop: Cop, amount: float)
signal boss_seen(cop: Cop)

const FIRST := 25.0
## From one call to the next.
const EVERY := 45.0
## To get to the steps, then the count.
const CALL := 8.0
const COUNT := 3.0
const JUDGE_EVERY := 1.0
## Walking more than this in a second during the count is moving (m).
const STILL := 0.3
## What it adds to the guests who see it: moving on the steps during the count (per second), and being off the steps
## at the flash.
const MOVED := 25.0
const AWAY := 30.0
## How long the guests take to walk to their spot and back.
const WALK := 2.0
const MIX_RATE := 22050

## Seconds to the next call (host) and left of this photo (every PC; 0: no photo).
var next_left := FIRST
var photo_left := 0.0
var case_seed := 0
## The guests, the boss among them, and where each one mingles; the spots on the steps (PartyHall sets them).
var guests: Array[ClubMember] = []
var boss: ClubMember
var photo_spots: Array[Vector3] = []
## Where the boss counts the jewels in the office, the way in (in front of its door, in the hall) and the door; where
## Serpentina takes the photo from.
var office_spot := Vector3.ZERO
var office_way := Vector3.ZERO
var office_door: FrontDoor
var serpentina: ClubMember
var photographer_spot := Vector3.ZERO
## Whether a world position is on the photo steps, inside the hall, and in the office.
var on_steps: Callable = func(_at: Vector3) -> bool: return false
var inside: Callable = func(_at: Vector3) -> bool: return false
var in_office: Callable = func(_at: Vector3) -> bool: return false
## This PC's cop this photo: the boss was seen, and seconds right and wrong.
var saw_boss := false
var good_seconds := 0
var bad_seconds := 0
var _home := {}
var _judge_left := JUDGE_EVERY
var _walked := 0.0
var _last_at := Vector3.INF
var _flashed := false
var _click: AudioStreamPlayer3D
var _flash: OmniLight3D
var _hud: CanvasLayer
var _cue: Label
var _verdict: Label
var _white: ColorRect


func _ready() -> void:
	add_to_group("party_photo")
	for guest in guests:
		_home[guest] = guest.transform
	if serpentina:
		_home[serpentina] = serpentina.transform
	_click = AudioStreamPlayer3D.new()
	_click.stream = click_stream()
	_click.max_distance = 40.0
	add_child(_click)
	_flash = OmniLight3D.new()
	_flash.omni_range = 18.0
	_flash.light_energy = 0.0
	add_child(_flash)
	_build_hud()


func is_photo() -> bool:
	return photo_left > 0.0


## In the count, after everyone had CALL seconds to get to the steps.
func is_counting() -> bool:
	return is_photo() and photo_left <= COUNT


## Host: the photo is called now on every PC.
func call_photo() -> void:
	next_left = EVERY
	_begin()
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_called.rpc_id(peer)


@rpc("authority", "call_remote", "reliable")
func _called() -> void:
	_begin()


## Every PC: the guests walk to the steps, the boss to the office and Serpentina in front of the steps.
func _begin() -> void:
	photo_left = CALL + COUNT
	saw_boss = false
	_flashed = false
	good_seconds = 0
	bad_seconds = 0
	_walked = 0.0
	var spots := photo_spots.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["party photo", case_seed])
	for guest in guests:
		if guest == boss:
			continue
		var spot: Vector3 = spots.pop_at(rng.randi_range(0, spots.size() - 1))
		# On the steps, facing the camera (+Z).
		_walk(guest, Transform3D(Basis(Vector3.UP, PI), spot))
	if boss:
		# Through the door, facing the safe (+X).
		_walk(boss, Transform3D(Basis(Vector3.UP, -PI / 2), office_spot), _office_door_ways(Basis.IDENTITY))
	if office_door:
		office_door.open_from_inside()
	if serpentina:
		serpentina.say("PARTY_PHOTO_CALL")
		_walk(serpentina, Transform3D(Basis.IDENTITY, photographer_spot))
	var cop := VoiceChat.local_cop(get_tree())
	if cop and inside.call(cop.global_position):
		cop.show_hint("HINT_PARTY_PHOTO")
	photo_called.emit()


## Every PC: the photo is over, everyone back where they were.
func _end() -> void:
	for member: ClubMember in _home:
		if member == boss:
			var ways := _office_door_ways(Basis(Vector3.UP, PI))
			ways.reverse()
			_walk(member, _home[member], ways)
		else:
			_walk(member, _home[member])
	if office_door:
		office_door.close()


## In front of the office door in the hall, and just inside it, facing `basis`.
func _office_door_ways(basis: Basis) -> Array[Transform3D]:
	return [Transform3D(basis, office_way), Transform3D(basis, office_way + Vector3.FORWARD * 2.0)]


## Walks `member` to `to` in WALK seconds, through `via` first if given (each leg an equal share).
func _walk(member: ClubMember, to: Transform3D, via: Array[Transform3D] = []) -> void:
	var tween := member.create_tween()
	var legs: Array[Transform3D] = via.duplicate()
	legs.append(to)
	for leg in legs:
		tween.tween_property(member, "transform", leg, WALK / legs.size()).set_trans(Tween.TRANS_SINE)


func _process(delta: float) -> void:
	var just_called := false
	if multiplayer.is_server() and not is_photo():
		next_left -= delta
		if next_left <= 0.0:
			call_photo()
			just_called = true
	_track_walk()
	if is_photo() and not just_called:
		photo_left = maxf(photo_left - delta, 0.0)
		if is_counting():
			_judge_left -= delta
			if _judge_left <= 0.0:
				_judge_left = JUDGE_EVERY
				judge()
		else:
			_judge_left = JUDGE_EVERY
			_walked = 0.0
		_look_for_boss()
		if not is_photo():
			flash()
			_end()
	_flash.light_energy = maxf(_flash.light_energy - delta * 20.0, 0.0)
	_white.modulate.a = maxf(_white.modulate.a - delta * 3.0, 0.0)
	_refresh_hud()


func _track_walk() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not cop:
		return
	var at := cop.global_position
	if _last_at != Vector3.INF:
		_walked += Vector2(at.x - _last_at.x, at.z - _last_at.z).length()
	_last_at = at


## Once a second in the count: this PC's cop on the steps held still, or didn't.
func judge() -> void:
	var walked := _walked
	_walked = 0.0
	var cop := VoiceChat.local_cop(get_tree())
	if not cop or not on_steps.call(cop.global_position):
		return
	if walked <= STILL:
		good_seconds += 1
		_verdict.text = "PARTY_PHOTO_GOOD"
		return
	bad_seconds += 1
	_verdict.text = "PARTY_PHOTO_MOVED"
	_report(cop, MOVED)


## The flash, on every PC: this PC's cop in the hall but off the steps is missing from the photo.
func flash() -> void:
	if _flashed:
		return
	_flashed = true
	_click.play()
	if serpentina:
		_flash.global_position = serpentina.global_position + Vector3.UP * 1.6
	_flash.light_energy = 6.0
	var cop := VoiceChat.local_cop(get_tree())
	if cop and inside.call(cop.global_position):
		_white.modulate.a = 0.8
		if not on_steps.call(cop.global_position):
			bad_seconds += 1
			_report(cop, AWAY)
	flashed.emit()


## This PC's cop in the office while the boss counts the jewels: seen once a photo.
func _look_for_boss() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if saw_boss or not cop or not boss or not in_office.call(cop.global_position):
		return
	if not in_office.call(boss.global_position):
		return
	saw_boss = true
	cop.show_hint("HINT_PARTY_SAW_BOSS")
	if multiplayer.is_server():
		boss_seen.emit(cop)
	else:
		_saw_boss.rpc_id(_net().HOST_ID)


func _report(cop: Cop, amount: float) -> void:
	if multiplayer.is_server():
		missed.emit(cop, amount)
	else:
		_missed.rpc_id(_net().HOST_ID, amount)


@rpc("any_peer", "call_remote", "reliable")
func _missed(amount: float) -> void:
	var cop := _sender_cop()
	if cop:
		missed.emit(cop, minf(amount, AWAY))


@rpc("any_peer", "call_remote", "reliable")
func _saw_boss() -> void:
	var cop := _sender_cop()
	if cop:
		boss_seen.emit(cop)


func _sender_cop() -> Cop:
	var sync: CopSync = _net().cop_syncs.get(multiplayer.get_remote_sender_id())
	if multiplayer.is_server() and sync and is_instance_valid(sync.cop):
		return sync.cop
	return null


## The Net of this PC's multiplayer branch: the autoload in the game, each test PC's own in the online tests.
func _net() -> Node:
	var branch := multiplayer as SceneMultiplayer
	if branch and not branch.root_path.is_empty():
		var net := get_node_or_null(str(branch.root_path) + "/Net")
		if net:
			return net
	return Net


func _refresh_hud() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = is_photo() and cop != null and inside.call(cop.global_position)
	if not _hud.visible:
		return
	_cue.text = str(ceili(photo_left)) if is_counting() else "PARTY_PHOTO"
	if not on_steps.call(cop.global_position):
		_verdict.text = "PARTY_PHOTO_GO"
	elif not is_counting():
		_verdict.text = "PARTY_PHOTO_POSE"


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	_white = ColorRect.new()
	_white.color = Color.WHITE
	_white.set_anchors_preset(Control.PRESET_FULL_RECT)
	_white.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_white.modulate.a = 0.0
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-180, 120)
	box.custom_minimum_size = Vector2(360, 0)
	_cue = Label.new()
	_cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cue.add_theme_font_size_override("font_size", 40)
	box.add_child(_cue)
	_verdict = Label.new()
	_verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verdict.add_theme_font_size_override("font_size", 24)
	box.add_child(_verdict)
	_hud.add_child(box)
	_hud.hide()
	add_child(_hud)
	# The flash whitens the screen of the cops in the hall, outside the HUD so it fades on its own.
	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 50
	flash_layer.add_child(_white)
	add_child(flash_layer)


## The camera's click and whine: a short click and a rising beep.
static func click_stream() -> AudioStreamWAV:
	var samples := int(MIX_RATE * 0.3)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / MIX_RATE
		var value := 0.0
		if t < 0.03:
			value = (randf() * 2.0 - 1.0) * (1.0 - t / 0.03)
		else:
			value = sin(TAU * (1800.0 + 3000.0 * t) * t) * 0.25 * (0.3 - t) / 0.27
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 30000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	return stream
