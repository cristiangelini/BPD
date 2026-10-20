extends GutTest

## The armory and the armero (docs/diseno/comisaria.md, "La armería").

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")
const CATALOG := {
	"ram": {"name": "ARMORY_RAM", "about": "ARMORY_RAM_ABOUT", "price": 0},
	"donuts": {"name": "x", "about": "x", "price": 30},
}


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	return cop


func test_the_ram_is_free_and_always_there() -> void:
	var armory := Armory.new(StationWallet.new())
	var cop := _cop()
	assert_true(armory.owns("ram"))
	assert_eq(armory.take("ram", cop), "")
	assert_not_null(cop.ram, "the ram is in the cop's hands")
	assert_eq(armory.take("ram", cop), "ARMORY_HAS_RAM", "one ram per cop")
	assert_eq(armory.take("ram", _cop()), "", "another cop takes another one")


func test_buying_spends_the_cash_box_and_keeps_the_item() -> void:
	var wallet := StationWallet.new()
	var armory := Armory.new(wallet, CATALOG)
	assert_eq(armory.buy("donuts"), "ARMORY_NO_MONEY")
	wallet.money = 50
	assert_false(armory.owns("donuts"))
	assert_eq(armory.buy("donuts"), "")
	assert_eq(wallet.money, 20)
	assert_true(armory.owns("donuts"), "bought for good")
	assert_eq(armory.buy("donuts"), "ARMORY_ALREADY_OWNED")


func test_the_menu_takes_the_ram_and_frees_the_cop() -> void:
	var cop := _cop()
	var menu := ArmoryMenu.new()
	add_child_autofree(menu)
	menu.open(Armory.new(StationWallet.new()), cop)
	assert_true(menu.visible)
	assert_true(cop.is_busy(), "the cop stands still at the counter")
	menu.choose()
	assert_not_null(cop.ram)
	assert_false(menu.visible, "taking something closes the list")
	assert_false(cop.is_busy())


func test_the_armero_waits_behind_the_counter() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	var cop: Cop = house.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(3)
	var armero: Armero = (house.get_node("City") as City).armero
	assert_false(house.has_node("RamPickup"), "the ram comes from the armory, not from the grandpa's door")
	# From the guard room side of the counter, looking at him, E reaches him.
	cop.global_position = armero.to_global(Vector3(0, 0.1, 1.7))
	cop.look_at(Vector3(armero.global_position.x, cop.global_position.y, armero.global_position.z), Vector3.UP)
	await wait_physics_frames(2)
	assert_eq(cop.current_prompt(), "PROMPT_ARMERO")
	assert_true(cop.use())
	assert_true(armero.menu.visible)


func test_the_armero_spends_the_campaign_cash_box() -> void:
	var before := Campaign.current
	var campaign := Campaign.new()
	Campaign.current = campaign
	var armero := Armero.new()
	Campaign.current = before
	assert_eq(armero.armory.wallet, campaign, "with a campaign, the armory uses its money and items")
	armero.free()
	armero = Armero.new()
	if before == null:
		assert_true(armero.armory.wallet is StationWallet, "without one, a cash box for this shift")
	armero.free()
