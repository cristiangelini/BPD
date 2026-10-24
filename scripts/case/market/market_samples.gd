class_name MarketSamples
extends Node

## The samples at the market (politico-mercado.md, step 3, decision 120): when the vendor offers (MarketTour.arrived),
## a plate appears in the deputy's hand. LAXED of the 12 stalls, drawn by the seed, hand him one with laxative. When
## the stop ends (MarketTour.tasting) he eats what's in his hand. A cop who grabs the plate takes it from him (he
## complains; untried, it's `snatched`, which costs image in step 5); set down near him while he stands at a stall
## with empty hands, he takes it back. No plate when the stop ends: he asks for his sample and moves on.
## Every number here is (propuesta).

## He ate the sample from stall `index`; `laxative` says whether it was a bad one (the toilet run, step 4).
signal ate(index: int, laxative: bool)
## A cop took his sample away without trying it first.
signal snatched(index: int)

const LAXED := 3
## Where he holds the plate, from his middle on the ground (he faces -Z).
const HAND := Vector3(0.52, 0.62, -0.25)
## A plate set down this close to his hand while he's at a stall goes back into it.
const GIVE_REACH := 1.0
const SETTLED_SPEED := 0.3

var market: MarketLevel
var tour: MarketTour
## The stalls whose sample has laxative, in walking order.
var laxed: Array[int] = []
## The plate in his hand, if any.
var in_hand: SamplePlate
## The plate of each stall he's been offered, by index.
var plates := {}


func setup(the_market: MarketLevel, the_tour: MarketTour, case_seed: int) -> void:
	market = the_market
	tour = the_tour
	laxed = draw_laxed(case_seed, market.stalls.size())
	tour.arrived.connect(_offer)
	tour.tasting.connect(_taste)


## LAXED different stalls out of `count`, drawn by the seed: never the first one (the cops are only getting there)
## and never two in a row.
static func draw_laxed(case_seed: int, count: int) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["market laxative", case_seed])
	var picked: Array[int] = []
	var tries := 0
	while picked.size() < LAXED and tries < 500:
		tries += 1
		var i := rng.randi_range(1, count - 1)
		if not picked.has(i) and not picked.has(i - 1) and not picked.has(i + 1):
			picked.append(i)
	picked.sort()
	return picked


## The vendor of stall `index` puts a sample in his hand.
func _offer(index: int) -> void:
	var plate := SamplePlate.new()
	plate.name = "Sample%d" % index
	plate.kind = market.stalls[index].kind
	plate.laxative = laxed.has(index)
	market.add_child(plate)
	plate.global_position = _hand()
	plates[index] = plate
	plate.bitten.connect(_on_bitten)
	_take(plate)


## A cop who bites a bad one gets cramps (step 4).
func _on_bitten(cop: Cop, laxative: bool) -> void:
	if laxative:
		Cramps.give(cop)


func _take(plate: SamplePlate) -> void:
	in_hand = plate
	plate.freeze = true
	tour.politician.add_collision_exception_with(plate)


func _drop() -> void:
	var plate := in_hand
	in_hand = null
	if is_instance_valid(plate):
		tour.politician.remove_collision_exception_with(plate)
		plate.freeze = false


## The stop at stall `index` is over: he eats what's in his hand, or asks for it.
func _taste(index: int) -> void:
	if not in_hand or not is_instance_valid(in_hand):
		in_hand = null
		tour.politician.say("MARKET_LUSTRE_NO_SAMPLE")
		return
	var plate := in_hand
	_drop()
	var yum := "MARKET_LUSTRE_YUM_%d" % (index % MarketTour.YUMS + 1)
	tour.politician.say("MARKET_LUSTRE_ODD_TASTE" if plate.laxative else yum)
	ate.emit(index, plate.laxative)
	plate.queue_free()


func _physics_process(_delta: float) -> void:
	if in_hand:
		if not is_instance_valid(in_hand):
			in_hand = null
		elif in_hand.is_held():
			var plate := in_hand
			_drop()
			tour.politician.say("MARKET_LUSTRE_SNATCHED")
			if not plate.tasted:
				snatched.emit(tour.stall)
		else:
			in_hand.global_position = _hand()
			in_hand.global_rotation = Vector3.ZERO
		return
	if tour.state != MarketTour.State.STOPPED:
		return
	for plate: SamplePlate in get_tree().get_nodes_in_group("sample_plates"):
		if plate.is_held() or plate.linear_velocity.length() > SETTLED_SPEED or plate.is_queued_for_deletion():
			continue
		if plate.global_position.distance_to(_hand()) < GIVE_REACH:
			_take(plate)
			tour.politician.say("MARKET_LUSTRE_GIVEN_BACK")
			return


func _hand() -> Vector3:
	return tour.politician.global_transform * HAND
