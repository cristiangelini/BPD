extends GutTest

## Taking the place's owner away to be interrogated (interrogatorio.md, "El dueño del allanamiento", decision 93).

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")
const GROOMER_SCENE := preload("res://scenes/npc/dog_groomer.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	house.get_node("Cop").input_enabled = false
	house.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(house)
	return house


func test_the_cuffed_grandpa_walks_after_the_cop_into_the_car() -> void:
	var house := _house()
	await wait_physics_frames(30)
	var cop: Cop = house.get_node("Cop")
	var grandpa := house.grandpa
	var car := house.car
	var escort := OwnerEscort.of(grandpa)
	assert_not_null(escort, "the raid gives its owner an escort")
	assert_eq(grandpa.prompt_key(cop), "PROMPT_GRANDPA", "uncuffed, E is still his story")
	cop.global_position = car.to_global(Vector3(1.5, 0.1, -0.5))
	grandpa.global_position = car.to_global(Vector3(1.5, 0.1, 6.0))
	grandpa.cuffed(Handcuffs.SECONDS)
	var before := grandpa.complaint
	assert_eq(grandpa.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	grandpa.use(cop)
	assert_eq(escort.escorted_by, cop)
	assert_almost_eq(grandpa.complaint, before + OwnerEscort.TAKEN, 0.01, "taking him by the arm makes him complain")
	assert_eq(grandpa.prompt_key(cop), "PROMPT_LET_GO_OWNER")
	await wait_physics_frames(300)
	assert_true(escort.in_car, "walked up to the car, he gets in")
	assert_eq(car.prisoner, grandpa)
	assert_eq(car.passengers().size(), 0, "he takes no cop's seat")
	assert_true(grandpa.is_cuffed())
	var custody := house.raid.custody()
	assert_eq(custody.owner, "grandpa")
	assert_eq(custody.story, GrandpaHouse.BINGO.id)
	assert_gt(int(custody.missed), 0, "the book never made it to the trunk")
	assert_eq((custody.slips as Array).size(), grandpa.slips.size())


func test_letting_go_leaves_him_cuffed_where_he_is() -> void:
	var house := _house()
	await wait_physics_frames(30)
	var cop: Cop = house.get_node("Cop")
	var grandpa := house.grandpa
	grandpa.cuffed(Handcuffs.SECONDS)
	grandpa.use(cop)
	grandpa.use(cop)
	assert_null(OwnerEscort.of(grandpa).escorted_by)
	assert_true(grandpa.is_cuffed())
	assert_eq(house.raid.custody(), {}, "nobody in the car, nobody to interrogate")


func test_ramiro_can_be_cuffed_and_taken() -> void:
	var ramiro: DogGroomer = GROOMER_SCENE.instantiate()
	add_child_autofree(ramiro)
	assert_eq(Handcuffs.cuffable(ramiro), ramiro)
	ramiro.cuffed(1.0)
	assert_true(ramiro.is_cuffed())
	assert_almost_eq(ramiro.complaint, DogGroomer.CUFFED, 0.01)
	assert_eq(ramiro.prompt_key(null), "", "with no raid around, E does nothing")


func test_the_campaign_keeps_who_is_in_custody() -> void:
	var campaign := Campaign.new()
	campaign.custody = {"owner": "baker", "story": "wedding", "slips": ["Algo"], "missed": 120}
	var back := Campaign.from_dict(JSON.parse_string(JSON.stringify(campaign.to_dict())))
	assert_eq(back.custody.owner, "baker")
	assert_eq(int(back.custody.missed), 120)
	assert_eq(Campaign.from_dict({}).custody, {})
