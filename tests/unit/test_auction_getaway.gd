extends GutTest

## Don Martillo's getaway (infiltracion-subasta.md, step 6, decision 177): found out, he drives off in the gallery's
## electric cart at 20 km/h on the street, a giant painting tied behind that sways out of every corner it turns; caught,
## it's solved with the evidence they have. In Play the auction house is one of the ten infiltrations.

const LEVEL := preload("res://scenes/levels/auction_house.tscn")

var house: AuctionHouse


func before_each() -> void:
	Campaign.current = null
	house = LEVEL.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)
	house.sale.set_physics_process(false)
	house.case.give_tip()


## Solving it leaves Don Martillo in custody for the next shift's draw (RaidCase): not for the next test's.
func after_each() -> void:
	PlaceDraw.custody = {}


## A cart on its own, driving `points`.
func _cart(points: Array[Vector3]) -> SuspectCar:
	var cart := SuspectCar.new()
	cart.kind = SuspectCar.GALLERY_CART
	cart.points.assign(points)
	add_child_autofree(cart)
	return cart


func test_found_out_don_martillo_drives_off_in_the_gallery_cart() -> void:
	house.suspicion.raise(house.members[0], 100.0)
	assert_not_null(house.case.chase)
	assert_eq(house.case.chase.suspect_id, SuspectCar.GALLERY_CART)
	assert_eq(house.case.chase.who, "martillo")
	assert_false(house.martillo.visible, "he isn't at his podium")
	var cart: SuspectCar = house.case.chase.truck
	assert_eq(cart.kind, SuspectCar.GALLERY_CART)
	assert_not_null(cart.get_node("Rider"), "Don Martillo driving it")
	assert_not_null(cart.get_node("Painting"), "the giant painting tied behind")


func test_the_cart_is_slow_and_on_the_street() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.GALLERY_CART], 20.0 / 3.6, 0.01)
	assert_false(SuspectCar.LANES.has(SuspectCar.GALLERY_CART), "on the street, not the sidewalk")
	assert_false(ChaseCase.ON_FOOT.has(SuspectCar.GALLERY_CART), "chased in the patrol car")


func test_the_painting_sways_out_of_a_corner_and_settles() -> void:
	var cart := _cart([Vector3(0, 0, 0), Vector3(0, 0, 0.5), Vector3(20, 0, 0.5)])
	cart.set_physics_process(false)
	cart.next = 1
	cart.global_position = Vector3(0, 0, 0.4)
	cart._physics_process(0.016)
	assert_eq(cart.sways, 1, "it turned at the corner")
	var top := 0.0
	for i in 20:
		cart._physics_process(0.016)
		top = maxf(top, absf(cart.sway))
	assert_gt(top, 0.1, "it leaned")
	assert_lte(top, SuspectCar.SWAY_MAX)
	assert_almost_eq((cart.get_node("Painting") as Node3D).rotation.z, cart.sway, 0.001)
	cart.driving = false
	for i in 400:
		cart._physics_process(0.016)
	assert_almost_eq(cart.sway, 0.0, 0.02, "and settled")


func test_a_left_and_a_right_turn_sway_it_opposite_ways() -> void:
	var lean := []
	for out_x: float in [20.0, -20.0]:
		var cart := _cart([Vector3(0, 0, 0), Vector3(0, 0, 0.5), Vector3(out_x, 0, 0.5)])
		cart.set_physics_process(false)
		cart.next = 1
		cart.global_position = Vector3(0, 0, 0.4)
		cart._physics_process(0.016)
		cart.driving = false
		for i in 5:
			cart._physics_process(0.016)
		lean.append(cart.sway)
	assert_lt(lean[0] * lean[1], 0.0, "opposite sides")


func test_the_lean_reaches_a_guest_copy() -> void:
	var cart := _cart([Vector3(0, 0, 0), Vector3(0, 0, 20)])
	cart.set_physics_process(false)
	cart._lean(0.3)
	var state: Variant = cart.net_state()
	var copy := _cart([Vector3(0, 0, 0), Vector3(0, 0, 20)])
	copy.set_physics_process(false)
	copy.apply_net_state(state)
	assert_almost_eq(copy.sway, 0.3, 0.001)
	assert_true(copy.get_node("Rider").visible, "still driving")
	cart.get_off()
	copy.apply_net_state(cart.net_state())
	assert_false(copy.get_node("Rider").visible, "got off on the copy too")


func test_caught_it_counts_as_solved_with_the_evidence() -> void:
	house.case.found(house.evidence.kinds[0])
	house.suspicion.raise(house.members[0], 100.0)
	house.case._on_chase_ended(true)
	assert_true(house.case.solved())
	assert_eq(house.case.report().salary, InfiltrationCase.SALARY / 3)


func test_play_draws_the_auction_house_among_the_infiltrations() -> void:
	assert_has(PlaceDraw.INFILTRATIONS, "auction")
	assert_eq(PlaceDraw.PLACES.get("auction"), "res://scenes/levels/auction_house.tscn")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "auction":
			drawn = true
			break
	assert_true(drawn)
	TranslationServer.set_locale("es")
	assert_string_contains(tr("HINT_ESCAPE_martillo"), "carrito")
