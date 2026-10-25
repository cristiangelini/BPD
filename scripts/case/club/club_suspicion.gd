class_name ClubSuspicion
extends Node3D

## The grandparents' suspicion at the club (infiltracion.md, step 4): each grandparent at the tables has a meter, like
## the jailbreak's guard (NightGuard.sees). What a grandparent sees in a cop raises it every second: no disguise,
## running, a tool in hand, being in the back rooms,
## sitting out the waltz (ClubDance). At the chapel (infiltracion-coro.md, step 4) the choristers watch the same way,
## for the robe instead of the grandparent disguise, and hear the cops sing out of time (ChoirSinging); at the theater
## (infiltracion-mimos.md, step 4) the mimes see the cops rehearse wrong (MimeRehearsal). Some things raise it at once: a disguise piece falling where they
## see it, a bad step in the waltz, a bingo number left unmarked (the neighbor at the table, ClubBingo.missed) and a shout nearby. At 50 a "?"
## shows over their head and at 80 a "!"; at 100 they shout "¡Son policías!" and everyone knows (`discovered`; the
## chase comes in step 6). It calms down when they see nothing. The host decides; online the guests follow its state
## (NpcSync). Every number here is (propuesta).

signal discovered(by: ClubMember)

## Per second, for each cop a grandparent sees doing it.
const UNDISGUISED := 30.0
const RUNNING := 35.0
const TOOL_OUT := 25.0
const BACK_ROOM := 40.0
## While the waltz plays, off the dance floor (step 5); or while the choir sings, off the platform.
const SITTING_OUT := 20.0
## The choristers this close hear a cop singing out of time, wherever they look.
const HEAR_RANGE := 5.0
const CALM := 5.0
## At once.
const DISGUISE_FELL := 30.0
const BINGO_MISS := 20.0
const BINGO_MISS_NEAR := 10.0
const BINGO_NEAR := 3.0
const SHOUT := 25.0
## A bad step in the waltz, to the grandparents who see it.
const STUMBLE := 10.0
const SHOUT_RANGE := 10.0
## A cop counts as running above this speed (between walking and running).
const RUN_SPEED := (GameScale.WALK_SPEED + GameScale.RUN_SPEED) / 2
const FOUND_OUT_LINES := 3

var members: Array[ClubMember] = []
var boss: ClubMember
## What the boss shouts when they find the cops out.
var boss_found_out := "CHELA_FOUND_OUT"
## Who the cops have to pass for (DisguisePiece.LOOKS), and the start of the texts: <prefix>FOUND_OUT_<n>,
## HINT_<prefix>FOUND_OUT and HUD_<prefix>SUSPICION. Set before it's added.
var disguise_look := "grandparent"
var prefix := "CLUB_"
## The choir's songs, if the place has them.
var singing: ChoirSinging
## The waltz, if the club has one.
var dance: ClubDance
## The mimes' rehearsal, if the place has one.
var rehearsal: MimeRehearsal
## Whether a world position is inside the club, and in its back rooms (GrandpaClub sets them).
var inside: Callable = func(_at: Vector3) -> bool: return false
var in_back_room: Callable = func(_at: Vector3) -> bool: return false
var found_out := false
## Who shouted it, as an index of `members` (-1: nobody yet).
var found_by := -1
var _last_at := {}
var _last_pieces := {}
var _hud: CanvasLayer
var _bar: ProgressBar


func _ready() -> void:
	add_to_group("club_suspicion")
	_build_hud()


## Connects the bingo's misses (GrandpaClub calls it).
func watch_bingo(bingo: ClubBingo) -> void:
	bingo.missed.connect(_on_bingo_missed)


## Connects the waltz's bad steps (GrandpaClub calls it).
func watch_dance(waltz: ClubDance) -> void:
	dance = waltz
	dance.stumbled.connect(_on_stumbled)


## Connects the choir's out-of-time singing (ChurchChoir calls it).
func watch_singing(songs: ChoirSinging) -> void:
	singing = songs
	singing.missed.connect(_on_sang_wrong)


## Connects the mimes' rehearsal done wrong (MimeTheater calls it).
func watch_rehearsal(mimes: MimeRehearsal) -> void:
	rehearsal = mimes
	rehearsal.missed.connect(_on_mimed_wrong)


func _on_mimed_wrong(cop: Cop, amount: float) -> void:
	for member in members:
		if member.sees_cop(cop):
			raise(member, amount)


func _on_sang_wrong(cop: Cop, amount: float) -> void:
	for member in members:
		if member.global_position.distance_to(cop.global_position) <= HEAR_RANGE:
			raise(member, amount)


