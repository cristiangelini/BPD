class_name TalentPlan
extends Node

## The prison's talent show (carcel-talentos.md, step 2): in the west half of the canteen, the stage against the back
## wall, the jury table with its 4 chairs in front of it and 3 benches with the 12 inmates sat watching; the host up
## on the stage. The seed draws the show: always the magician, the choir and the smoke dance (the ones hiding an
## escape, step 5) and 2 of the 5 acts without a trick, in its own order. Step 3: the show starts when the first cop
## walks into the canteen. The host welcomes everyone, and for each act: announces it with the curtain closed, opens
## it for ACT_TIME (the act's performers up front, saying their lines), and asks the jury for their scores for
## VOTE_TIME, with the cards up of every cop sat at the jury table; then the curtain closes for BREAK_TIME. After the
## last one the host names the winner (the most points; with a tie, the later act). Step 4: a vote with nobody at the
## jury table offends the audience: ANGRY of them stand up booing and throw food at the cops for FIGHT_TIME (or until
## every one of them is calmed with E). Every number here is (propuesta).

signal show_started
signal act_started(index: int)
## `seated`: how many cops were at the jury table; `points`: their cards added up.
signal voted(index: int, seated: int, points: int)
signal show_ended(winner: int)
signal fight_started
signal fight_ended

enum Phase { WAITING, INTRO, ANNOUNCE, ACT, VOTE, BREAK, OVER }

const ACTS: Array[String] = ["magician", "choir", "smoke", "juggler", "ventriloquist", "plates", "spoons", "poet"]
## The acts that hide an escape (step 5); the others are only suspicious.
const TRICKS: Array[String] = ["magician", "choir", "smoke"]
const SHOW := 5
## Level space (x, z): the middle of the stage's front edge, the jury table and the benches.
const STAGE_AT := Vector2(-7.0, -4.5)
const JURY_AT := Vector2(-7.0, -3.4)
const JURY_SIZE := Vector3(3.6, 0.75, 0.7)
const CHAIR_XS: Array[float] = [-8.35, -7.45, -6.55, -5.65]
const CHAIR_BEHIND := 0.6
const BENCH_ZS: Array[float] = [-1.6, -0.2, 1.2]
const BENCH_SIZE := Vector3(5.2, 0.4, 0.35)
const SEAT_XS: Array[float] = [-8.8, -7.6, -6.4, -5.2]
const INMATES := 12
const INTRO_TIME := 6.0
const ANNOUNCE_TIME := 4.0
const ACT_TIME := 60.0
const VOTE_TIME := 5.0
const BREAK_TIME := 15.0
const LINE_EVERY := 8.0
const CHOIR := 3
## Where the performers stand on the stage (metres east of its middle, back from its front edge), and backstage.
const PERFORM_BACK := 0.6
const BACKSTAGE_BACK := 2.0
const HOST_ASIDE := Vector2(-2.3, 0.5)
const ANGRY := 6
const FIGHT_TIME := 20.0
const THROW_EVERY := 3.0
const THROW_JITTER := 1.0
const WOOD := Color(0.45, 0.3, 0.18)
const CLOTH := Color(0.2, 0.35, 0.25)

