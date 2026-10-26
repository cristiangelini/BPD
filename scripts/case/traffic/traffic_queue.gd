class_name TrafficQueue
extends Node3D

## The cars that come to the traffic control and their patience (control-transito.md, "Cómo es el caso", steps 3 and
## 6). Once the checkpoint is set up, a car comes down the lane every SPAWN_EVERY seconds and joins the queue. Each car
## waiting adds to the patience meter; at FULL the first one sneaks by along the sidewalk and the meter drops a bit.
## E on the barrier lets the first one through. There's no time limit (decision 98): only the meter.
## "rush_hour" (Hora pico) sends twice the cars and wears the patience out faster. "clown_convoy" (control-payasos.md)
## sends the circus's identical clown cars, a bit less often since each one takes longer to check; their clowns loose
## on the street wear the patience out too, and a car won't go until its clowns are back in. "fruit_truck"
## (control-frutas.md) sends the fruit fair's pickups, loaded with watermelons. "crowded_car" (control-auto-lleno.md)
## sends city cars, some of them packed with people. "ghost_car" (control-auto-fantasma.md) sends city cars with their
## drivers leaning on the windows, and one with nobody at the wheel. "wedding" (control-boda.md) sends the wedding's
## convoy, with the newlyweds up front and a few city cars among them. "race" (control-carrera.md) sends city cars
## and, among them, the night's racers, in heats out of the queue. "fog" (control-neblina.md) sends city cars with
## their headlights on, out of the fog. "circus_move" (control-circo.md) sends the circus's trucks, each with a caged
## animal, and a few city cars among them. Every number here is (propuesta).

signal patience_changed(value: float)
## A car went by: let through, or sneaking.
signal passed(car: QueueCar, sneaked: bool)
## A car rolled over a spike strip (control-carrera.md, step 3).
signal punctured(car: QueueCar)

const SPAWN_EVERY := 6.0
## Cars start this far up the lane from the checkpoint.
const SPAWN_FROM := 70.0
## No new car while the queue's last one is this close to where they start.
const SPAWN_ROOM := 8.0
const FULL := 100.0
## Per waiting car, per second.
const PATIENCE_PER_CAR := 0.5
## Per second with nobody waiting.
const CALM_DOWN := 2.0
## Per clown loose on the street, per second (control-payasos.md, step 4).
const PATIENCE_PER_CLOWN := 0.4
## After a car sneaks by, the meter drops back to this.
const AFTER_SNEAK := 70.0
const VARIANTS := {
	"rush_hour": {"spawn": 0.5, "patience": 1.5},
	"clown_convoy": {"spawn": 0.75, "patience": 1.0, "clown": true},
	"fruit_truck": {"spawn": 0.75, "patience": 1.0, "fruit": true},
	"crowded_car": {"spawn": 0.75, "patience": 1.0, "crowd": true},
	"ghost_car": {"spawn": 0.75, "patience": 1.0, "ghost": true},
	"wedding": {"spawn": 0.75, "patience": 1.0, "wedding": true},
	"race": {"spawn": 0.75, "patience": 1.0, "race": true},
	"fog": {"spawn": 0.75, "patience": 1.0, "fog": true},
	"circus_move": {"spawn": 0.75, "patience": 1.0, "circus": true},
}

var checkpoint: TrafficCheckpoint
## Which cars come, in order, with the wanted one among them (step 4). Without it, random cars forever.
var plan: WantedPlan
var variant := "rush_hour"
var case_seed := 1
var patience := 0.0
## In the order they came, the first one first.
var cars: Array[QueueCar] = []
var spawned := 0
## How many cars sneaked by so far.
var sneaked := 0
## How many cars ran the checkpoint in the fog, unwarned (counted in `sneaked` too).
var overruns := 0
## Online, a guest's queue only shows the host's: its cars come from the host (NpcSync) and so does the meter.
var follower := false
## The street race's racers (control-carrera.md, step 2): out of the queue, in heats; how many heats came so far.
var racers: Array[QueueCar] = []
var heats := 0
var _until_heat := RaceCar.FIRST_HEAT
var _until_spawn := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = hash(["traffic queue", case_seed])
	for barrier: RoadBarrier in get_tree().get_nodes_in_group("road_barriers"):
		if barrier.get_parent() == get_parent():
			barrier.lifted.connect(func(_cop: Cop) -> void: release_front())


