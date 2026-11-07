extends GutTest

## Don Renglón at the print shop (docs/diseno/allanamiento-imprenta.md, step 4): he walks between the counter and the
## press, adds 5 to his complaint for each cop he sees leaving footprints (once per cop) and 10 each time he sees a
## barrel tip over, and the fax's "enviar prueba" sends him to the chibalete with an urgent order, twice; the third
## time he catches on.

const SCENE := preload("res://scenes/levels/print_shop.tscn")
const LINES := ["LINE_1", "LINE_2", "LINE_3", "LINE_4", "PRINTER", "FIX_1", "FIX_2", "FIX_3", "FIX_DONE", "HURT",
	"DOOR", "SAW", "NOTHING", "OFFENDED", "LAWYER", "CAUGHT_ON", "FOOTPRINTS", "BARREL"]


func _shop() -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.case_seed = 5
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_he_walks_his_round_and_talks() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var owner_npc := shop.owner_npc
	assert_eq(owner_npc.voice, "RENGLON")
	assert_eq(owner_npc.complaint, 0.0)
	var from := owner_npc.global_position
	await wait_physics_frames(30)
	assert_gt(owner_npc.global_position.distance_to(from), 0.2, "he walks")
	for line: String in LINES:
		assert_ne(tr("RENGLON_" + line), "RENGLON_" + line, line)
	assert_ne(tr("PROMPT_PRINT_SHOP_FAX"), "PROMPT_PRINT_SHOP_FAX")


func test_he_sees_a_cop_leaving_footprints_once() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var owner_npc := shop.owner_npc
	owner_npc.set_physics_process(false)
	owner_npc.start_at(2)
	var cop: Cop = shop.get_node("Cop")
	var at := Vector3(-1.0, PrintShop.FLOOR_TOP, 4.0)
	shop.ink.footprint_left.emit(cop, at)
	assert_eq(owner_npc.complaint, PrintShop.SAW_FOOTPRINTS)
	shop.ink.footprint_left.emit(cop, at + Vector3(0.6, 0, 0))
	assert_eq(owner_npc.complaint, PrintShop.SAW_FOOTPRINTS, "once per cop")


func test_he_sees_a_barrel_tip_over() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var owner_npc := shop.owner_npc
	owner_npc.set_physics_process(false)
	owner_npc.global_position = Vector3(-2.0, PrintShop.FLOOR_TOP, -4.5)
	await wait_physics_frames(2)
	shop.tip_barrel(1, Vector3.BACK)
	assert_eq(owner_npc.complaint, PrintShop.SAW_BARREL)


func test_the_fax_sends_him_to_the_type_case_twice() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var fax := shop.fax
	var owner_npc := shop.owner_npc
	fax.button.use(shop.get_node("Cop"))
	assert_true(fax.is_busy())
	assert_true(fax.order.visible, "the order comes out")
	assert_eq(owner_npc.errand(), "printer", "he goes to set it")
	fax.send()
	assert_eq(fax.distractions, 1, "not again so soon")
	fax.fix()
	assert_false(fax.order.visible)
	fax.rest_left = 0.0
	fax.send()
	assert_eq(fax.distractions, 2)
	fax.fix()
	fax.rest_left = 0.0
	fax.send()
	assert_false(fax.is_busy(), "the third time he catches on")
	assert_eq(owner_npc.complaint, PrintShop.CAUGHT_ON)


func test_setting_the_order_he_sees_nothing() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var owner_npc := shop.owner_npc
	owner_npc.start_at(1)
	shop.fax.send()
	for i in 100:
		await wait_physics_frames(10)
		if owner_npc.is_fixing():
			break
	assert_true(owner_npc.is_fixing(), "he got to the chibalete")
	var cop: Cop = shop.get_node("Cop")
	shop.ink.footprint_left.emit(cop, owner_npc.global_position + Vector3(2, 0, 0))
	assert_eq(owner_npc.complaint, 0.0, "his back to everything")