var prison: PrisonLevel
var stage: TalentStage
var chairs: Array[JuryChair] = []
var inmates: Array[TalentInmate] = []
var host: TalentInmate
## The 5 acts of the show, in order, and who's in each (the choir is three).
var acts: Array[String] = []
var performers := {}
var phase := Phase.WAITING
var act_now := -1
var phase_left := 0.0
## Each act's points from the jury's cards and whether anyone was at the table when the host asked.
var points: Array[int] = []
var voted_ok: Array[bool] = []
var winner := -1
## The audience's food fight (step 4): seconds left (0: none on) and how many there were.
var fight_left := 0.0
var fights := 0
var _throw_left := {}
var _line_left := 0.0
## A guest's copy (step 7): the host's plan decides.
var follower := false
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["prison talent", case_seed])
	acts.assign(TRICKS)
	var others := ACTS.filter(func(act: String) -> bool: return not TRICKS.has(act))
	_shuffle(others)
	acts.append_array(others.slice(0, SHOW - TRICKS.size()))
	_shuffle(acts)
	stage = TalentStage.new()
	stage.name = "TalentStage"
	stage.position = _at(STAGE_AT)
	prison.add_child(stage)
	stage.set_curtain(false, true)
	var jury := StaticBody3D.new()
	jury.name = "JuryTable"
	jury.position = _at(JURY_AT)
	prison.add_child(jury)
	var top := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = JURY_SIZE
	top.shape = box
	top.position.y = JURY_SIZE.y / 2
	jury.add_child(top)
	jury.add_child(CopTool.piece(CopTool.box(JURY_SIZE), CLOTH, Vector3(0, JURY_SIZE.y / 2, 0)))
	for x in CHAIR_XS:
		var chair := JuryChair.new()
		chair.name = "JuryChair%d" % chairs.size()
		chair.position = _at(Vector2(x, JURY_AT.y + CHAIR_BEHIND))
		prison.add_child(chair)
		chairs.append(chair)
	for z in BENCH_ZS:
		var bench := StaticBody3D.new()
		bench.name = "Bench%d" % BENCH_ZS.find(z)
		bench.position = _at(Vector2(STAGE_AT.x, z))
		prison.add_child(bench)
		var seat := CollisionShape3D.new()
		var seat_box := BoxShape3D.new()
		seat_box.size = BENCH_SIZE
		seat.shape = seat_box
		seat.position.y = BENCH_SIZE.y / 2
		bench.add_child(seat)
		bench.add_child(CopTool.piece(CopTool.box(BENCH_SIZE), WOOD, Vector3(0, BENCH_SIZE.y / 2, 0)))
	for i in INMATES:
		var inmate := TalentInmate.new()
		inmate.name = "Inmate%d" % i
		inmate.seated = true
		add_child(inmate)
		# Just behind the bench's middle, so the body doesn't stand on it.
		var row := i / SEAT_XS.size()
		inmate.global_position = prison.global_transform * Vector3(SEAT_XS[i % SEAT_XS.size()],
			PrisonLevel.FLOOR_TOP, BENCH_ZS[row] + BENCH_SIZE.z / 2 + 0.05)
		inmate.face(stage.global_position)
		inmate.calmed.connect(_on_calmed.unbind(1))
		inmates.append(inmate)
	for act in acts:
		var group: Array[TalentInmate] = []
		for i in (CHOIR if act == "choir" else 1):
			var performer := TalentInmate.new()
			performer.name = "Performer_%s%d" % [act, i]
			performer.role = TalentInmate.Role.PERFORMER
			performer.act = act
			add_child(performer)
			performer.global_position = stage.spot((i - (CHOIR - 1) / 2.0) * 1.0 if act == "choir" else 0.0,
				BACKSTAGE_BACK)
			performer.face(performer.global_position + prison.global_basis.z)
			performer.set_on_stage(false)
			group.append(performer)
		performers[act] = group
	host = TalentInmate.new()
	host.name = "Host"
	host.role = TalentInmate.Role.HOST
	add_child(host)
	host.global_position = stage.spot(-1.8, 0.5)
	host.face(host.global_position + prison.global_basis.z)


## Showtime: the host's welcome.
func start() -> void:
	if phase != Phase.WAITING:
		return
	_enter(Phase.INTRO)
	host.say("TALENT_HELLO", INTRO_TIME)
	show_started.emit()


func act_name(index: int) -> String:
	return acts[index] if index >= 0 and index < acts.size() else ""


## Who's up on the stage now.
func on_stage() -> Array[TalentInmate]:
	var list: Array[TalentInmate] = []
	if act_now >= 0 and (phase == Phase.ACT or phase == Phase.VOTE):
		list.assign(performers[acts[act_now]])
	return list


func is_over() -> bool:
	return phase == Phase.OVER


func _enter(next: Phase) -> void:
	phase = next
	match next:
		Phase.INTRO:
			phase_left = INTRO_TIME
		Phase.ANNOUNCE:
			phase_left = ANNOUNCE_TIME
			act_now += 1
			stage.set_curtain(false)
			host.global_position = stage.spot(0.0, PERFORM_BACK)
			host.say("TALENT_ANNOUNCE_%s" % acts[act_now].to_upper(), ANNOUNCE_TIME)
		Phase.ACT:
			phase_left = ACT_TIME
			_line_left = 0.0
			host.global_position = stage.spot(HOST_ASIDE.x, HOST_ASIDE.y)
			stage.set_curtain(true)
			var group: Array = performers[acts[act_now]]
			for i in group.size():
				var performer: TalentInmate = group[i]
				performer.global_position = stage.spot((i - (group.size() - 1) / 2.0) * 1.0, PERFORM_BACK)
				performer.set_on_stage(true)
			act_started.emit(act_now)
		Phase.VOTE:
			phase_left = VOTE_TIME
			host.say("TALENT_VOTE", VOTE_TIME)
			for inmate in inmates:
				inmate.cheer()
			for chair in chairs:
				chair.set_raised(chair.sitter != null)
		Phase.BREAK:
			phase_left = BREAK_TIME
			_count_vote()
			for performer: TalentInmate in performers[acts[act_now]]:
				performer.set_on_stage(false)
			stage.set_curtain(false)
			if fight_left <= 0.0:
				host.say("TALENT_THANKS", 3.0)
		Phase.OVER:
			_count_vote()
			for performer: TalentInmate in performers[acts[act_now]]:
				performer.set_on_stage(false)
			winner = 0
			for i in points.size():
				if points[i] >= points[winner]:
					winner = i
			# The curtain stays open: the winner comes out, the host to one side.
			host.global_position = stage.spot(HOST_ASIDE.x, HOST_ASIDE.y)
			host.say(tr("TALENT_WINNER") % tr("TALENT_ACT_%s" % acts[winner].to_upper()), 10.0)
			var group: Array = performers[acts[winner]]
			for i in group.size():
				var performer: TalentInmate = group[i]
				performer.global_position = stage.spot((i - (group.size() - 1) / 2.0) * 1.0, PERFORM_BACK)
				performer.set_on_stage(true)
				performer.say("TALENT_TEARS", 10.0)
			show_ended.emit(winner)


