class_name GardenPlan
extends Node3D

## The prison's new garden (carcel-huerta.md, step 2): 12 beds in the east of the yard, 3 across and 4 deep, each with
## 4 plants of one kind (lettuce, carrot, tomato or pumpkin, by the seed). Garden time starts when the first cop walks
## through the gate, and the 6 gardeners (YardInmate, GARDEN, with straw hats and watering cans) go from bed to bed,
## each round their own beds. Step 3: the seed hides MAGIC magic beans (GardenPlant.magic) among the plants, each in a
## bed of its own; the first starts growing FIRST_BEAN seconds into garden time and each of the others BEAN_EVERY
## seconds after the one before. Every magic bed is on WATERED_BY gardeners' rounds, and at one they sing to it.
## Step 4: E on a plant pulls it. A magic bean comes out with one cop up to its stage TUG_FROM - 1; from TUG_FROM on it
## holds on until TUGGERS cops pull within TUG_WINDOW seconds of each other (one, playing alone). A vegetable pulled by
## mistake is out too (`wrong`), and the nearest gardener is offended. Step 5: while a giant stands, every CLIMB_EVERY
## seconds the nearest gardener goes up it (GardenClimber): over the wall he's `escaped`; pulled down, cuffed and
## walked into a cell (the punishment cell: the block is locked) he's `caught`. Step 6: garden time lasts TIME
## seconds (`ended`). Step 7: on a guest the host's plan decides (`follower`); its counts and clock come with the case
## (net_state), the plants, the gardeners and the climbers by NpcSync.

signal bean_grew(plant: GardenPlant, stage: int)
signal bean_pulled(plant: GardenPlant, stage: int)
signal wrong_pull(plant: GardenPlant)
signal ended
signal escaped_one(count: int)
signal caught_one(count: int)

const BEDS := 12
const PER_BED := 4
const BED_XS: Array[float] = [6.5, 9.0, 11.5]
const BED_ZS: Array[float] = [10.0, 12.6, 15.2, 17.8]
const BED_SIZE := Vector3(1.8, 0.3, 0.6)
const SLOT_XS: Array[float] = [-0.66, -0.22, 0.22, 0.66]
const GARDENERS := 6
const STOPS := 4
## A gardener stands this far in front of a bed (on its south side) to work at it.
const AT_BED := 0.75
const SOIL := Color(0.36, 0.25, 0.15)
const CAN := Color(0.35, 0.6, 0.4)
const MAGIC := 3
const FIRST_BEAN := 10.0
const BEAN_EVERY := 60.0
const WATERED_BY := 2
const SING_LINES := 3
const TUG_FROM := 3
const TUGGERS := 2
const TUG_WINDOW := 2.0
## A bean pulled before this stage counts as found early (the case's bonus).
const EARLY_BEFORE := 4
const TIME := 360.0
const CLIMB_EVERY := 30.0
## Where a climber comes from with no gardeners left: out of the canteen's east door.
const DOOR_OUT := Vector2(2.0, 9.0)
## The climber starts up the giant from this far out of its bed, on the wall's side.
const FOOT_OUT := 0.5

var prison: PrisonLevel
var plants: Array[GardenPlant] = []
var gardeners: Array[YardInmate] = []
## Each bed's kind (GardenPlant.Kind).
var kinds: Array[int] = []
var started := false
## The magic beans, in the order they start growing, and how long into garden time it is.
var beans: Array[GardenPlant] = []
var time := 0.0
## Step 4: the beans pulled (and how many before EARLY_BEFORE) and the vegetables pulled by mistake.
var pulled := 0
var early := 0
var wrong := 0
var _tugs := {}
## Step 5: the ones going up a giant, and how many got over and were walked to a cell.
var climbers: Array[GardenClimber] = []
var escaped := 0
var caught := 0
var down := 0
var _climb_left := {}
var over := false
## A guest's copy (step 7): the host's one decides.
var follower := false:
	set(value):
		follower = value
		for plant in plants:
			plant.follower = value
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["prison garden", case_seed])
	for i in BEDS:
		kinds.append(i % GardenPlant.Kind.size())
	_shuffle(kinds)
	for i in BEDS:
		_bed(i)
	var beds := range(BEDS)
	_shuffle(beds)
	child_entered_tree.connect(_on_child_entered)
	for bed: int in beds.slice(0, MAGIC):
		var bean := plants[bed * PER_BED + _rng.randi_range(0, PER_BED - 1)]
		bean.magic = true
		bean.prison = level
		bean.grew.connect(func(plant: GardenPlant, stage: int) -> void: bean_grew.emit(plant, stage))
		beans.append(bean)
	for i in GARDENERS:
		var gardener := YardInmate.new()
		gardener.name = "Gardener%d" % i
		gardener.prison = level
		gardener.activity = YardInmate.Activity.GARDEN
		gardener.wander_seed = _rng.randi()
		var rounds := range(BEDS)
		_shuffle(rounds)
		for bed: int in rounds.slice(0, STOPS):
			gardener.stops.append(bed_front(bed))
		for b in beans.size():
			if (i + b) % (GARDENERS / WATERED_BY) == 0 and not gardener.stops.has(bed_front(beans[b].bed)):
				gardener.stops[b % STOPS] = bed_front(beans[b].bed)
		gardener.spot = gardener.stops[0]
		gardener.face = bed_center(int(rounds[0]))
		add_child(gardener)
		gardener.place()
		_watering_can(gardener)
		gardeners.append(gardener)


