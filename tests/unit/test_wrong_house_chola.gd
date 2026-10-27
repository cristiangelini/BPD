extends GutTest

## Doña Chola (docs/diseno/casa-equivocada.md, step 2): the innocent neighbor's complaint rises twice as fast, what
## breaks in her house costs double, a cop can say sorry once, and her mate comes with gossip.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")
const STEP := 1.0 / 60.0

var place: WrongHouse
var chola: NeighborChola
var cop: Cop


func before_each() -> void:
	place = SCENE.instantiate()
	place.case_seed = 77
	cop = place.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(place)
	await wait_physics_frames(2)
	chola = place.chola
	chola.set_physics_process(false)


func test_she_lives_in_the_house_that_is_not_the_guilty_one() -> void:
	assert_ne(place.chola_house(), place.guilty)
	assert_eq(WrongHouse.house_of(chola.global_position), place.chola_house())
	assert_eq(chola.complaint, 0.0)


func test_what_breaks_in_her_house_costs_double_and_she_sees_it() -> void:
	var hers: Ornament = place.ornaments[place.chola_house()][0]
	place._on_ornament_broken(hers.global_position, place.chola_house())
	assert_eq(place.fines, Ornament.FINE * WrongHouse.CHOLA_FINES)
	assert_eq(chola.complaint, NeighborChola.SAW_BREAK, "she saw it: twice the grandpa's 10")
	var theirs: Ornament = place.ornaments[place.guilty][0]
	place._on_ornament_broken(theirs.global_position, place.guilty)
	assert_eq(place.fines, Ornament.FINE * (WrongHouse.CHOLA_FINES + 1), "next door it's the usual fine")
	assert_eq(chola.complaint, NeighborChola.SAW_BREAK, "and she doesn't see through the party wall")


func test_pushes_and_her_rammed_door_count_double() -> void:
	assert_true(chola.struck())
	assert_eq(chola.complaint, NeighborChola.STRUCK)
	assert_false(chola.struck(), "once a second at most")
	place.doors[place.chola_house()].broken.emit()
	assert_eq(chola.complaint, NeighborChola.STRUCK + NeighborChola.DOOR_BROKEN)
	place.doors[place.guilty].broken.emit()
	assert_eq(chola.complaint, NeighborChola.STRUCK + NeighborChola.DOOR_BROKEN, "the other door isn't hers")


func test_at_a_hundred_she_calls_her_lawyer() -> void:
	watch_signals(chola)
	for i in 4:
		chola.saw(chola.global_position + Vector3(0, 1.0, 1.0))
	assert_signal_not_emitted(chola, "lawyer_called")
	chola.saw(chola.global_position + Vector3(0, 1.0, 1.0))
	assert_signal_emitted(chola, "lawyer_called")
	assert_true(chola.has_called_lawyer)


func test_saying_sorry_takes_holding_e_and_works_once_per_cop() -> void:
	chola._set_complaint(50.0)
	cop.global_position = chola.global_position + Vector3(0, 0, 1.2)
	assert_eq(chola.prompt_key(cop), "PROMPT_APOLOGIZE")
	chola.use(cop)
	assert_eq(cop.turning, chola, "holding E")
	for i in int(NeighborChola.APOLOGY_TIME / STEP) - 10:
		chola._physics_process(STEP)
	assert_eq(chola.complaint, 50.0, "not yet")
	for i in 20:
		chola._physics_process(STEP)
	assert_almost_eq(chola.complaint, 50.0 - NeighborChola.APOLOGY, 0.01)
	assert_null(cop.turning, "done, E free again")
	assert_eq(chola.prompt_key(cop), "PROMPT_TAKE_MATE", "and now the mate")
	chola.use(cop)
	assert_almost_eq(chola.complaint, 50.0 - NeighborChola.APOLOGY, 0.01, "sorry only works once")
	assert_eq(chola.prompt_key(cop), "")


func test_walking_off_or_letting_go_stops_the_apology() -> void:
	chola._set_complaint(50.0)
	cop.global_position = chola.global_position + Vector3(0, 0, 1.2)
	chola.use(cop)
	chola._physics_process(STEP)
	cop.global_position = chola.global_position + Vector3(0, 0, NeighborChola.REACH + 1.0)
	chola._physics_process(STEP)
	assert_null(chola.apologizing, "walked off")
	cop.global_position = chola.global_position + Vector3(0, 0, 1.2)
	chola.use(cop)
	chola.end_turn(cop)
	for i in int(NeighborChola.APOLOGY_TIME / STEP) + 10:
		chola._physics_process(STEP)
	assert_eq(chola.complaint, 50.0, "let go of E")
	assert_eq(chola.prompt_key(cop), "PROMPT_APOLOGIZE", "can try again")


func test_her_mate_comes_with_the_gossip() -> void:
	chola.apologized.append(cop)
	chola.gossip = "CHOLA_NO_GOSSIP"
	watch_signals(chola)
	chola.use(cop)
	assert_signal_emitted_with_parameters(chola, "gossiped", ["CHOLA_NO_GOSSIP"])
	assert_eq(chola.said(), "CHOLA_NO_GOSSIP")
	chola.use(cop)
	assert_signal_emit_count(chola, "gossiped", 1, "one mate per cop")
