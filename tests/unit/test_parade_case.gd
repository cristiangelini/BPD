extends GutTest

## Parade step 5 (control-desfile.md, "Cómo es" 4, 6 to 8): El Antifaz taken down from his float can be cuffed: he's
## walked to the patrol car and the crown falls out of his costume (+100 in the patrol car's trunk). On the float
## nobody's cuffed, its driver isn't the thief and a real dancer taken down is no thief either. If his float gets past
## the checkpoint he runs off on it, shooting confetti at every corner that covers the patrol car's windshield.
## Play draws the parade too.

var level: Node3D
var checkpoint: TrafficCheckpoint
var queue: TrafficQueue
var case: TrafficCase


func before_each() -> void:
	level = Node3D.new()
	add_child_autofree(level)
	var city := Node3D.new()
	city.name = "City"
	level.add_child(city)
	checkpoint = TrafficCheckpoint.new()
	level.add_child(checkpoint)
	checkpoint.global_transform = TrafficControlLevel.checkpoint_at()
	var barrier := RoadBarrier.new()
	barrier.freeze = true
	level.add_child(barrier)
	barrier.global_transform = checkpoint.global_transform
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "parade"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, false, false, false, false, false, false, false, true)
	queue.plan = case.plan
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## The `index`th car of the plan at the barrier.
func _at_barrier(index: int) -> QueueCar:
	queue.spawned = index
	var car := queue.spawn()
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func _thief(car: QueueCar) -> ParadeDancer:
	return ParadeFloat.dancers_of(car)[int(car.parade.thief)]


func test_on_the_float_he_can_t_be_cuffed() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	assert_true(car.waiting())
	_thief(car).cuffed(Handcuffs.SECONDS)
	assert_null(case.suspect)
	assert_eq(car.saying(), tr("PARADE_TAKE_DOWN_FIRST"))
	case.detain(car)
	assert_null(case.suspect, "the cuffs on the float go on nobody")
	assert_eq(car.saying(), tr("PARADE_CUFF_A_DANCER"))
	assert_eq(case.innocents, 0)


func test_a_real_dancer_taken_down_is_no_thief() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	var other := ParadeFloat.dancers_of(car)[(int(car.parade.thief) + 1) % ParadeFloat.dancers_of(car).size()]
	car.take_down(other.index)
	assert_eq(case.innocents, 1, "taking her down was the complaint")
	other.cuffed(Handcuffs.SECONDS)
	assert_null(case.suspect)
	assert_eq(car.saying(), tr("PARADE_NOT_THE_THIEF"))
	assert_eq(case.innocents, 1, "no second complaint for the cuffs")


func test_cuffed_el_antifaz_drops_the_crown_worth_100_in_the_patrol_car() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	var thief := _thief(car)
	car.take_down(thief.index)
	var at := thief.global_position
	thief.cuffed(Handcuffs.SECONDS)
	assert_not_null(case.suspect)
	assert_lt(case.suspect.global_position.distance_to(at), 0.5, "taken out where he stood")
	assert_eq(car.state, "pulled_over", "his float pulls over")
	assert_false(car.dancer_down(), "he's off the float's troupe")
	var crown := level.get_node_or_null("ParadeCrown") as ParadeCrown
	assert_not_null(crown)
	assert_lt(crown.global_position.distance_to(at), 1.0, "by his feet")
	assert_eq(case.crown_bonus(), [])
	case.patrol_car.delivered.append(crown)
	assert_eq(case.crown_bonus(), [ParadeCrown.VALUE])
	assert_has(case.extras(), ParadeCrown.VALUE)


func test_past_the_checkpoint_he_runs_off_on_his_float() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	queue.cars.erase(car)
	var traits := car.parade.duplicate(true)
	case._on_passed(car, false)
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.PARADE_FLOAT)
	assert_not_null(case.chase.truck.get_node_or_null("Theme"), "his float's theme on it")
	var dancers := case.chase.truck.get_node("Dancers")
	assert_eq(dancers.get_child_count(), traits.dancers.size() - 1, "the others still dance on it, he drives")
	assert_true(case.chase.drops.confetti)
	assert_eq(case.snapshot().run_off[11], traits, "guests dress his float too")


func test_his_confetti_covers_the_patrol_car_s_windshield_for_3_seconds() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	queue.cars.erase(car)
	case._on_passed(car, false)
	var drops := case.chase.drops
	case.chase.chasing = true
	drops._on_corner(false)
	assert_eq(drops.clouds.size(), 0, "only where he turns")
	drops._on_corner(true)
	assert_eq(drops.clouds.size(), 1)
	var cloud := drops.clouds[0]
	case.patrol_car.global_position = cloud.global_position + Vector3.UP * 0.3
	drops._physics_process(0.016)
	var cover := case.patrol_car.get_node_or_null("ConfettiCover") as Node3D
	assert_not_null(cover)
	assert_true(cover.visible, "in the cloud, the windshield's covered")
	case.patrol_car.global_position = cloud.global_position + Vector3(40, 0.3, 40)
	drops._physics_process(ConfettiCloud.BLIND_SECONDS - 0.5)
	assert_true(cover.visible, "it stays a while after")
	drops._physics_process(1.0)
	assert_false(cover.visible, "then it's off")
	cloud.left = 0.0
	drops._physics_process(0.016)
	assert_eq(drops.clouds.size(), 0, "the cloud's gone")


func test_play_draws_the_parade_too() -> void:
	assert_has(TrafficControlLevel.VARIANTS, "parade")
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=parade"])), "parade")
	var count := {}
	for i in 1000:
		var variant := TrafficControlLevel.variant_from("", PackedStringArray(), i + 1)
		count[variant] = count.get(variant, 0) + 1
	assert_eq(count.size(), TrafficControlLevel.VARIANTS.size())
	assert_between(int(count.get("parade", 0)), 60, 140, "about a tenth")


func test_texts_are_translated() -> void:
	for key in ["PROMPT_PARADE_CROWN", "HINT_PARADE_CROWN", "PARADE_TAKE_DOWN_FIRST", "PARADE_NOT_THE_THIEF",
			"PARADE_CUFF_A_DANCER"]:
		assert_ne(tr(key), key)
