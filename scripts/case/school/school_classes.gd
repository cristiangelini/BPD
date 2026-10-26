class_name SchoolClasses
extends Node3D

## The Profesora Ganzúa's practical classes (infiltracion-escuela.md, step 3, decision 173): 20 s in and then every
## 45 s the bell rings and, for 15 s, everyone in the classroom or the yard practices a subject, in turn. Lockpicking:
## hold E at a training lock on the yard's wall without moving. Pickpocketing: by the dummy, crouched (C) and still,
## or the bells ring. Sneaking: cross the creaky floor while the Profesora has her back turned, and freeze when she
## turns around. Each PC judges its own cop once a second and, when the class ends, gives it a grade from 1 to 10 (the
## share of good seconds; staying away from the class inside the school is the lowest) and tells the host, which keeps
## the grades (`grades`, for the graduation in step 4). A grade of LOW_GRADE or less makes the students who see that
## cop suspicious (`missed`, to ClubSuspicion). The host decides the classes and when the Profesora turns, and tells
## the guests. When the cops' average reaches GRADUATE in all three subjects (step 4), the next bell is the graduation
## instead of a class: the Director comes down with the diplomas and there are no more classes. Every number here is
## (propuesta).

signal class_started(subject: String)
signal graduation_started
signal graded(cop: Cop, subject: String, grade: int)
signal missed(cop: Cop, amount: float)

const SUBJECTS: Array[String] = ["lockpick", "pickpocket", "sneak"]
const FIRST := 20.0
## Seconds between one class's end and the next one's start, and how long a class lasts (one every 45 s).
const BREAK := 30.0
const CLASS := 15.0
## The Profesora warns this long before.
const WARNING := 5.0
const GRACE := 1.0
const JUDGE_EVERY := 1.0
## How close to a lock, and to the dummy, the practice counts (m).
const LOCK_REACH := 1.1
const DUMMY_REACH := 1.3
## Walking more than this in a second is moving (m).
const STILL := 0.3
## During sneaking, the Profesora turns around after between these many seconds (drawn with the seed).
const TURN := Vector2(2.0, 4.0)
## A grade this low makes the students who see it suspicious, by this much.
const LOW_GRADE := 3
const LOW_GRADE_SUSPICION := 25.0
## The average every subject needs for the graduation.
const GRADUATE := 7.0

## Seconds to the next class (host) and left of this one (every PC; 0: no class).
var next_left := FIRST
var class_left := 0.0
var subject := ""
var since_start := 0.0
## During sneaking, whether the Profesora is looking (every PC).
var watching := false
var case_seed := 0
## Whether a world position is in the classroom or the yard, inside the school, on the creaky floor, and near a
## training lock or the dummy (SchoolHall sets them).
var in_lesson: Callable = func(_at: Vector3) -> bool: return false
var inside: Callable = func(_at: Vector3) -> bool: return false
var on_creaky: Callable = func(_at: Vector3) -> bool: return false
var near_lock: Callable = func(_at: Vector3) -> bool: return false
var near_dummy: Callable = func(_at: Vector3) -> bool: return false
var teacher: ClubMember
## This PC's cop this class: seconds right and wrong, and its last grade.
var good_seconds := 0
var bad_seconds := 0
var last_grade := 0
## Subject -> {player (Cop.uniform) -> best grade} (the host's, copied to the guests).
var grades := {}
## The averages are good enough and the next bell is the graduation (host), and it happened (every PC).
var graduation_due := false
var graduated := false
## Tests and the debug panel can make this PC's cop hold E.
var force_using := false
var _rng := RandomNumberGenerator.new()
var _turn_left := 0.0
var _judge_left := JUDGE_EVERY
var _warned := false
var _next_subject := 0
var _walked := 0.0
var _last_at := Vector3.INF
var _bell: AudioStreamPlayer3D
var _mark: Label3D
var _hud: CanvasLayer
var _cue: Label
var _verdict: Label


func _ready() -> void:
	add_to_group("school_classes")
	_rng.seed = hash(["school classes", case_seed])
	_next_subject = _rng.randi_range(0, SUBJECTS.size() - 1)
	for kind: String in SUBJECTS:
		grades[kind] = {}
	_bell = AudioStreamPlayer3D.new()
	_bell.stream = bell_stream()
	_bell.max_distance = 40.0
	_bell.volume_db = -4.0
	add_child(_bell)
	_mark = Label3D.new()
	_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_mark.no_depth_test = true
	_mark.pixel_size = 0.006
	_mark.font_size = 48
	_mark.outline_size = 12
	_mark.modulate = Color(1, 0.85, 0.3)
	_mark.hide()
	add_child(_mark)
	_build_hud()


func in_class() -> bool:
	return class_left > 0.0