func _on_stumbled(cop: Cop) -> void:
	for member in members:
		if member.sees_cop(cop):
			raise(member, STUMBLE)


func highest() -> float:
	var top := 0.0
	for member in members:
		top = maxf(top, member.suspicion)
	return top


func _physics_process(delta: float) -> void:
	var cops: Array = get_tree().get_nodes_in_group("cops")
	var speeds := {}
	for cop: Cop in cops:
		var at := cop.global_position
		var last: Vector3 = _last_at.get(cop, at)
		speeds[cop] = Vector2(at.x - last.x, at.z - last.z).length() / maxf(delta, 0.001)
		_last_at[cop] = at
	if found_out:
		return
	for cop: Cop in cops:
		var pieces := cop.disguise.size()
		if pieces < _last_pieces.get(cop, pieces) and inside.call(cop.global_position):
			for member in members:
				if member.sees_cop(cop):
					raise(member, DISGUISE_FELL)
		_last_pieces[cop] = pieces
	for member in members:
		var rate := 0.0
		for cop: Cop in cops:
			if cop.vehicle or not inside.call(cop.global_position) or not member.sees_cop(cop):
				continue
			rate += offence(cop, speeds.get(cop, 0.0))
		raise(member, (rate if rate > 0.0 else -CALM) * delta)
		if found_out:
			return


## What a grandparent seeing `cop` (moving at `speed`) adds per second.
func offence(cop: Cop, speed: float) -> float:
	var rate := 0.0
	if not cop.is_disguised(disguise_look):
		rate += UNDISGUISED
	if speed > RUN_SPEED:
		rate += RUNNING
	if cop.belt and cop.belt.held_tool():
		rate += TOOL_OUT
	if in_back_room.call(cop.global_position):
		rate += BACK_ROOM
	if dance and dance.is_waltz() and not dance.on_floor.call(cop.global_position):
		rate += SITTING_OUT
	if singing and singing.is_song() and not singing.on_platform.call(cop.global_position):
		rate += SITTING_OUT
	if rehearsal and rehearsal.is_rehearsal() and not rehearsal.on_stage.call(cop.global_position):
		rate += SITTING_OUT
	return rate


func raise(member: ClubMember, amount: float) -> void:
	if found_out:
		return
	member.set_suspicion(clampf(member.suspicion + amount, 0.0, 100.0))
	if member.suspicion >= 100.0:
		_find_out(members.find(member))


## A cop shouted into the microphone (VoiceChat, on the host): the grandparents near it hear it.
func shouted_by(cop: Node3D) -> void:
	for member in members:
		if member.global_position.distance_to(cop.global_position) <= SHOUT_RANGE:
			raise(member, SHOUT)


func _on_bingo_missed(card: ClubBingoCard) -> void:
	if not multiplayer.is_server():
		return
	var nearest: ClubMember = null
	for member in members:
		var away := member.global_position.distance_to(card.global_position)
		if not nearest or away < nearest.global_position.distance_to(card.global_position):
			nearest = member
	for member in members:
		if member == nearest:
			raise(member, BINGO_MISS)
		elif member.global_position.distance_to(card.global_position) <= BINGO_NEAR:
			raise(member, BINGO_MISS_NEAR)


func _find_out(index: int) -> void:
	found_out = true
	found_by = index
	var by: ClubMember = members[index] if index >= 0 and index < members.size() else null
	if by:
		by.say(prefix + "FOUND_OUT_%d" % (index % FOUND_OUT_LINES))
	if boss:
		boss.say(boss_found_out)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.input_enabled:
			cop.show_hint("HINT_" + prefix + "FOUND_OUT")
	discovered.emit(by)


func _process(_delta: float) -> void:
	_refresh_hud()


## This PC's bar: the most suspicious grandparent, while its cop is inside.
func _refresh_hud() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = cop != null and inside.call(cop.global_position) and highest() > 0.0
	_bar.value = highest()


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	box.position = Vector2(-120, 16)
	box.custom_minimum_size = Vector2(240, 0)
	var title := Label.new()
	title.text = "HUD_" + prefix + "SUSPICION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(240, 14)
	_bar.show_percentage = false
	_bar.modulate = Color(1, 0.45, 0.3)
	box.add_child(_bar)
	_hud.add_child(box)
	_hud.hide()
	add_child(_hud)


## Online: what the guests need (NpcSync): every grandparent's meter and whether they found out.
func net_state() -> Array:
	return [members.map(func(member: ClubMember) -> float: return member.suspicion), found_out, found_by]


func apply_net_state(state: Array) -> void:
	for i in mini(members.size(), state[0].size()):
		members[i].set_suspicion(state[0][i])
	if state[1] and not found_out:
		_find_out(state[2])
	_refresh_hud()
