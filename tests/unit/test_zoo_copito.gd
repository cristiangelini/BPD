extends GutTest

## Copito hidden in the zoo (escena-zoo.md, step 4): Zoo's hideouts, search and feeding log, Copito carried back to
## his floe (+100), the penguins' gate and the sneezing plush penguins.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A zoo with its case set up, and a cop at hand.
func _zoo_case(seed_value: int) -> Array:
	var zoo := Zoo.new()
	zoo.case_seed = seed_value
	add_child_autofree(zoo)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = zoo
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [zoo, case, cop]


func _hint(cop: Cop) -> String:
	return cop.get_node("Hud/Hint").text


## A seed whose case hides Copito in `spot`.
func _seed_for(spot: String) -> int:
	for seed_value in range(1, 200):
		if Zoo.HIDEOUTS[absi(hash("zoo copito %d" % seed_value)) % Zoo.HIDEOUTS.size()] == spot:
			return seed_value
	return 0


func test_every_hideout_comes_up_and_has_its_place() -> void:
	for spot: String in Zoo.HIDEOUTS:
		assert_ne(_seed_for(spot), 0, "%s comes up with some seed" % spot)
	var zoo := Zoo.new()
	add_child_autofree(zoo)
	assert_eq(zoo.hideouts.size(), Zoo.LOCKERS + 5, "six lockers, four more places and the log")
	for spot: String in zoo.hideouts:
		var hideout := zoo.hideouts[spot] as ZooHideout
		assert_ne(tr(hideout.prompt_key(null)), hideout.prompt_key(null), "%s has its prompt" % spot)
	assert_eq(zoo.room(zoo.to_global(zoo.hideouts.locker3.position)), "hut")
	assert_eq(zoo.room(zoo.to_global(zoo.hideouts.plush.position)), "shop")
	assert_eq(zoo.room(zoo.to_global(zoo.hideouts.shell.position)), "reptiles")
	assert_eq(zoo.room(zoo.to_global(zoo.hideouts.boat.position)), "pond")


func test_he_is_in_the_culprits_locker_and_the_log_says_so() -> void:
	TranslationServer.set_locale("es")
	var made := _zoo_case(_seed_for("locker"))
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var culprit := case.plan.culprit
	assert_eq(zoo.hidden_at(), "locker%d" % culprit)
	zoo.search("locker%d" % ((culprit + 1) % Zoo.LOCKERS), cop)
	assert_eq(_hint(cop), "HINT_ZOO_NOTHING_locker")
	assert_null(zoo.copito)
	zoo.search("log", cop)
	assert_eq(_hint(cop), tr("HINT_ZOO_LOG_EXTRA") % zoo.keepers[culprit].traits.name)
	zoo.search("locker%d" % culprit, cop)
	assert_eq(_hint(cop), "HINT_ZOO_COPITO_FOUND")
	assert_not_null(zoo.copito, "he turns up")
	assert_eq(zoo.room(zoo.copito.global_position), "hut")


func test_elsewhere_the_log_says_all_normal() -> void:
	var made := _zoo_case(_seed_for("boat"))
	var zoo: Zoo = made[0]
	var cop: Cop = made[2]
	zoo.search("log", cop)
	assert_eq(_hint(cop), "HINT_ZOO_LOG_NORMAL")
	zoo.search("shell", cop)
	assert_eq(_hint(cop), "HINT_ZOO_NOTHING_shell")
	zoo.search("boat", cop)
	assert_not_null(zoo.copito)


func test_a_search_takes_its_seconds() -> void:
	var made := _zoo_case(_seed_for("freezer"))
	var zoo: Zoo = made[0]
	var cop: Cop = made[2]
	var freezer := zoo.hideouts.freezer as ZooHideout
	freezer.use(cop)
	assert_eq(_hint(cop), "HINT_ZOO_SEARCHING")
	assert_true(freezer.busy)
	assert_eq(freezer.prompt_key(cop), "PROMPT_ZOO_BUSY")
	assert_null(zoo.copito, "not yet")
	await wait_seconds(ZooHideout.SEARCH_SECONDS + 0.3)
	assert_false(freezer.busy)
	assert_not_null(zoo.copito, "found after the search")


func test_back_on_his_floe_he_counts() -> void:
	var made := _zoo_case(_seed_for("shell"))
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	zoo.search("shell", null)
	var copito := zoo.copito
	assert_false(zoo.on_floe(copito.global_position))
	await wait_physics_frames(3)
	assert_false(case.loot_found, "not yet")
	copito.global_position = zoo.to_global(Zoo.ICE_AT + Vector3(0.3, 1.2, 0.2))
	await wait_physics_frames(3)
	assert_true(copito.home, "let go on the floe, he's home")
	assert_true(zoo.loot_found)
	assert_true(case.loot_found, "+100 for the pay")
	var pos := copito.global_position
	copito.hold(1, pos + Vector3(2, 0, 0))
	assert_true(copito.holders.is_empty(), "home, he stays")


func test_the_penguins_gate_opens_and_the_others_dont() -> void:
	var zoo := Zoo.new()
	add_child_autofree(zoo)
	var penguins := zoo.gates.penguins as ZooGate
	assert_eq(penguins.prompt_key(null), "PROMPT_ZOO_GATE_OPEN")
	penguins.use(null)
	assert_eq(penguins.collision_layer, 0, "open")
	assert_false(penguins.bars.visible)
	assert_eq(penguins.prompt_key(null), "PROMPT_ZOO_GATE_SHUT")
	penguins.use(null)
	assert_ne(penguins.collision_layer, 0, "shut again")
	var monkey := zoo.gates.monkey as ZooGate
	monkey.use(null)
	assert_ne(monkey.collision_layer, 0, "padlocked until feeding time")
	assert_eq(monkey.prompt_key(null), "PROMPT_ZOO_GATE_LOCKED")


func test_among_the_plush_penguins_he_sneezes() -> void:
	var made := _zoo_case(_seed_for("plush"))
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var sneeze := zoo.get_node("Sneeze") as Label3D
	var seen := false
	for i in 40:
		await wait_seconds(0.1)
		seen = seen or sneeze.visible
	assert_true(seen, "¡Achís!")
	assert_eq(case.briefing_lines()[0], "BRIEF_ZOO_A_copito")
	zoo.search("plush", null)
	await wait_seconds(0.1)
	assert_false(sneeze.visible, "found, no more sneezing")