## Host: a class starts now on every PC, the next subject in turn (or this one: tests and the debug panel).
func start_class(kind := "") -> void:
	next_left = BREAK
	_warned = false
	if kind.is_empty():
		kind = SUBJECTS[_next_subject]
		_next_subject = (_next_subject + 1) % SUBJECTS.size()
	_begin(kind, CLASS)
	if kind == "sneak":
		_turn(false)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_started.rpc_id(peer, kind, class_left)


@rpc("authority", "call_remote", "reliable")
func _started(kind: String, left: float) -> void:
	if SUBJECTS.has(kind):
		_begin(kind, left)


## Every PC: the bell, the Profesora names the subject, and `left` seconds of it.
func _begin(kind: String, left: float) -> void:
	subject = kind
	class_left = left
	since_start = 0.0
	good_seconds = 0
	bad_seconds = 0
	watching = false
	_judge_left = JUDGE_EVERY
	_bell.play()
	if teacher:
		teacher.say("GANZUA_CLASS_" + subject.to_upper())
	var cop := VoiceChat.local_cop(get_tree())
	if cop and inside.call(cop.global_position):
		cop.show_hint("HINT_SCHOOL_" + subject.to_upper())
	class_started.emit(subject)


## Host: during sneaking the Profesora turns her back (or looks), on every PC.
func _turn(look: bool) -> void:
	_turn_left = _rng.randf_range(TURN.x, TURN.y)
	_set_watching(look)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_turned.rpc_id(peer, look)


@rpc("authority", "call_remote", "reliable")
func _turned(look: bool) -> void:
	_set_watching(look)


func _set_watching(look: bool) -> void:
	watching = look
	_walked = 0.0
	if teacher:
		teacher.say("GANZUA_LOOKING" if look else "GANZUA_BACK_TURNED")


func _process(delta: float) -> void:
	if teacher:
		_mark.global_position = teacher.global_position + Vector3.UP * 2.6
	if multiplayer.is_server():
		_lead(delta)
	_track_walk()
	if in_class():
		class_left = maxf(class_left - delta, 0.0)
		since_start += delta
		_judge_left -= delta
		if _judge_left <= 0.0:
			_judge_left = JUDGE_EVERY
			judge()
		if not in_class():
			finish()
	_refresh_marks()


## Host: counts down to the next class with the Profesora's warning, and turns her around during sneaking.
func _lead(delta: float) -> void:
	if graduated:
		return
	if in_class():
		if subject == "sneak":
			_turn_left -= delta
			if _turn_left <= 0.0:
				_turn(not watching)
		return
	next_left -= delta
	if next_left <= WARNING and not _warned:
		_warned = true
		if teacher:
			teacher.say("GANZUA_GRADUATION_SOON" if graduation_due else "GANZUA_BELL_SOON")
	if next_left <= 0.0:
		if graduation_due:
			start_graduation()
		else:
			start_class()


## Host: the graduation starts now on every PC.
func start_graduation() -> void:
	graduation_due = false
	_graduate()
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_graduated.rpc_id(peer)


@rpc("authority", "call_remote", "reliable")
func _graduated() -> void:
	_graduate()


## Every PC: the bell, the Profesora announces it and the Director comes down (SchoolHall); no more classes.
func _graduate() -> void:
	if graduated:
		return
	graduated = true
	class_left = 0.0
	_bell.play()
	if teacher:
		teacher.say("GANZUA_GRADUATION")
	graduation_started.emit()


func _track_walk() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not cop:
		return
	var at := cop.global_position
	if _last_at != Vector3.INF:
		_walked += Vector2(at.x - _last_at.x, at.z - _last_at.z).length()
	_last_at = at


## Whether this PC's player holds E.
func is_using() -> bool:
	return force_using or Input.is_action_pressed("use")


## What this PC's cop did this second of the class: "good", "bad" (with the verdict's key) or "" (nothing counts).
func verdict(cop: Cop, walked: float) -> String:
	if not in_lesson.call(cop.global_position):
		return "SCHOOL_NOT_IN_CLASS"
	match subject:
		"lockpick":
			if not near_lock.call(cop.global_position):
				return "SCHOOL_GO_TO_LOCK"
			if walked > STILL or not is_using():
				return "SCHOOL_NOT_PICKING"
		"pickpocket":
			if not near_dummy.call(cop.global_position):
				return "SCHOOL_GO_TO_DUMMY"
			if not cop.is_crouching or walked > STILL:
				return "SCHOOL_BELLS"
		"sneak":
			if not on_creaky.call(cop.global_position):
				return "SCHOOL_GO_TO_FLOOR"
			if watching and walked > STILL:
				return "SCHOOL_SEEN_MOVING"
			if not watching and walked <= STILL:
				return ""
	return "good"


