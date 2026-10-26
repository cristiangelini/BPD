extends GutTest

## The double's swaps (politico-doble.md, step 2, decision 220): each time the real deputy walks off, Rolo Calcado
## sneaks round the back of the stage (unmasking the first time) and takes the lectern; there each line of the speech
## is an outrage of his and a stain on the real deputy's image. Led back by a cop, the real one gets the lectern back
## and the double mingles with the crowd until the next time. Led up by a cop who took him for the real one, the double
## takes it himself.

const LEVEL := preload("res://scenes/levels/plaza_double.tscn")
const TEST_PATH := "user://test_partidas/politico_doble_cambiazo.json"
const STEP := 1.0 / 60.0

var rally: PlazaRally
var swap: DoubleSwap
var real_walks: PoliticianWalks
var double_walks: PoliticianWalks
var cop: Cop


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	rally = LEVEL.instantiate()
	rally.case_seed = 4242
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)
	swap = rally.swap
	swap.set_physics_process(false)
	real_walks = PoliticianWalks.of(rally.politician)
	double_walks = PoliticianWalks.of(rally.double)
	real_walks.set_physics_process(false)
	rally.speech.set_physics_process(false)
	rally.crowd.set_physics_process(false)
	rally.speech.start()
	cop = rally.get_node("Cop")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


## Runs the swap (and the double's walks) until `state`, or gives up.
func _swap_until(state: DoubleSwap.State) -> void:
	for i in 4000:
		if swap.state == state:
			return
		swap._physics_process(STEP)
		if double_walks.is_physics_processing():
			double_walks._physics_process(STEP)


## A cop leads the real deputy back to the lectern, and he takes it.
func _lead_real_back() -> void:
	real_walks.use(cop)
	assert_eq(real_walks.state, PoliticianWalks.State.LED)
	rally.politician.global_position = real_walks.podium + Vector3(1.0, 0, 0)
	for i in 600:
		real_walks._physics_process(STEP)
		swap._physics_process(STEP)
		if double_walks.is_physics_processing():
			double_walks._physics_process(STEP)
		if real_walks.state == PoliticianWalks.State.SPEAKING:
			return


func test_the_double_takes_the_lectern_when_the_deputy_walks_off() -> void:
	assert_eq(swap.state, DoubleSwap.State.LURKING)
	assert_false(double_walks.auto_walks, "he never walks off by himself")
	assert_true(real_walks.auto_walks)
	real_walks.walk_off()
	assert_eq(swap.state, DoubleSwap.State.SNEAKING)
	await wait_physics_frames(1)
	_swap_until(DoubleSwap.State.SPEAKING)
	assert_eq(swap.state, DoubleSwap.State.SPEAKING)
	assert_false(rally.double.disguised, "the hat and scarf off behind the stage")
	assert_true(rally.double.tells.visible)
	assert_almost_eq(rally.double.global_position.distance_to(real_walks.podium), 0.0, 0.1, "at the lectern")
	assert_eq(rally.speech.impostor, rally.double)
	assert_eq(swap.swaps, 1)


func test_his_lines_are_outrages_and_stain_the_deputy() -> void:
	real_walks.walk_off()
	_swap_until(DoubleSwap.State.SPEAKING)
	for i in 30:
		rally.speech._physics_process(0.5)
	assert_gt(rally.speech.outrages, 0)
	assert_true(rally.double.said().begins_with("DOUBLE_OUTRAGE_"))
	assert_eq(rally.politician.stains, rally.speech.outrages, "each one a stain on the real deputy")
	assert_eq(rally.politician.marks[0][0], Politician.SHAME)
	assert_null(rally.politician.get_node_or_null("Stain1"), "on his image, not his suit")
	assert_true(rally.politician.said().begins_with("POLITICIAN_SHAMED_"))
	assert_eq(rally.double.stains, 0)


func test_led_back_the_deputy_gets_the_lectern_and_the_double_mingles() -> void:
	real_walks.walk_off()
	_swap_until(DoubleSwap.State.SPEAKING)
	_lead_real_back()
	assert_eq(swap.state, DoubleSwap.State.MINGLING)
	assert_null(rally.speech.impostor, "the speech is the deputy's again")
	assert_ne(double_walks.state, PoliticianWalks.State.SPEAKING, "off the lectern")
	assert_eq(real_walks.state, PoliticianWalks.State.SPEAKING)
	assert_almost_eq(rally.politician.global_position.distance_to(real_walks.podium), 0.0, 0.1)
	var stains := rally.politician.stains
	for i in 30:
		rally.speech._physics_process(0.5)
	assert_eq(rally.politician.stains, stains, "no more outrages")


func test_the_next_time_he_sneaks_up_again() -> void:
	real_walks.walk_off()
	_swap_until(DoubleSwap.State.SPEAKING)
	_lead_real_back()
	real_walks.walk_off()
	assert_eq(swap.state, DoubleSwap.State.SNEAKING)
	_swap_until(DoubleSwap.State.SPEAKING)
	assert_eq(swap.swaps, 2)
	assert_eq(rally.speech.impostor, rally.double)


func test_led_up_by_mistake_the_double_takes_the_lectern() -> void:
	real_walks.walk_off()
	_swap_until(DoubleSwap.State.SPEAKING)
	_lead_real_back()
	# A cop takes the double for the real one and leads him up.
	double_walks.use(cop)
	assert_eq(double_walks.state, PoliticianWalks.State.LED)
	rally.double.global_position = real_walks.podium + Vector3(-1.0, 0, 0)
	for i in 600:
		double_walks._physics_process(STEP)
		swap._physics_process(STEP)
		if swap.state == DoubleSwap.State.SPEAKING:
			break
	assert_eq(swap.state, DoubleSwap.State.SPEAKING)
	assert_eq(rally.speech.impostor, rally.double)
	assert_ne(real_walks.state, PoliticianWalks.State.SPEAKING, "the deputy makes way")


func test_led_by_the_hand_he_doesnt_sneak() -> void:
	rally.double.disguise(false)
	swap.state = DoubleSwap.State.MINGLING
	double_walks.set_physics_process(false)
	double_walks.state = PoliticianWalks.State.GREETING
	double_walks.use(cop)
	real_walks.walk_off()
	assert_eq(swap.state, DoubleSwap.State.MINGLING)
