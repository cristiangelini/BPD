extends GutTest

## The comisario gives the case in his office and the patrol car waits for it (comisaria.md, "El comisario").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func _comisario(house: GrandpaHouse) -> Comisario:
	return (house.get_node("City") as City).comisario


func test_the_comisario_waits_in_his_office() -> void:
	var house := _house()
	var comisario := _comisario(house)
	assert_not_null(comisario)
	assert_eq(comisario.prompt_key(house.get_node("Cop")), "PROMPT_COMISARIO")
	assert_false(house.raid.tip_given, "no case until someone talks to him")


func test_the_car_stays_locked_until_the_tip() -> void:
	var house := _house()
	var cop: Cop = house.get_node("Cop")
	var car := house.raid.car
	car.use(cop)
	assert_eq(car.seat_of(cop), -1, "nobody gets in before the case")
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_COMISARIO_FIRST")
	_comisario(house).use(cop)
	assert_true(house.raid.tip_given)
	car.use(cop)
	assert_gt(car.seat_of(cop), -1, "with the case given, the car opens")


func test_he_gives_the_tip_only_once() -> void:
	# Only a cop with a player at the keys hears the briefing.
	var house := _house()
	var cop: Cop = house.get_node("Cop")
	cop.input_enabled = true
	_comisario(house).use(cop)
	assert_true(house.raid.briefing.visible)
	house.raid.briefing.visible = false
	_comisario(house).use(cop)
	assert_false(house.raid.briefing.visible, "talking again doesn't repeat the briefing")


func test_without_the_station_the_tip_comes_right_away() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.start_at_station = false
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	assert_true(house.raid.tip_given)
	assert_eq(house.raid.car.locked_hint, "")