func spawn_every() -> float:
	return SPAWN_EVERY * float(VARIANTS[variant].spawn)


func loose_clowns() -> int:
	var count := 0
	for car in cars:
		count += car.clowns_out.size()
	return count


func waiting_count() -> int:
	return cars.filter(func(car: QueueCar) -> bool: return car.waiting()).size()


func front() -> QueueCar:
	return cars[0] if not cars.is_empty() else null


func release_front() -> void:
	var car := front()
	if car and not car.can_go():
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			cop.show_hint("HINT_RIDERS_OUT" if car.crowd > 0 else "HINT_CLOWNS_OUT")
		return
	if car:
		car.let_through()
		_leave(car, false)


## A detained car leaves the queue for the curb.
func pull_over(car: QueueCar) -> void:
	car.pull_over()
	var i := cars.find(car)
	if i >= 0:
		cars.remove_at(i)
		if i < cars.size():
			cars[i].ahead = cars[i - 1] if i > 0 else null


func _physics_process(delta: float) -> void:
	if follower or not checkpoint or not checkpoint.ready_now:
		return
	_until_spawn -= delta
	if _until_spawn <= 0.0 and _room_to_spawn():
		_until_spawn = spawn_every()
		spawn()
	# A car that went by on its own (the barrier was off the lane) leaves the queue too.
	for car in cars.duplicate():
		if not is_instance_valid(car) or car.at.z < -TrafficCheckpoint.ZONE.y:
			_leave(car, false)
	var waiting := waiting_count()
	var loose := loose_clowns()
	if waiting > 0 or loose > 0:
		_set_patience(patience + (waiting * PATIENCE_PER_CAR * float(VARIANTS[variant].patience)
			+ loose * PATIENCE_PER_CLOWN) * delta)
	else:
		_set_patience(patience - CALM_DOWN * delta)
	if patience >= FULL and front() and front().can_go():
		var car := front()
		car.sneak()
		sneaked += 1
		_leave(car, true)
		_set_patience(AFTER_SNEAK)
	if VARIANTS[variant].get("race", false):
		_run_heats(delta)


func heats_total() -> int:
	return plan.heats.size() if plan and plan.race else RaceCar.heats_of(case_seed)


func _run_heats(delta: float) -> void:
	_until_heat -= delta
	if _until_heat <= 0.0 and heats < heats_total():
		spawn_heat()
	for racer in racers.duplicate():
		if not is_instance_valid(racer):
			racers.erase(racer)
		elif racer.state == "racing" and racer.at.z < -TrafficCheckpoint.ZONE.y:
			# A punctured one stopped, wherever that was: it didn't get away.
			racers.erase(racer)
			passed.emit(racer, false)


## The next heat gathers at the back corner, in the race lane, one behind the other.
func spawn_heat() -> Array[QueueCar]:
	var heat: Array[QueueCar] = []
	var size := plan.heats[heats].size() if plan and plan.race else RaceCar.heat_size(case_seed, heats)
	for slot in size:
		var data: Dictionary = plan.heats[heats][slot] if plan and plan.race else WantedPlan.random_car(_rng)
		var car := QueueCar.new()
		car.name = "Racer%d_%d" % [heats, slot]
		car.checkpoint = checkpoint
		car.look = data.look
		car.plate = data.plate
		car.driver = data.driver
		car.race_mode = true
		car.racer = true
		car.race = data.get("race", RaceCar.traits_of(car.plate))
		car.wanted = data.get("wanted", false)
		car.race_slot = slot
		car.race_left = RaceCar.GATHER
		car.state = "gathering"
		car.at = Vector3(RaceCar.LANE, 0, SPAWN_FROM + slot * RaceCar.SLOT_GAP)
		car.ahead = heat.back() if not heat.is_empty() else null
		racers.append(car)
		heat.append(car)
		add_child(car)
	_until_heat = RaceCar.heat_every(case_seed, heats)
	heats += 1
	return heat


