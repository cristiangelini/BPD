class_name TvDebate
extends Node

## The live debate (politico-debate.md, step 3, decision 230), the clock of the case: everyone waits at their places
## until the first cop walks into the studio, then 3 blocks of BLOCK seconds with BREAK seconds of ads between them.
## Each block is 2 questions: the moderator asks (ASK seconds) and each candidate answers for ANSWER seconds, Lustre
## first on the odd questions and Malvón on the even ones. The control room puts on air the camera of whoever speaks.
## Lustre's image starts at IMAGE_START: each answer of his without a blunder (step 4) adds ANSWER_GAIN, each answer of
## Malvón's takes MALVON_GAIN off it, and each blunder takes BLUNDER. Time and image show at the top of the screen.
## `finished` at the end of the third block. Every number here is (propuesta).

signal started
signal speaking(who: String)
signal ad_break
signal finished
signal blundered(kind: String)

enum State { WAITING, BLOCK, BREAK, OVER }

const BLOCKS := 3
const BLOCK := 90.0
const BREAK := 10.0
const ASK := 5.0
const ANSWER := 20.0
const QUESTIONS := 6
const IMAGE_START := 50
const ANSWER_GAIN := 6
const MALVON_GAIN := 3
const BLUNDER := 8
## Which camera shoots whom (TvStudio.CAMERAS).
const CAMERA_OF := {"malvon": 0, "moderator": 1, "lustre": 2}

var studio: TvStudio
var politician: Politician
var malvon: RallyFan
var moderator: RallyFan
var state := State.WAITING
## The block on now (1 to BLOCKS) and the seconds left in it (or in the break).
var block := 0
var left := BLOCK
var image := IMAGE_START
## Who has the word: "moderator", "lustre", "malvon" or "" (nobody, before or after, or in the break).
var speaker := ""
## The question being answered, from 0.
var question := -1
var blunders := 0
## Online, a guest's: the host's runs the clock.
var follower := false
var _blunder_in_turn := false
var _clock: Label


func setup(the_studio: TvStudio, the_politician: Politician, the_malvon: RallyFan, the_moderator: RallyFan) -> void:
	studio = the_studio
	politician = the_politician
	malvon = the_malvon
	moderator = the_moderator


func _ready() -> void:
	var hud := CanvasLayer.new()
	hud.name = "ClockHud"
	_clock = Label.new()
	_clock.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_clock.offset_top = 50.0
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clock.add_theme_constant_override("outline_size", 6)
	hud.add_child(_clock)
	add_child(hud)


func start() -> void:
	if state != State.WAITING:
		return
	state = State.BLOCK
	block = 1
	left = BLOCK
	started.emit()
	_follow_the_time()


## A blunder on air (step 4): the image drops, and Lustre's answer under way earns nothing.
func blunder(kind: String) -> void:
	if state != State.BLOCK:
		return
	blunders += 1
	_blunder_in_turn = true
	_add(-BLUNDER)
	blundered.emit(kind)


func _add(points: int) -> void:
	image = clampi(image + points, 0, 100)


func _physics_process(delta: float) -> void:
	_show()
	if follower:
		return
	match state:
		State.WAITING:
			for cop: Node3D in get_tree().get_nodes_in_group("cops"):
				if studio.in_studio(cop.global_position):
					start()
					return
		State.BLOCK:
			left -= delta
			if left <= 0.0:
				_end_block()
			else:
				_follow_the_time()
		State.BREAK:
			left -= delta
			if left <= 0.0:
				state = State.BLOCK
				block += 1
				left = BLOCK
				_follow_the_time()


## Who should have the word at this point of the block; a change of turn closes the one before.
func _follow_the_time() -> void:
	var played := BLOCK - left
	var cycle := ASK + ANSWER * 2
	var in_block := mini(floori(played / cycle), roundi(BLOCK / cycle) - 1)
	var at := played - in_block * cycle
	var now_question := (block - 1) * roundi(BLOCK / cycle) + in_block
	var lustre_first := now_question % 2 == 0
	var who := "moderator"
	if at >= ASK + ANSWER:
		who = "malvon" if lustre_first else "lustre"
	elif at >= ASK:
		who = "lustre" if lustre_first else "malvon"
	if who != speaker or now_question != question:
		_close_turn()
		question = now_question
		_open_turn(who)


func _open_turn(who: String) -> void:
	speaker = who
	_blunder_in_turn = false
	studio.put_on_air(CAMERA_OF[who])
	var line := question % QUESTIONS + 1
	match who:
		"moderator":
			moderator.say("TV_QUESTION_%d" % line)
		"lustre":
			politician.say("TV_LUSTRE_ANSWER_%d" % line, ANSWER)
		"malvon":
			malvon.say("TV_MALVON_ANSWER_%d" % line)
			_add(-MALVON_GAIN)
	speaking.emit(who)


## The turn that ends: a clean answer of Lustre's earns its points.
func _close_turn() -> void:
	if speaker == "lustre" and not _blunder_in_turn:
		_add(ANSWER_GAIN)
	speaker = ""


func _end_block() -> void:
	_close_turn()
	if block < BLOCKS:
		state = State.BREAK
		left = BREAK
		studio.put_on_air(CAMERA_OF.moderator)
		ad_break.emit()
		for cop in get_tree().get_nodes_in_group("cops"):
			(cop as Cop).show_hint("HINT_DEBATE_BREAK")
	else:
		state = State.OVER
		left = 0.0
		finished.emit()


func _show() -> void:
	if _clock == null:
		return
	match state:
		State.WAITING:
			_clock.text = "HUD_DEBATE_WAITING"
		State.BREAK:
			_clock.text = tr("HUD_DEBATE_BREAK") % [ceili(maxf(left, 0.0)), image]
		State.OVER:
			_clock.text = tr("HUD_DEBATE_OVER") % image
		_:
			var seconds := ceili(maxf(left, 0.0))
			_clock.text = tr("HUD_DEBATE_CLOCK") % [block, BLOCKS, seconds / 60, seconds % 60, image]
