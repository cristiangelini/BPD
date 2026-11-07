class_name PartyKid
extends ClubMember

## A kid at Tomasito's birthday (docs/diseno/allanamiento-cumple.md, step 3). Guests run about the hall from spot to
## spot; one who gets close to a cop hangs on their leg ("¡Llévame en el patrullero!") and the cop walks at half speed
## for HANG_TIME seconds; one who finds something small lying on the floor carries it off to the bouncy castle until
## they get bored, or until a cop gives them one of Chispita's balloons for it. A cop running into a kid makes them
## cry, and so does the cake falling. When the piñata breaks they sit on the floor under it picking up candies.
## Tomasito doesn't run about: he waits by the piñata for whoever breaks it. Positions are in the party's space.
## Every number here is (propuesta).

signal cried(kid: PartyKid)

enum State { WANDER, HANG, CARRY, CRY, CANDY }

const SPEED := 1.4
const ARRIVED := 0.3
const HANG_REACH := 0.9
const HANG_TIME := 5.0
const HANG_SLOW := 0.5
## After letting go, a kid won't hang on anyone again for a while.
const HANG_REST := 12.0
const GRAB_REACH := 0.8
const SMALL_KG := 1.0
## Something on the floor: lower than this over the hall's floor.
const ON_FLOOR := 0.35
const BORED := 30.0
const CRY_TIME := 10.0
const CANDY_TIME := 10.0
## A cop this close going faster than this knocks the kid over.
const PUSH_REACH := 0.75
const PUSH_SPEED := GameScale.WALK_SPEED + 0.5
## Where the carried thing rides, and where the kid hangs on a cop's leg (in the cop's space).
const HAND := Vector3(0, 0.6, -0.35)
const ON_LEG := Vector3(0.35, -0.85, 0.1)

var party: BirthdayRaid
var wanders := true
var state := State.WANDER
## The cop the kid hangs on, and the thing they carry.
var hanging_on: Cop
var carrying: Grabbable
var _left := 0.0
var _rest := 0.0
var _target := Vector3.INF
var _rng := RandomNumberGenerator.new()


func setup(the_party: BirthdayRaid, seed_value: int) -> void:
	party = the_party
	_rng.seed = seed_value


func prompt_key(cop: Cop) -> String:
	if carrying and party and party.has_balloon(cop):
		return "PROMPT_GIVE_BALLOON"
	return super.prompt_key(cop)


func use(cop: Cop) -> void:
	if carrying and party and party.has_balloon(cop):
		party.take_balloon(cop)
		_drop()
		say("BIRTHDAY_KID_THANKS")
		return
	if look == "tomasito" and party and party.tomasito_talks(cop):
		return
	super.use(cop)


func _physics_process(delta: float) -> void:
	if not party or party.singing():
		return
	_rest = maxf(_rest - delta, 0.0)
	_left -= delta
	match state:
		State.HANG:
			_hang()
		State.CARRY:
			_carry(delta)
		State.CRY, State.CANDY:
			if _left <= 0.0:
				state = State.WANDER
		State.WANDER:
			_wander(delta)
	if state != State.CRY and state != State.HANG:
		_watch_pushes()


## Crying for CRY_TIME seconds; `tell` lets Chispita know (the cake's fall he counts once, not once a kid).
func cry(tell := true) -> void:
	if state == State.CRY:
		return
	stop()
	state = State.CRY
	_left = CRY_TIME
	say("BIRTHDAY_KID_CRY")
	if tell:
		cried.emit(self)


## Lets go of the cop's leg and of what they carry.
func stop() -> void:
	if state == State.HANG:
		_let_go()
	_drop()


## The piñata broke: down on the floor at `spot` picking up candies;
## `shout` says so (not everyone at once).
func pick_candies(spot: Vector3, shout := true) -> void:
	stop()
	state = State.CANDY
	_left = CANDY_TIME
	position = spot
	if shout:
		say("BIRTHDAY_CANDIES")


func is_hanging() -> bool:
	return state == State.HANG


## Online (NpcSync): the host runs the kids and the guests' copies follow; a copy hanging on a leg slows down the cop
## it hangs on there (its own PC's cop is the one that walks).
func net_state() -> Variant:
	return state == State.HANG


