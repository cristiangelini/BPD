extends GutTest

## Engineer Remache and the bridge as a case (politico-puente.md, step 5, decision 178): Remache stands in the crowd
## with sawdust on his hands and gets nervous when something breaks, the pickup hides the invoices and the beams, cuffed
## he can be walked to the patrol car; the ribbon solves the case, the second dip loses it, and the pay counts dips,
## planks in the water and Remache.

const LEVEL := preload("res://scenes/levels/bridge_park.tscn")

var park: BridgePark
var case: BridgeCase
var cop: Cop


func before_each() -> void:
	park = LEVEL.instantiate()
	park.case_seed = 7
	cop = park.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(park)
	await wait_physics_frames(2)
	case = park.case


func test_remache_stands_in_the_crowd_with_sawdust_on_his_hands() -> void:
	var remache := park.remache
	assert_eq(remache.fans.size(), BridgeRemache.FANS)
	assert_true(remache.engineer.has_sawdust())
	var engineer := park.to_local(remache.engineer.global_position)
	assert_between(engineer.x, -17.0, -11.5, "on the west bank, beside the ramp")
	assert_between(engineer.z, -7.5, -2.5)
	for fan in remache.fans:
		assert_gt(fan.global_position.distance_to(remache.engineer.global_position), 0.8, "nobody on top of him")
	var other_park: BridgePark = LEVEL.instantiate()
	other_park.case_seed = 8
	add_child_autofree(other_park)
	await wait_physics_frames(1)
	assert_ne(other_park.to_local(other_park.remache.engineer.global_position).snapped(Vector3.ONE),
		engineer.snapped(Vector3.ONE), "another seed, another spot")


func test_he_gets_nervous_when_something_breaks() -> void:
	park.breaks.broke.emit("rail", 2)
	assert_string_starts_with(park.remache.engineer.said(), "BRIDGE_ENGINEER_NERVOUS_")


func test_the_pickup_hides_the_invoices_and_the_beams() -> void:
	var remache := park.remache
	watch_signals(remache)
	assert_eq(remache.beams.prompt_key(cop), "PROMPT_LIFT_TARP")
	var tarp_at := remache.beams.cover.global_position
	remache.beams.use(cop)
	assert_signal_emitted_with_parameters(remache, "found_clue", ["beams"])
	assert_eq(remache.beams.prompt_key(cop), "PROMPT_LOOK_BEAMS")
	assert_gt(remache.beams.cover.global_position.distance_to(tarp_at), 1.0, "the tarp lies aside")
	var van := park.to_local(remache.beams.cover.global_position)
	assert_lt(van.x, BridgePark.VAN_AT.x - BridgePark.VAN_SIZE.x / 2, "away from the pickup, not into it")
	remache.invoices.use(cop)
	assert_eq(case.clues.size(), 2)


func test_cuffed_he_can_be_walked_to_the_car() -> void:
	var engineer := park.remache.engineer
	assert_eq(engineer.prompt_key(cop), "PROMPT_TALK_ENGINEER")
	engineer.cuffed(Handcuffs.SECONDS)
	assert_eq(engineer.said(), "BRIDGE_ENGINEER_CUFFED")
	assert_eq(engineer.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	assert_false(park.remache.loose())
	OwnerEscort.of(engineer).board()
	assert_true(case.jailed)


func test_the_ribbon_solves_it() -> void:
	assert_false(case.tip_given, "not before seeing the comisario")
	case.give_tip()
	park.remache.engineer.cuffed(Handcuffs.SECONDS)
	park.ceremony.finished.emit()
	assert_true(case.solved())
	assert_null(case.chase, "Remache is cuffed: nobody runs")
	await wait_seconds(BridgeCase.SHIFT_DELAY + 0.5)
	assert_true(case.shift_over)


func test_the_second_dip_loses_it() -> void:
	park.dip.dipped.emit(1)
	park.dip.went_home.emit()
	assert_true(case.went_home)
	park.ceremony.finished.emit()
	assert_false(case.solved(), "no ribbon once he's gone")
	assert_eq(case.report().salary, 0)


func test_the_pay_counts_dips_planks_and_remache() -> void:
	case.ribbon_cut = true
	assert_eq(case.report().salary, BridgeCase.SALARY)
	park.dip.dipped.emit(1)
	assert_eq(case.report().salary, BridgeCase.SALARY - BridgeCase.DIP)
	for i in 2:
		var spare := park.repairs.spares[i]
		spare.global_position = park.to_global(Vector3(-4 + i * 2, BridgePark.WATER_TOP - 0.1, 6))
	assert_eq(case.planks_in_water(), 2)
	assert_eq(case.report().salary, BridgeCase.SALARY - BridgeCase.DIP - 2 * BridgeCase.PLANK)
	assert_false(case.report().approved, "a dip and two planks: under the quota")
	park.remache.jailed.emit()
	var pay := case.report()
	assert_eq(pay.salary, BridgeCase.SALARY - BridgeCase.DIP - 2 * BridgeCase.PLANK + BridgeCase.ENGINEER)
	assert_eq(pay.quota, BridgeCase.QUOTA)
	assert_true(pay.approved, "Remache in the car brings it back over")


func test_the_planilla_follows_the_ceremony() -> void:
	case.give_tip()
	var rows := case.rows()
	assert_eq(rows[0].text, "OBJ_BRIDGE_GUARD")
	assert_eq(rows[-1].text, "OBJ_BRIDGE_KEEP_DRY")
	park.dip.dipped.emit(1)
	assert_eq(case.rows()[-1].text, "OBJ_BRIDGE_WET")
	park.ceremony.finished.emit()
	assert_eq(case.rows()[-1].text, "OBJ_BRIDGE_OVER")
	assert_true(case.rows()[1].done, "photos and ribbon done")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["BRIEF_BRIDGE_C", "HINT_BRIDGE_BEAMS", "BRIDGE_ENGINEER_NERVOUS_3", "OBJ_BRIDGE_CLUES",
			"PROMPT_LIFT_TARP"]:
		assert_ne(tr(key), key)