func _shuffle(list: Array) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = list[i]
		list[i] = list[j]
		list[j] = swap


## The middle of bed `bed` on the yard's floor (level space x, z).
static func bed_center(bed: int) -> Vector2:
	return Vector2(BED_XS[bed % BED_XS.size()], BED_ZS[bed / BED_XS.size()])


## Where a gardener works at bed `bed`.
static func bed_front(bed: int) -> Vector2:
	return bed_center(bed) - Vector2(0, AT_BED)


func _bed(bed: int) -> void:
	var at := bed_center(bed)
	var box := StaticBody3D.new()
	box.name = "Bed%d" % bed
	box.position = Vector3(at.x, PrisonLevel.FLOOR_TOP, at.y)
	add_child(box)
	var shape := CollisionShape3D.new()
	var size := BoxShape3D.new()
	size.size = BED_SIZE
	shape.shape = size
	shape.position.y = BED_SIZE.y / 2
	box.add_child(shape)
	box.add_child(CopTool.piece(CopTool.box(BED_SIZE), PrisonLevel.WOOD, Vector3(0, BED_SIZE.y / 2, 0)))
	box.add_child(CopTool.piece(CopTool.box(Vector3(BED_SIZE.x - 0.1, 0.02, BED_SIZE.z - 0.1)), SOIL,
		Vector3(0, BED_SIZE.y, 0)))
	for slot in PER_BED:
		var plant := GardenPlant.new()
		plant.name = "Plant%d_%d" % [bed, slot]
		plant.kind = kinds[bed] as GardenPlant.Kind
		plant.bed = bed
		plant.slot = slot
		plant.position = Vector3(at.x + SLOT_XS[slot], PrisonLevel.FLOOR_TOP + BED_SIZE.y + 0.01, at.y)
		add_child(plant)
		plant.tugged.connect(_on_tugged)
		plants.append(plant)


## The gardener's green watering can, in the right hand.
func _watering_can(gardener: YardInmate) -> void:
	var can := Node3D.new()
	can.name = "WateringCan"
	can.position = Vector3(0.38, 0.7, 0.15)
	gardener.add_child(can)
	can.add_child(CopTool.piece(CopTool.cylinder(0.1, 0.22), CAN))
	can.add_child(CopTool.piece(CopTool.cylinder(0.015, 0.25), CAN, Vector3(0, 0.05, 0.16), Vector3(-1.0, 0, 0)))


func _physics_process(delta: float) -> void:
	if follower:
		return
	if not started:
		for cop: Node3D in get_tree().get_nodes_in_group("cops"):
			if prison.inside_walls(cop.global_position):
				start()
				return
		return
	if over:
		return
	time += delta
	if time >= TIME:
		over = true
		ended.emit()
		return
	for i in beans.size():
		if time >= FIRST_BEAN + i * BEAN_EVERY and not beans[i].growing and beans[i].stage == 0:
			beans[i].start_growing()
	_sing()
	_climbs(delta)


## Every giant still standing sends someone up it every CLIMB_EVERY seconds, one at a time.
func _climbs(delta: float) -> void:
	for bean in beans:
		if bean.pulled or bean.stage < GardenPlant.STAGES:
			continue
		if _on_its_way(bean):
			continue
		_climb_left[bean] = float(_climb_left.get(bean, 0.0)) - delta
		if _climb_left[bean] <= 0.0:
			_climb_left[bean] = CLIMB_EVERY
			send_climber(bean)


## Someone is already walking to `bean` or up it.
func _on_its_way(bean: GardenPlant) -> bool:
	for each in climbers:
		if each.get_meta("bean") == bean and not each.is_escaped and (each.climbing or each.active):
			return true
	return false