func apply_net_state(hanging: Variant) -> void:
	if hanging and not is_instance_valid(hanging_on):
		hanging_on = _cop_near(HANG_REACH)
	elif not hanging and is_instance_valid(hanging_on):
		hanging_on.slow_factor = 1.0
		hanging_on = null
	if is_instance_valid(hanging_on):
		hanging_on.slow_factor = HANG_SLOW


func _wander(delta: float) -> void:
	if not wanders:
		return
	var item := _small_item_near()
	if item:
		carrying = item
		item.freeze = true
		state = State.CARRY
		_left = BORED
		say("BIRTHDAY_KID_GRAB")
		return
	var cop := _cop_near(HANG_REACH)
	if cop and _rest <= 0.0 and not party.is_hung_on(cop):
		hanging_on = cop
		cop.slow_factor = HANG_SLOW
		state = State.HANG
		_left = HANG_TIME
		say("BIRTHDAY_KID_HANG")
		return
	if _target == Vector3.INF or _walk_to(_target, delta):
		var spots := BirthdayRaid.KID_SPOTS
		_target = spots[_rng.randi_range(0, spots.size() - 1)] + Vector3(0, position.y, 0)


func _hang() -> void:
	if not is_instance_valid(hanging_on) or _left <= 0.0:
		_let_go()
		return
	hanging_on.slow_factor = HANG_SLOW
	position = party.to_local(hanging_on.to_global(ON_LEG))
	position.y = maxf(position.y, BirthdayRaid.FLOOR_TOP)
	rotation.y = hanging_on.rotation.y


func _let_go() -> void:
	if is_instance_valid(hanging_on):
		hanging_on.slow_factor = 1.0
	hanging_on = null
	state = State.WANDER
	_rest = HANG_REST


## Off to the castle with it, and playing there until bored.
func _carry(delta: float) -> void:
	if not is_instance_valid(carrying) or carrying.is_held():
		carrying = null
		state = State.WANDER
		return
	if _left <= 0.0:
		say("BIRTHDAY_KID_BORED")
		# At the castle it stays inside, bouncing.
		var near := position.distance_to(BirthdayRaid.CASTLE_PLAY) < 1.0
		_drop(BirthdayRaid.CASTLE_DROP if near else Vector3.INF)
		return
	_walk_to(BirthdayRaid.CASTLE_PLAY, delta)
	carrying.global_transform = Transform3D(global_basis, to_global(HAND))


## Lets go of what they carry: at `at` (in the party's space), or on the floor before them.
func _drop(at := Vector3.INF) -> void:
	if not is_instance_valid(carrying):
		carrying = null
		return
	carrying.freeze = false
	carrying.global_position = party.to_global(at) if at != Vector3.INF else to_global(Vector3(0, 0.3, -0.5))
	carrying = null
	if state == State.CARRY:
		state = State.WANDER


## A step towards `at` (on the floor); true once there.
func _walk_to(at: Vector3, delta: float) -> bool:
	var to := at - position
	to.y = 0.0
	if to.length() <= ARRIVED:
		return true
	position += to.normalized() * minf(SPEED * delta, to.length())
	# Members face -z.
	look_at(global_position + party.global_basis * to)
	return false


func _small_item_near() -> Grabbable:
	for item: Grabbable in party.loose_items:
		# Nothing sharp, though.
		if not is_instance_valid(item) or item.is_held() or item.freeze or item.mass >= SMALL_KG \
				or item.has_meta("sharp"):
			continue
		var at := party.to_local(item.global_position)
		if at.y - BirthdayRaid.FLOOR_TOP < ON_FLOOR and Vector2(at.x - position.x, at.z - position.z).length() < GRAB_REACH:
			return item
	return null


func _cop_near(reach: float) -> Cop:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var at := party.to_local(cop.global_position)
		if party.is_ancestor_of(cop) and Vector2(at.x - position.x, at.z - position.z).length() < reach \
				and absf(at.y - position.y) < 1.5:
			return cop
	return null


func _watch_pushes() -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var at := party.to_local(cop.global_position)
		if party.is_ancestor_of(cop) and Vector2(at.x - position.x, at.z - position.z).length() < PUSH_REACH \
				and Vector2(cop.velocity.x, cop.velocity.z).length() > PUSH_SPEED:
			cry()
			return