## The cards up when the host asked: added up, and back down on the table.
func _count_vote() -> void:
	var seated := 0
	var total := 0
	for chair in chairs:
		if chair.raised:
			seated += 1
			total += chair.score
		chair.set_raised(false)
	points.append(total)
	voted_ok.append(seated > 0)
	voted.emit(act_now, seated, total)
	if seated == 0:
		_start_fight()


## Nobody voted: the audience is offended and the food flies.
func _start_fight() -> void:
	if fight_left > 0.0:
		return
	fight_left = FIGHT_TIME
	fights += 1
	host.say("TALENT_OFFENDED", 4.0)
	var order := range(inmates.size())
	_shuffle(order)
	for i: int in order.slice(0, ANGRY):
		inmates[i].set_angry(true)
		_throw_left[inmates[i]] = _rng.randf_range(0.5, THROW_EVERY)
	fight_started.emit()


func angry_ones() -> Array[TalentInmate]:
	var list: Array[TalentInmate] = []
	list.assign(inmates.filter(func(inmate: TalentInmate) -> bool: return inmate.angry))
	return list


func _on_calmed() -> void:
	if fight_left > 0.0 and angry_ones().is_empty():
		_end_fight()


func _end_fight() -> void:
	fight_left = 0.0
	for inmate in angry_ones():
		inmate.set_angry(false)
	_throw_left.clear()
	fight_ended.emit()


## Every angry one throws at the closest cop in the canteen, now and then.
func _fight(delta: float) -> void:
	fight_left -= delta
	if fight_left <= 0.0:
		_end_fight()
		return
	var cops := get_tree().get_nodes_in_group("cops").filter(func(cop: Cop) -> bool:
		return in_canteen(cop.global_position))
	for inmate in angry_ones():
		_throw_left[inmate] = _throw_left.get(inmate, THROW_EVERY) - delta
		if _throw_left[inmate] > 0.0 or cops.is_empty():
			continue
		_throw_left[inmate] = THROW_EVERY + _rng.randf_range(-THROW_JITTER, THROW_JITTER)
		var target: Cop = cops[0]
		for cop: Cop in cops:
			if cop.global_position.distance_to(inmate.global_position) \
					< target.global_position.distance_to(inmate.global_position):
				target = cop
		var miss := Vector3(_rng.randf_range(-1, 1), _rng.randf_range(-0.5, 0.5), _rng.randf_range(-1, 1)) \
			* TalentInmate.MISS
		inmate.throw_at(target.global_position + Vector3.UP * TalentInmate.CHEST + miss,
			TalentInmate.FOODS[_rng.randi_range(0, TalentInmate.FOODS.size() - 1)])


## Whether a world position is in the canteen (the building's front room, west of the kitchen).
func in_canteen(at: Vector3) -> bool:
	var local := prison.global_transform.affine_inverse() * at
	return local.z > PrisonLevel.CELLS_Z and local.z < PrisonLevel.BUILDING_FRONT \
		and local.x > -PrisonLevel.BUILDING_X and local.x < PrisonLevel.KITCHEN_X


func _physics_process(delta: float) -> void:
	if follower:
		return
	if fight_left > 0.0:
		_fight(delta)
	if phase == Phase.OVER:
		return
	if phase == Phase.WAITING:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if in_canteen(cop.global_position):
				start()
				return
		return
	if phase == Phase.ACT:
		_line_left -= delta
		if _line_left <= 0.0:
			_line_left = LINE_EVERY
			var group: Array = performers[acts[act_now]]
			(group[randi() % group.size()] as TalentInmate).say("TALENT_LINE_%s" % acts[act_now].to_upper())
	elif phase == Phase.VOTE:
		# A cop who sits down while the host waits gets their card up too.
		for chair in chairs:
			if chair.sitter and not chair.raised:
				chair.set_raised(true)
	phase_left -= delta
	if phase_left > 0.0:
		return
	match phase:
		Phase.INTRO, Phase.BREAK:
			_enter(Phase.ANNOUNCE)
		Phase.ANNOUNCE:
			_enter(Phase.ACT)
		Phase.ACT:
			_enter(Phase.VOTE)
		Phase.VOTE:
			_enter(Phase.OVER if act_now == acts.size() - 1 else Phase.BREAK)


## How many cops are sat at the jury table.
func jury_seated() -> int:
	return chairs.filter(func(chair: JuryChair) -> bool: return chair.sitter != null).size()


func _at(at: Vector2) -> Vector3:
	return Vector3(at.x, PrisonLevel.FLOOR_TOP, at.y)


func _shuffle(list: Array) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = list[i]
		list[i] = list[j]
		list[j] = swap
