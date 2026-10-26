extends GutTest

## El Cromado's getaway (infiltracion-motos.md, step 6, decision 176): found out, he rides off on his "bike", a moped
## with chopper handlebars, at 30 km/h on the street, going "BRRRUM!" with his mouth all the way; caught, it's solved
## with the evidence they have. In Play the biker bar is one of the nine infiltrations.

const LEVEL := preload("res://scenes/levels/biker_bar.tscn")

var bar: BikerBar


func before_each() -> void:
	Campaign.current = null
	bar = LEVEL.instantiate()
	bar.get_node("Cop").input_enabled = false
	add_child_autofree(bar)
	await wait_physics_frames(2)
	bar.dares.set_physics_process(false)
	bar.case.give_tip()


## Solving it leaves El Cromado in custody for the next shift's draw (RaidCase): not for the next test's.
func after_each() -> void:
	PlaceDraw.custody = {}


func test_found_out_el_cromado_rides_off_on_his_moped() -> void:
	bar.suspicion.raise(bar.members[0], 100.0)
	assert_not_null(bar.case.chase)
	assert_eq(bar.case.chase.suspect_id, SuspectCar.CHOPPER_MOPED)
	assert_eq(bar.case.chase.who, "cromado")
	assert_false(bar.cromado.visible, "he isn't polishing it in the workshop")
	var moped: SuspectCar = bar.case.chase.truck
	assert_eq(moped.kind, SuspectCar.CHOPPER_MOPED)
	assert_not_null(moped.get_node("Rider"), "El Cromado riding it")


func test_the_moped_is_slow_and_on_the_street() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.CHOPPER_MOPED], 30.0 / 3.6, 0.01)
	assert_false(SuspectCar.LANES.has(SuspectCar.CHOPPER_MOPED), "on the street, not the sidewalk")
	assert_false(ChaseCase.ON_FOOT.has(SuspectCar.CHOPPER_MOPED), "chased in the patrol car")


func test_it_goes_brrrum_until_he_gets_off() -> void:
	var moped := SuspectCar.new()
	moped.kind = SuspectCar.CHOPPER_MOPED
	moped.points.assign([Vector3(0, 0, 0), Vector3(0, 0, 20)])
	add_child_autofree(moped)
	moped.set_physics_process(false)
	var brrrum: Label3D = moped.get_node("Brrrum")
	assert_eq(brrrum.text, "MOPED_BRRRUM")
	assert_true(brrrum.visible)
	assert_true((moped.get_node("Song") as AudioStreamPlayer3D).autoplay, "the little engine")
	moped.get_off()
	assert_false(brrrum.visible, "quiet once caught")


func test_caught_it_counts_as_solved_with_the_evidence() -> void:
	bar.case.found(bar.evidence.kinds[0])
	bar.suspicion.raise(bar.members[0], 100.0)
	bar.case._on_chase_ended(true)
	assert_true(bar.case.solved())
	assert_eq(bar.case.report().salary, InfiltrationCase.SALARY / 3)


func test_play_draws_the_biker_bar_among_the_infiltrations() -> void:
	assert_has(PlaceDraw.INFILTRATIONS, "biker")
	assert_eq(PlaceDraw.PLACES.get("biker"), "res://scenes/levels/biker_bar.tscn")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "biker":
			drawn = true
			break
	assert_true(drawn)
	TranslationServer.set_locale("es")
	assert_string_contains(tr("HINT_ESCAPE_cromado"), "ciclomotor")
	assert_ne(tr("MOPED_BRRRUM"), "MOPED_BRRRUM")
