extends GutTest

## The Chef Flambé's getaway (infiltracion-restaurante.md, step 6, decision 174): found out, he rides off on the
## restaurant's delivery scooter at 40 km/h, with the giant thermal box on the back, and loses a pizza at every corner
## he turns; caught, it's solved with the evidence they have. In Play the restaurant is one of the seven infiltrations.

const LEVEL := preload("res://scenes/levels/restaurant_hall.tscn")

var hall: RestaurantHall


func before_each() -> void:
	Campaign.current = null
	hall = LEVEL.instantiate()
	hall.get_node("Cop").input_enabled = false
	add_child_autofree(hall)
	await wait_physics_frames(2)
	hall.orders.set_process(false)
	hall.case.give_tip()


## Solving it leaves the Chef in custody for the next shift's draw (RaidCase): not for the next test's.
func after_each() -> void:
	PlaceDraw.custody = {}

func test_found_out_the_chef_rides_off_on_the_scooter() -> void:
	hall.suspicion.raise(hall.members[0], 100.0)
	assert_not_null(hall.case.chase)
	assert_eq(hall.case.chase.suspect_id, SuspectCar.PIZZA_SCOOTER)
	assert_eq(hall.case.chase.who, "flambe")
	assert_false(hall.chef.visible, "he isn't in the kitchen")
	var scooter: SuspectCar = hall.case.chase.truck
	assert_eq(scooter.kind, SuspectCar.PIZZA_SCOOTER)
	assert_not_null(scooter.get_node("Rider"), "the Chef riding it")


func test_the_scooter_is_fast_and_on_the_street() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.PIZZA_SCOOTER], 40.0 / 3.6, 0.01)
	assert_false(SuspectCar.LANES.has(SuspectCar.PIZZA_SCOOTER), "on the street, not the sidewalk")
	assert_false(ChaseCase.ON_FOOT.has(SuspectCar.PIZZA_SCOOTER), "chased in the patrol car")


func test_it_loses_a_pizza_at_every_corner_it_turns() -> void:
	hall.suspicion.raise(hall.members[0], 100.0)
	var drops := hall.case.chase.drops
	drops._on_corner(false)
	assert_true(drops.furniture.is_empty(), "straight on, nothing falls")
	drops._on_corner(true)
	assert_eq(drops.furniture.size(), 1)
	var pizza := drops.furniture[0] as ChaseFurniture
	assert_true(pizza.pizza)
	assert_lt(pizza.piece, ChaseDrops.PIZZAS.size())
	assert_eq(pizza.net_setup().pizza, true, "online the guests' copy is a pizza too")
	assert_almost_eq(pizza.mass, 0.5, 0.01, "light: a trail, not a wall")


func test_caught_it_counts_as_solved_with_the_evidence() -> void:
	hall.case.found(hall.evidence.kinds[0])
	hall.suspicion.raise(hall.members[0], 100.0)
	hall.case._on_chase_ended(true)
	assert_true(hall.case.solved())
	assert_eq(hall.case.report().salary, InfiltrationCase.SALARY / 3)


func test_play_draws_the_restaurant_among_the_infiltrations() -> void:
	assert_has(PlaceDraw.INFILTRATIONS, "restaurant")
	assert_eq(PlaceDraw.PLACES.get("restaurant"), "res://scenes/levels/restaurant_hall.tscn")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "restaurant":
			drawn = true
			break
	assert_true(drawn)
	TranslationServer.set_locale("es")
	assert_string_contains(tr("HINT_ESCAPE_flambe"), "pizzas")
