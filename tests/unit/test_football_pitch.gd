extends GutTest

## The football pitch (politico-futbol.md, step 1, decision 179): its own lot in the city, the field with its lines and
## two goals a ball stops in, the stand, the benches, the stretcher and the cup.

const LEVEL := preload("res://scenes/levels/football_pitch.tscn")

var pitch: FootballPitch


func before_each() -> void:
	pitch = LEVEL.instantiate()
	pitch.case_seed = 7
	pitch.get_node("Cop").input_enabled = false
	add_child_autofree(pitch)
	await wait_physics_frames(2)


func test_it_has_its_own_block_in_the_city() -> void:
	var lot := CityLayout.place("football_pitch")
	assert_eq(lot.block, Vector2i(4, 4))
	assert_true(CityLayout.is_park(lot.block), "grass and no filler buildings")
	assert_false(CityLayout.fillers().any(func(f: Dictionary) -> bool: return f.block == lot.block))
	assert_eq(PlaceDraw.PLACES.get("football", ""), "res://scenes/levels/football_pitch.tscn")


func test_the_field_fits_the_lot() -> void:
	var length := FootballPitch.HALF_LENGTH + FootballPitch.GOAL.z
	assert_lt(length, FootballPitch.HALF, "goals and all inside the lot")
	assert_lt(absf(FootballPitch.CENTER.z) + FootballPitch.HALF_WIDTH, FootballPitch.HALF - 3.0)
	assert_true(pitch.on_field(pitch.to_global(FootballPitch.CENTER)))
	assert_false(pitch.on_field(pitch.to_global(FootballPitch.CUP_TABLE_AT)), "the cup's table is off the field")


func test_two_goals_face_each_other() -> void:
	assert_eq(pitch.goals.size(), 2)
	assert_lt(pitch.goals[0].position.x, 0.0, "west first")
	assert_gt(pitch.goals[1].position.x, 0.0)


func test_a_ball_stops_in_the_net() -> void:
	var ball := RigidBody3D.new()
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.11
	shape.shape = sphere
	ball.add_child(shape)
	ball.mass = 0.45
	# The match's ball (step 2) uses continuous collision too.
	ball.continuous_cd = true
	pitch.add_child(ball)
	ball.position = FootballPitch.goal_at(1.0) + Vector3(-3.0, 0.5, 0)
	ball.linear_velocity = Vector3(20, 0, 0)
	await wait_physics_frames(60)
	var local := ball.position
	assert_gt(local.x, FootballPitch.goal_at(1.0).x, "over the line")
	assert_lt(local.x, FootballPitch.goal_at(1.0).x + FootballPitch.GOAL.z, "and caught by the net")


func test_the_cup_and_the_stretcher_are_there() -> void:
	assert_not_null(pitch.get_node_or_null("Built/Cup"))
	assert_not_null(pitch.get_node_or_null("Built/Stretcher"))


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PLACE_FOOTBALL_PITCH", "FOOTBALL_BANNER", "FOOTBALL_STALL"]:
		assert_ne(tr(key), key)
