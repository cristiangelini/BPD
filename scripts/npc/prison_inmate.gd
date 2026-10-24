class_name PrisonInmate
extends CharacterBody3D

## An inmate in the prison's canteen (carcel-motin.md, step 2, decision 104): standing at their place by a table, with
## an `anger` from 0 to MAX_ANGER. It goes up with what upsets them (raise: food on them, step 2b) and, once the riot
## is on, drifts down DECAY a second after CALM_AFTER seconds left alone. At ANGRY or more they're angry: red steam over
## their head and shouts. Step 2b: an angry inmate throws food every THROW_EVERY seconds or so (RallyThrowable: mash,
## jelly, chicken or yogurt) at whoever PrisonRiot.target_for picks, a cop or another inmate, up to MISS off; food
## that hits an inmate upsets them HIT_ANGER more, so the riot spreads. Step 4: a cop holding E on them, close and
## looking at them, talks them down TALK_RATE a second until some food hits that cop; at 0 they sit down. Cuffed they
## calm down at once and don't throw. A ringleader's anger never goes down: they stand on their table, can't be talked
## to, and cuffed, E walks them to the punishment cell (PrisonEscort). Every number here is (propuesta).

## They got angry, or calmed down below ANGRY.
signal angry_changed(inmate: PrisonInmate, angry: bool)
signal threw(inmate: PrisonInmate, food: RallyThrowable)

const MODEL := preload("res://assets/models/npc_preso.glb")
const MAX_ANGER := 100.0
const ANGRY := 60.0
const DECAY := 1.5
const CALM_AFTER := 6.0
const SHOUTS := 6
const SHOUT_EVERY := 5.0
const SAY_TIME := 3.0
const STEAM_COLOR := Color(0.95, 0.2, 0.15)
const FOODS: Array[String] = ["mash", "jelly", "chicken", "yogurt"]
const THROW_EVERY := 6.0
const THROW_JITTER := 2.0
## Where the throw leaves from (about their raised hand), how long it flies and how far off it may land: more at a cop,
## who is further away and moving.
const HAND := Vector3(0.25, 1.4, 0)
const FLIGHT := 0.9
const MISS := 0.8
const MISS_INMATE := 0.5
## Aimed at the chest.
const CHEST := 1.1
const HIT_ANGER := 35.0
const HITS := 3
## Talking: within TALK_REACH, the cop's front within TALK_FACING (dot) of them.
const TALK_RATE := 12.0
const TALK_REACH := 2.5
const TALK_FACING := 0.6
const TALKS := 3
## Calm, they sit down on the bench this much lower.
const SIT_DROP := 0.35
## A ringleader on their table's top.
const TABLE_TOP := 0.79

var anger := 0.0
## The riot is on: anger drifts down and the angry ones shout (PrisonRiot.start).
var active := false
## A guest's copy (NpcSync): the host's says how angry they are.
var follower := false
## Who they throw at (step 2b): set by PrisonRiot.
var riot: PrisonRiot
## Their table (PrisonRiot.setup) and whether they lead it: stood on it, always angry (step 4).
var table: CanteenTable
var ringleader := false
## The cop talking them down, if any (step 4), and the stains on that cop when it began: one more breaks it off.
var talker: Cop
var _talker_stains := 0
var _cuffed_left := 0.0
var _throw_left := 0.0
var _quiet_left := 0.0
var _shout_left := 0.0
var _next_shout := 0
var _was_angry := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _steam: Label3D


func _ready() -> void:
	add_to_group("prison_inmates")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z; the inmate's front is -Z, like the other NPCs placed by code.
	_model.rotation.y = PI
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.85, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	_steam = Label3D.new()
	_steam.name = "Steam"
	_steam.text = "#@!"
	_steam.font_size = 90
	_steam.pixel_size = 0.004
	_steam.outline_size = 14
	_steam.modulate = STEAM_COLOR
	_steam.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_steam.position = Vector3(0, 1.6, 0)
	add_child(_steam)
	_update()


func is_angry() -> bool:
	return anger >= ANGRY


## Something upset them: `points` more anger, and they stay upset a while before it starts going down.
func raise(points: float) -> void:
	anger = minf(anger + points, MAX_ANGER)
	_quiet_left = CALM_AFTER
	_update()


## Something calmed them: `points` less anger. Nothing calms a ringleader.
func calm(points: float) -> void:
	if ringleader:
		return
	anger = maxf(anger - points, 0.0)
	_update()


## Walked into the punishment cell (PrisonEscort): out of the riot.
func is_jailed() -> bool:
	var escort := OwnerEscort.of(self)
	return escort != null and escort.in_car


## Up on their table's top, over their place (a ringleader, until the table goes over or they're cuffed).
func climb() -> void:
	if not table or table.tipped_side != 0.0 or is_cuffed() or is_jailed():
		return
	var on := table.global_transform.affine_inverse() * global_position
	global_position = table.global_transform * Vector3(on.x, TABLE_TOP, 0.0)


## Down off the table to the floor on its `side` (local Z), a step past the bench.
func jump_down(side: float) -> void:
	var on := table.global_transform.affine_inverse() * global_position
	if on.y < TABLE_TOP / 2:
		return
	global_position = table.global_transform * Vector3(on.x, 0.05, side * (PrisonRiot.PLACE_Z + 0.3))


