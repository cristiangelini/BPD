extends GutTest

## The bank's perimeter and getaway (robo-banco.md, step 6a, decision 102): the barrier and the cones by the station's
## door, the van boxed in by them, and the vault opening: the robbers still loose take a sack each, and El Oso among
## them gets away in the van, or on foot if it's boxed in.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel


func before_each() -> void:
	bank = LEVEL.instantiate()
	# A base robbery's seed: the party (robo-banco-rehenes.md) has its own tests.
	bank.case_seed = 4
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


## Brings the barrier to the van's nose and PERIMETER_CONES cones around it.
func _box_in() -> void:
	var barrier: Node3D = bank.get_node("Barrier")
	barrier.global_position = bank.van.global_position + bank.van.global_basis * Vector3(0, 0.05, BankLevel.VAN_SIZE.z / 2 + 1.0)
	for i in BankLevel.PERIMETER_CONES:
		var cone: TrafficCone = bank.get_node("Cone%d" % i)
		cone.global_position = bank.van.global_position + Vector3(cos(i * 1.6) * 3.5, 0.05, sin(i * 1.6) * 3.5)
		cone.global_rotation = Vector3.ZERO


func test_the_barrier_and_cones_wait_at_the_station() -> void:
	var door := bank.city.global_transform * CityLayout.door_of("station")
	assert_lt(bank.get_node("Barrier").global_position.distance_to(door), 10.0)
	assert_eq(bank.get_tree().get_nodes_in_group("traffic_cones").size(), BankLevel.CONES)
	assert_false(bank.van_boxed_in())


func test_the_barrier_and_cones_box_the_van_in() -> void:
	_box_in()
	assert_true(bank.van_boxed_in())


func test_cones_without_the_barrier_dont() -> void:
	_box_in()
	bank.get_node("Barrier").global_position += Vector3(30, 0, 0)
	assert_false(bank.van_boxed_in())


func test_the_vault_opens_and_el_oso_gets_away_in_the_van() -> void:
	bank.drill.drilled = BankDrill.DRILL_TIME
	bank.drill._physics_process(0.1)
	assert_eq(bank.bags_taken, 4, "all four loose")
	assert_not_null(bank.chase)
	assert_eq(bank.chase.suspect_id, SuspectCar.ROBBERS_VAN)
	assert_eq(bank.chase.who, "oso")
	assert_false(bank.boss.visible)


func test_boxed_in_he_runs_on_foot() -> void:
	_box_in()
	bank.drill.drilled = BankDrill.DRILL_TIME
	bank.drill._physics_process(0.1)
	assert_eq(bank.chase.suspect_id, SuspectCar.BEAR_ON_FOOT)
	assert_true(ChaseCase.ON_FOOT.has(SuspectCar.BEAR_ON_FOOT))


func test_with_el_oso_in_the_patrol_car_nobody_is_chased() -> void:
	var escort := OwnerEscort.of(bank.boss)
	bank.boss.cuffed(Handcuffs.SECONDS)
	escort.board()
	bank.drill.drilled = BankDrill.DRILL_TIME
	bank.drill._physics_process(0.1)
	assert_null(bank.chase)
	assert_eq(bank.bags_taken, 3)


func test_the_chase_ending_is_kept() -> void:
	bank.drill.drilled = BankDrill.DRILL_TIME
	bank.drill._physics_process(0.1)
	bank.chase.ended.emit(true)
	assert_true(bank.getaway_over)
	assert_true(bank.getaway_caught)