## The nearest gardener drops his watering can and goes up `bean` (with no gardeners left, one from the canteen).
func send_climber(bean: GardenPlant) -> GardenClimber:
	var from := prison.global_transform * Vector3(DOOR_OUT.x, PrisonLevel.FLOOR_TOP, DOOR_OUT.y)
	var gardener := _nearest_gardener(bean)
	if gardener:
		from = gardener.global_position
		gardeners.erase(gardener)
		gardener.queue_free()
	var climber := GardenClimber.new()
	climber.name = "Climber%d" % climbers.size()
	climber.role = BlackoutInmate.Role.WANDER
	climber.glow_eyes = false
	climber.prison = prison
	var out := bean.top - bean.position
	out.y = 0.0
	climber.foot = Vector3(bean.position.x, PrisonLevel.FLOOR_TOP, bean.position.z) \
		+ out.normalized() * (BED_SIZE.z / 2 + FOOT_OUT)
	climber.top = bean.top
	climber.route = [Vector2(climber.foot.x, climber.foot.z)] as Array[Vector2]
	climber.set_meta("bean", bean)
	add_child(climber)
	climber.global_position = from
	climber.active = true
	climber.say("GARDEN_TO_THE_BEAN")
	climber.escaped.connect(_on_climber_escaped)
	climber.pulled_down.connect(func(_who: GardenClimber) -> void: down += 1)
	BlackoutEscort.to_block(climber, prison).boarded.connect(_on_caught.bind(climber))
	climbers.append(climber)
	return climber


func _on_climber_escaped(_climber: BlackoutInmate) -> void:
	escaped += 1
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_GARDEN_ESCAPED")
	escaped_one.emit(escaped)


func _on_caught(climber: GardenClimber) -> void:
	if climber.has_meta("caught"):
		return
	climber.set_meta("caught", true)
	caught += 1
	caught_one.emit(caught)


## A gardener working at a bed with a magic bean growing in it sings to it.
func _sing() -> void:
	for gardener in gardeners:
		if gardener._pause <= 0.0 or gardener.said() != "":
			continue
		var at := prison.global_transform.affine_inverse() * gardener.global_position
		for bean in beans:
			if bean.growing and Vector2(at.x, at.z).distance_to(bed_front(bean.bed)) < 0.5:
				gardener.say("GARDEN_SING_%d" % (bean.bed % SING_LINES), 4.0)
				break


## E on a plant (on every PC; the host decides).
func _on_tugged(plant: GardenPlant, cop: Cop) -> void:
	if follower or plant.pulled:
		return
	if not plant.magic:
		plant.pull_out()
		wrong += 1
		var gardener := _nearest_gardener(plant)
		if gardener:
			gardener.say("GARDEN_MY_%s" % GardenPlant.Kind.keys()[plant.kind], 3.0)
		cop.show_hint("HINT_GARDEN_WRONG")
		wrong_pull.emit(plant)
		return
	if plant.stage >= TUG_FROM:
		var now := Time.get_ticks_msec()
		var on: Dictionary = _tugs.get(plant, {})
		on[cop] = now
		_tugs[plant] = on
		var cops := get_tree().get_nodes_in_group("cops").size()
		var pulling := on.values().filter(func(at: int) -> bool: return now - at <= TUG_WINDOW * 1000.0)
		if pulling.size() < mini(TUGGERS, maxi(cops, 1)):
			plant.shake()
			cop.show_hint("HINT_GARDEN_TUG")
			return
		_tugs.erase(plant)
	var stage := plant.stage
	plant.pull_out()
	pulled += 1
	if stage < EARLY_BEFORE:
		early += 1
	for each: Cop in get_tree().get_nodes_in_group("cops"):
		each.show_hint("HINT_GARDEN_BEAN")
	bean_pulled.emit(plant, stage)


func _nearest_gardener(plant: GardenPlant) -> YardInmate:
	var best: YardInmate = null
	for gardener in gardeners:
		if not best or gardener.global_position.distance_to(plant.global_position) \
				< best.global_position.distance_to(plant.global_position):
			best = gardener
	return best


## A guest's copy of a climber (NpcSync makes it here): its way to a cell too, so the guest's cops see the prompt to
## walk him there.
func _on_child_entered(node: Node) -> void:
	if not follower or not node is GardenClimber or climbers.has(node):
		return
	var climber := node as GardenClimber
	climber.prison = prison
	climbers.append(climber)
	(func() -> void: BlackoutEscort.to_block(climber, prison).follower = true).call_deferred()


## For a guest's case (GardenCase.snapshot): the clock and the counts.
func net_state() -> Array:
	return [started, time, over, pulled, early, wrong, escaped, caught, down]


func apply_net_state(state: Array) -> void:
	if state[0] and not started:
		started = true
	time = state[1]
	over = state[2]
	pulled = state[3]
	early = state[4]
	wrong = state[5]
	escaped = state[6]
	caught = state[7]
	down = state[8]


func time_left() -> float:
	return maxf(TIME - time, 0.0) if started else TIME


## The next magic bean grows one stage now (the debug panel's shortcut, once it exists).
func grow_next() -> void:
	for bean in beans:
		if not bean.pulled and bean.stage < GardenPlant.STAGES:
			bean.growing = true
			bean.set_stage(bean.stage + 1)
			return


## Garden time: off to their beds.
func start() -> void:
	if started:
		return
	started = true
	for i in gardeners.size():
		gardeners[i].start(i * 0.5)