func is_on_table() -> bool:
	return table != null and (table.global_transform.affine_inverse() * global_position).y > TABLE_TOP / 2


func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	end_talk()
	if follower:
		return
	if ringleader:
		say("RINGLEADER_CUFFED")
		return
	anger = 0.0
	_update()
	say("INMATE_CUFFED")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	if talker == cop or is_cuffed() or (anger <= 0.0 and not ringleader):
		return ""
	return "PROMPT_TALK_INMATE"


## E: cuffed, the escort; a ringleader won't listen; anyone else, `cop` starts talking them down while E is held.
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	if ringleader:
		say("RINGLEADER_NO_TALK")
		return
	if talker or is_cuffed() or anger <= 0.0:
		return
	talker = cop
	cop.talking_to = self
	_talker_stains = riot.stains_on(cop) if riot else 0
	say("INMATE_TALK_%d" % randi_range(1, TALKS))


## The talk is over: E let go, the cop walked off or got hit.
func end_talk() -> void:
	if talker and is_instance_valid(talker) and talker.talking_to == self:
		talker.talking_to = null
	talker = null


## What the escort calls (OwnerEscort): a line for `seconds`, and being taken by the arm upsets no one further.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key, seconds)


func _raise(_points: float) -> void:
	pass


## Food burst on them (RallyThrowable): a stain, and it upsets them.
func hit_by_food(food: RallyThrowable) -> void:
	if food:
		RallyThrowable.stain_on(self, food.kind, food.global_position)
	raise(HIT_ANGER)
	if active and not follower:
		say("INMATE_HIT_%d" % randi_range(1, HITS))


## Throws a `kind` to land on `target` (world space), facing it. Returns what flies.
func throw_at(target: Vector3, kind: String) -> RallyThrowable:
	var to := target - global_position
	to.y = 0.0
	if to.length() > 0.1:
		look_at(global_position + to, Vector3.UP)
	var food := RallyThrowable.new()
	food.kind = kind
	get_parent().add_child(food, true)
	add_collision_exception_with(food)
	food.add_collision_exception_with(self)
	food.launch(global_transform * HAND, target, FLIGHT)
	threw.emit(self, food)
	return food


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## What a guest's copy needs besides where they are and what they say (NpcSync).
func net_state() -> Array:
	return [snappedf(anger, 0.5), active, is_cuffed()]


func apply_net_state(state: Variant) -> void:
	anger = state[0]
	active = state[1]
	_cuffed_left = Handcuffs.SECONDS if state[2] else 0.0
	_update()


func _update() -> void:
	if not is_node_ready():
		return
	var angry := is_angry()
	_steam.visible = angry
	_model.position.y = -SIT_DROP if anger <= 0.0 and active and not is_on_table() else 0.0
	if angry != _was_angry:
		_was_angry = angry
		if angry:
			_shout_left = 0.0
			_throw_left = randf_range(0.5, THROW_EVERY)
		angry_changed.emit(self, angry)


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if not active or follower:
		return
	_quiet_left -= delta
	if _quiet_left <= 0.0 and anger > 0.0:
		calm(DECAY * delta)
	if talker:
		_talk(delta)
	if is_cuffed() or is_jailed():
		return
	if is_angry():
		_throw_left -= delta
		if _throw_left <= 0.0:
			_throw_left = THROW_EVERY + randf_range(-THROW_JITTER, THROW_JITTER)
			var target: Node3D = riot.target_for(self) if riot else null
			if target:
				var off: float = MISS if target is Cop else MISS_INMATE
				var miss := Vector3(randf_range(-off, off), randf_range(-off, off) * 0.5, randf_range(-off, off))
				throw_at(target.global_position + Vector3.UP * CHEST + miss, FOODS[randi_range(0, FOODS.size() - 1)])
		_shout_left -= delta
		if _shout_left <= 0.0:
			_shout_left = SHOUT_EVERY + randf_range(0.0, 2.0)
			if ringleader:
				say("RINGLEADER_SHOUT_%d" % (_next_shout % PrisonRiot.RILES + 1))
			else:
				say("INMATE_SHOUT_%d" % (_next_shout % SHOUTS + 1))
			_next_shout += 1


## Talked down while `talker` stays close, looks at them and keeps clean; calm at last, they sit.
func _talk(delta: float) -> void:
	if not is_instance_valid(talker) or talker.talking_to != self:
		talker = null
		return
	var to := global_position - talker.global_position
	to.y = 0.0
	var facing := (-talker.global_basis.z * Vector3(1, 0, 1)).normalized().dot(to.normalized())
	if to.length() > TALK_REACH or facing < TALK_FACING:
		end_talk()
		return
	if riot and riot.stains_on(talker) > _talker_stains:
		talker.show_hint("HINT_TALK_BROKEN")
		end_talk()
		return
	calm(TALK_RATE * delta)
	_quiet_left = CALM_AFTER
	if anger <= 0.0:
		end_talk()
		say("INMATE_CALMED")


func _process(delta: float) -> void:
	# The escort turns them with their +Z ahead.
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and escort.escorted_by else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