## Once a second during a class: this PC's cop in the school did the practice, or didn't.
func judge() -> void:
	var walked := _walked
	_walked = 0.0
	var cop := VoiceChat.local_cop(get_tree())
	if not cop or not in_class() or since_start < GRACE or not inside.call(cop.global_position):
		return
	var said := verdict(cop, walked)
	if said == "good":
		good_seconds += 1
		_verdict.text = "SCHOOL_GOOD"
	elif not said.is_empty():
		bad_seconds += 1
		_verdict.text = said


## The class is over: this PC's cop gets its grade, if it was in the school, and the host hears it.
func finish() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not cop or not inside.call(cop.global_position):
		return
	last_grade = grade_of(good_seconds, bad_seconds)
	cop.show_hint(tr("SCHOOL_YOUR_GRADE") % last_grade)
	if multiplayer.is_server():
		record(cop, subject, last_grade)
	else:
		_graded.rpc_id(_net().HOST_ID, subject, last_grade)


## From 1 to 10: the share of good seconds; no good second at all is the lowest.
static func grade_of(good: int, bad: int) -> int:
	if good + bad == 0:
		return 1
	return clampi(1 + roundi(9.0 * good / (good + bad)), 1, 10)


## Host: keeps `cop`'s grade (its best in that subject) and a low one raises the students who see it.
func record(cop: Cop, kind: String, grade: int) -> void:
	var of_subject: Dictionary = grades[kind]
	of_subject[cop.uniform] = maxi(of_subject.get(cop.uniform, 0), grade)
	graded.emit(cop, kind, grade)
	if grade <= LOW_GRADE:
		missed.emit(cop, LOW_GRADE_SUSPICION)
	if not graduated and ready_to_graduate():
		graduation_due = true
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_grades_now.rpc_id(peer, grades)


## Guests: the host's grades, for the report card.
@rpc("authority", "call_remote", "reliable")
func _grades_now(all: Dictionary) -> void:
	for kind: String in SUBJECTS:
		grades[kind] = all.get(kind, {})


## Whether the cops' average is at least GRADUATE in every subject.
func ready_to_graduate() -> bool:
	return SUBJECTS.all(func(kind: String) -> bool: return average(kind) >= GRADUATE)


@rpc("any_peer", "call_remote", "reliable")
func _graded(kind: String, grade: int) -> void:
	var sync: CopSync = _net().cop_syncs.get(multiplayer.get_remote_sender_id())
	if multiplayer.is_server() and sync and is_instance_valid(sync.cop) and SUBJECTS.has(kind):
		record(sync.cop, kind, clampi(grade, 1, 10))


## The cops' average in `kind`, of each one's best grade (0 with no grade yet).
func average(kind: String) -> float:
	var of_subject: Dictionary = grades.get(kind, {})
	if of_subject.is_empty():
		return 0.0
	var total := 0
	for grade: int in of_subject.values():
		total += grade
	return float(total) / of_subject.size()


## The Net of this PC's multiplayer branch: the autoload in the game, each test PC's own in the online tests.
func _net() -> Node:
	var branch := multiplayer as SceneMultiplayer
	if branch and not branch.root_path.is_empty():
		var net := get_node_or_null(str(branch.root_path) + "/Net")
		if net:
			return net
	return Net


func _refresh_marks() -> void:
	_mark.visible = in_class()
	_mark.text = "SCHOOL_CLASS_" + subject.to_upper()
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = in_class() and cop != null and inside.call(cop.global_position)
	if not _hud.visible:
		return
	_cue.text = "%s  %d" % [tr(_mark.text), ceili(class_left)]
	if subject == "sneak":
		_cue.text += "  " + tr("SCHOOL_LOOKING" if watching else "SCHOOL_BACK_TURNED")
	if since_start < GRACE:
		_verdict.text = "SCHOOL_HOW_" + subject.to_upper()


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-240, 120)
	box.custom_minimum_size = Vector2(480, 0)
	_cue = Label.new()
	_cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cue.add_theme_font_size_override("font_size", 36)
	box.add_child(_cue)
	_verdict = Label.new()
	_verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verdict.add_theme_font_size_override("font_size", 24)
	box.add_child(_verdict)
	_hud.add_child(box)
	_hud.hide()
	add_child(_hud)


## The school bell: two short rings.
static func bell_stream() -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * 0.6)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / rate
		var ring := 1.0 if fmod(t, 0.3) < 0.22 else 0.0
		var value := (sin(TAU * 1250.0 * t) + 0.5 * sin(TAU * 2500.0 * t)) * 0.35 * ring * (1.0 - t / 0.6)
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 30000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream
