extends GutTest

## Values copied from docs/diseno/escala.md: a change here means the doc changed too.


func test_cop_body() -> void:
	assert_eq(GameScale.COP_HEIGHT, 1.55)
	assert_eq(GameScale.EYE_HEIGHT, 1.35)
	assert_eq(GameScale.CROUCH_HEIGHT, 1.1)


func test_speeds() -> void:
	assert_eq(GameScale.WALK_SPEED, 4.0)
	assert_eq(GameScale.RUN_SPEED, 6.5)
	assert_eq(GameScale.CROUCH_SPEED, 2.0)


func test_jump_reaches_one_meter() -> void:
	var v := GameScale.jump_velocity()
	assert_almost_eq(v * v / (2.0 * GameScale.GRAVITY), GameScale.JUMP_HEIGHT, 0.001)