func _room_to_spawn() -> bool:
	if plan and spawned >= plan.total:
		return false
	return cars.is_empty() or cars.back().at.z < SPAWN_FROM - SPAWN_ROOM


func spawn() -> QueueCar:
	var car := QueueCar.new()
	car.name = "QueueCar%d" % spawned
	car.checkpoint = checkpoint
	var clown: bool = VARIANTS[variant].get("clown", false)
	var fruit: bool = VARIANTS[variant].get("fruit", false)
	var crowd: bool = VARIANTS[variant].get("crowd", false)
	var ghost: bool = VARIANTS[variant].get("ghost", false)
	var data := plan.cars[spawned] if plan and spawned < plan.total \
		else WantedPlan.random_car(_rng, clown, fruit, crowd, ghost, VARIANTS[variant].get("wedding", false))
	car.look = data.look
	car.plate = data.plate
	car.driver = data.driver
	car.clown = clown
	car.fruit = fruit
	var fruit_traits: Dictionary = data.get("fruit", {})
	car.crate = fruit_traits.get("crate", "")
	car.hat = fruit_traits.get("hat", "")
	car.melon_kinds.assign(fruit_traits.get("melons", []))
	car.clown_traits = data.get("clown", {})
	if crowd:
		car.crowd = data.get("crowd", CrowdedCar.riders_of(car.plate))
	if ghost:
		car.ghost_mode = true
		car.shirt = data.get("shirt", -1)
		car.ghost = data.get("ghost", spawned == GhostCar.ghost_at(case_seed))
		car.puppeteer = data.get("puppeteer", spawned == GhostCar.pilot_at(case_seed))
	if VARIANTS[variant].get("wedding", false):
		car.wedding_mode = true
		car.newlyweds = data.get("newlyweds", spawned == WeddingCar.newlyweds_at(case_seed))
		car.guest = data.get("guest", WeddingCar.guest_at(case_seed, spawned))
		car.tie = data.get("tie", -1)
		car.alcohol = data.get("alcohol", -1.0)
		car.couple = data.get("couple", plan.couple if plan else 0)
		if car.newlyweds:
			car.look = WeddingCar.NEWLYWEDS_LOOK
	if VARIANTS[variant].get("race", false):
		car.race_mode = true
	if VARIANTS[variant].get("fog", false):
		car.fog_mode = true
		car.fog = data.get("fog", FogCar.traits_of(car.plate))
	if VARIANTS[variant].get("circus", false):
		car.circus_mode = true
		car.circus = data.get("circus", CircusTruck.traits_of(car.plate))
	car.wanted = plan != null and spawned == plan.wanted_index
	car.at = Vector3(0, 0, SPAWN_FROM)
	car.speed = QueueCar.SPEED
	car.ahead = cars.back() if not cars.is_empty() else null
	spawned += 1
	cars.append(car)
	add_child(car)
	return car


## A car in the fog ran the checkpoint, unwarned (control-neblina.md, step 2): it goes by like one sneaking, and the
## queue's patience goes up.
func overran(car: QueueCar) -> void:
	sneaked += 1
	overruns += 1
	_leave(car, true)
	_set_patience(patience + FogCar.OVERRUN_PATIENCE)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_FOG_OVERRUN")


func _leave(car: QueueCar, sneaked: bool) -> void:
	var i := cars.find(car)
	if i < 0:
		return
	cars.remove_at(i)
	if i < cars.size():
		cars[i].ahead = cars[i - 1] if i > 0 else null
	if is_instance_valid(car):
		passed.emit(car, sneaked)


## A guest's queue shows the host's meter, and its hint when one more car sneaked by (or ran the checkpoint in the
## fog, `host_overruns`).
func show_patience(value: float, host_sneaked: int, host_overruns := 0) -> void:
	if host_sneaked > sneaked:
		sneaked = host_sneaked
		var hint := "HINT_FOG_OVERRUN" if host_overruns > overruns else "HINT_CAR_SNEAKED"
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			cop.show_hint(hint)
	overruns = maxi(overruns, host_overruns)
	_set_patience(value)


func _set_patience(value: float) -> void:
	value = clampf(value, 0.0, FULL)
	if value != patience:
		patience = value
		patience_changed.emit(patience)
