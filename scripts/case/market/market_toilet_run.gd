class_name MarketToiletRun
extends Node

## The deputy and the laxative (politico-mercado.md, step 4, decision 120): the first sample with laxative he eats sends
## him running to the chemical toilet; he waits banging on the door if someone's in it, stays locked in IN_TOILET and
## then the walk goes on from where he left it (`ran`: 200 less pay in step 6). The second one, he goes home
## (`went_home`, the case is lost, decision 120): he runs out the way out and is gone. Every number here is
## (propuesta).

signal ran(count: int)
signal went_home

enum State { NONE, RUNNING, WAITING, INSIDE, LEAVING, GONE }

const RUN_SPEED := 2.6
const IN_TOILET := 30.0
const ARRIVED := 0.4
const KNOCK_EVERY := 4.0
const KNOCKS := 3
## Past the way out, this far into the street, he's gone.
const STREET := 6.0

var market: MarketLevel
var tour: MarketTour
var toilet: ChemicalToilet
var politician: Politician
var state := State.NONE
## How many bad samples he ate.
var runs := 0
var _path: Array[Vector3] = []
var _knock_left := 0.0
var _knock := 0


func setup(the_market: MarketLevel, the_tour: MarketTour, samples: MarketSamples) -> void:
	market = the_market
	tour = the_tour
	toilet = market.toilet
	politician = tour.politician
	samples.ate.connect(_on_ate)
	toilet.freed.connect(_on_freed)


func _on_ate(_index: int, laxative: bool) -> void:
	if not laxative or state == State.GONE:
		return
	runs += 1
	ran.emit(runs)
	tour.hold(INF)
	if runs >= 2:
		_leave()
		return
	politician.say("MARKET_LUSTRE_RUN")
	state = State.RUNNING
	_path = market.aisle_path(politician.global_position, toilet.to_global(ChemicalToilet.FRONT))
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_LUSTRE_TOILET")


func _leave() -> void:
	politician.say("MARKET_LUSTRE_HOME")
	state = State.LEAVING
	var way_out := Vector3(MarketLevel.EXIT_X, 0, MarketLevel.HALF_Z)
	_path = market.aisle_path(politician.global_position, market.to_global(way_out - Vector3(0, 0, 1.5)))
	_path.append(market.to_global(way_out + Vector3(0, 0, STREET)))
	tour.abort()
	went_home.emit()


func _physics_process(delta: float) -> void:
	match state:
		State.RUNNING, State.LEAVING:
			if _follow(delta):
				if state == State.LEAVING:
					state = State.GONE
					politician.hide()
					politician.collision_layer = 0
					politician.collision_mask = 0
				else:
					state = State.WAITING
		State.WAITING:
			if toilet.is_free():
				state = State.INSIDE
				politician.global_position = toilet.global_position + Vector3.UP * 0.05
				toilet.occupy(politician, IN_TOILET)
				politician.say("MARKET_LUSTRE_INSIDE")
				return
			_knock_left -= delta
			if _knock_left <= 0.0:
				_knock_left = KNOCK_EVERY
				politician.say("MARKET_LUSTRE_KNOCK_%d" % (_knock % KNOCKS + 1))
				_knock += 1


func _on_freed(who: Node3D) -> void:
	if who != politician or state != State.INSIDE:
		return
	state = State.NONE
	politician.global_position = toilet.to_global(ChemicalToilet.FRONT) + Vector3.UP * 0.05
	politician.say("MARKET_LUSTRE_RELIEF")
	tour.release()


## Runs along _path; true once at its end.
func _follow(delta: float) -> bool:
	var to := _path[0] - politician.global_position
	to.y = 0.0
	if to.length() < ARRIVED:
		_path.remove_at(0)
		if _path.is_empty():
			politician.velocity = Vector3.ZERO
			return true
		return false
	var wish := to.normalized() * RUN_SPEED
	politician.look_at(politician.global_position + wish, Vector3.UP)
	var fall := 0.0 if politician.is_on_floor() else politician.velocity.y - GameScale.GRAVITY * delta
	politician.velocity = Vector3(wish.x, fall, wish.z)
	politician.move_and_slide()
	return false
