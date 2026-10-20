extends GutTest

## The armory's rubber gloves (docs/diseno/comisaria.md, "La armería").

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const TIN_SCENE := preload("res://scenes/props/cookie_tin.tscn")


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(cop)
	return cop


func _tin() -> Evidence:
	var tin: Evidence = TIN_SCENE.instantiate()
	tin.freeze = true
	add_child_autofree(tin)
	return tin


func test_gloved_hands_break_half_as_much() -> void:
	var bare := _cop()
	var gloved := _cop()
	gloved.put_on_gloves()
	var tin_a := _tin()
	var tin_b := _tin()
	bare.get_node("Grabber").grab(tin_a)
	gloved.get_node("Grabber").grab(tin_b)
	var loss_bare := tin_a.hit(7.0)
	var loss_gloved := tin_b.hit(7.0)
	assert_gt(loss_bare, 0.0)
	assert_almost_eq(loss_gloved, loss_bare * Evidence.GLOVES_FACTOR, 0.01)


func test_a_throw_from_gloved_hands_lands_softer() -> void:
	var cop := _cop()
	cop.put_on_gloves()
	var tin := _tin()
	cop.get_node("Grabber").grab(tin)
	cop.get_node("Grabber").release()
	var lost := tin.hit(7.0)
	var plain := _tin()
	assert_almost_eq(lost, plain.hit(7.0) * Evidence.GLOVES_FACTOR, 0.01, "just after letting go it still counts")
	tin.let_go_at -= int((Evidence.GLOVES_GRACE + 1.0) * 1000.0)
	assert_almost_eq(tin.hit(7.0), plain.full_value * Evidence.LOSS_PER_SPEED * (7.0 - tin.safe_speed), 0.01,
		"long after, it's a plain hit")


func test_buy_the_gloves_once_and_every_cop_puts_them_on() -> void:
	var wallet := StationWallet.new()
	wallet.money = 120
	var armory := Armory.new(wallet)
	var cop := _cop()
	assert_eq(armory.choose("gloves", cop), "", "the first E buys them")
	assert_eq(wallet.money, 0)
	assert_eq(armory.choose("gloves", cop), "")
	assert_true(cop.gloves)
	assert_eq(armory.take("gloves", cop), "ARMORY_HAS_GLOVES")
	var other := _cop()
	assert_eq(armory.take("gloves", other), "", "they stay at the armory for the others")
	assert_true(armory.owns("gloves"))
