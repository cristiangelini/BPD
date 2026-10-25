extends GutTest

## Fruit truck step 2 (control-frutas.md): the watermelons ride frozen in the truck's bed, come off when grabbed, sound
## different when tapped (normal or odd), only split with a hard hit and show what's inside: two halves, juice, and
## the gold watches in a hollow one.

var street: Node3D
var floor_body: StaticBody3D


func before_each() -> void:
	street = Node3D.new()
	add_child_autofree(street)
	floor_body = StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(20, 1, 20)
	shape.shape = box
	shape.position.y = -0.5
	floor_body.add_child(shape)
	street.add_child(floor_body)


func _melon(kind := "normal") -> Watermelon:
	var melon := Watermelon.new()
	melon.kind = kind
	street.add_child(melon)
	melon.global_position = Vector3(0, 0.5, 0)
	return melon


func test_it_weighs_8_kg_so_one_cop_can_carry_it() -> void:
	var melon := _melon()
	assert_eq(melon.mass, Watermelon.KG)
	assert_lte(melon.mass, GameScale.COP_CARRY_KG)


func test_a_normal_one_knocks_and_the_others_sound_odd() -> void:
	var normal := _melon()
	normal.use(null)
	assert_eq(normal.saying(), tr("MELON_TAP"))
	assert_eq(normal.taps, 1)
	for kind in ["hollow", "overripe"]:
		var odd := _melon(kind)
		odd.use(null)
		assert_eq(odd.saying(), tr("MELON_TAP_ODD"), kind)


func test_a_soft_hit_does_not_split_it() -> void:
	var melon := _melon()
	assert_false(melon.hit(Watermelon.SPLIT_SPEED - 0.5))
	assert_false(melon.is_broken)


func test_a_hard_hit_splits_it_into_halves_and_juice() -> void:
	var melon := _melon()
	assert_true(melon.hit(Watermelon.SPLIT_SPEED + 1.0))
	await wait_physics_frames(2)
	assert_eq(_count(MelonHalf), 2)
	assert_eq(get_tree().get_nodes_in_group("melon_juice").size(), 1)
	assert_eq(_count(GoldWatch), 0)


func test_a_hollow_one_has_the_gold_watches() -> void:
	var melon := _melon("hollow")
	melon.hit(INF)
	await wait_physics_frames(2)
	assert_eq(_count(GoldWatch), Watermelon.WATCHES)


func test_an_overripe_one_is_only_mush() -> void:
	var melon := _melon("overripe")
	melon.hit(INF)
	await wait_physics_frames(2)
	assert_eq(_count(GoldWatch), 0)
	for half in street.get_children().filter(func(n: Node) -> bool: return n is MelonHalf):
		assert_true((half as MelonHalf).mushy)


func test_thrown_hard_at_the_ground_it_splits() -> void:
	var melon := _melon()
	melon.global_position = Vector3(0, 1.4, 0)
	melon.linear_velocity = Vector3(2.8, -6.0, 0)
	await wait_physics_frames(30)
	assert_false(is_instance_valid(melon) and not melon.is_broken, "split on the ground")


func test_set_down_gently_it_stays_whole() -> void:
	var melon := _melon()
	melon.global_position = Vector3(0, 0.3, 0)
	await wait_physics_frames(40)
	assert_true(is_instance_valid(melon))
	assert_false(melon.is_broken)


func test_in_the_bed_it_rides_frozen_and_grabbing_takes_it_off() -> void:
	var checkpoint := TrafficCheckpoint.new()
	street.add_child(checkpoint)
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "fruit_truck"
	queue.set_physics_process(false)
	street.add_child(queue)
	var car := queue.spawn()
	car.set_physics_process(false)
	var melons := car.bed_melons()
	assert_eq(melons.size(), car.melons())
	var melon := melons[0]
	assert_true(melon.freeze)
	assert_false(melon.hit(50.0), "never splits in the bed")
	melon.hold(1, melon.global_position + Vector3.UP)
	assert_false(melon.in_bed)
	assert_false(melon.freeze)
	assert_eq(melon.get_parent(), street, "loose on the street, the queue's level")
	assert_eq(car.bed_melons().size(), car.melons() - 1)
	melon.let_go(1)


func test_the_texts_are_translated() -> void:
	for key in ["PROMPT_TAP_MELON", "PROMPT_TAP_MELON_HELD", "MELON_TAP", "MELON_TAP_ODD", "PROMPT_GOLD_WATCH"]:
		assert_ne(tr(key), key)


func _count(type: Variant) -> int:
	return street.get_children().filter(func(n: Node) -> bool: return is_instance_of(n, type)).size()
