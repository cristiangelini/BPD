extends GutTest

## The deputy's falls (politico-futbol.md, step 4, decision 179): a veteran touches him and he lies screaming until the
## stretcher comes; on it, it takes two cops; at his bench he heals and goes back. The Tank charges at him: a cop in
## the way stops him, and if he gets there it's a real injury.

const LEVEL := preload("res://scenes/levels/football_pitch.tscn")

var pitch: FootballPitch
var lustre: FootballLustre
var cop: Cop


func before_each() -> void:
	pitch = LEVEL.instantiate()
	pitch.case_seed = 7
	cop = pitch.get_node("Cop")
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(pitch)
	await wait_physics_frames(3)
	lustre = pitch.lustre
	# Only him playing; the cop away from everyone.
	lustre.playing = true
	cop.global_position = pitch.to_global(Vector3(0, 0.1, 22))


func _veteran() -> FootballPlayer:
	for player in pitch.match_clock.players:
		if player.role == "veteran":
			return player
	return null


func test_a_veteran_touches_him_and_he_stays_down_screaming() -> void:
	watch_signals(lustre)
	_veteran().global_position = lustre.politician.global_position + Vector3(0.5, 0, 0)
	await wait_physics_frames(3)
	assert_true(lustre.down)
	assert_signal_emitted(lustre, "fell")
	assert_eq(lustre.injuries, 0, "a dive is not an injury")
	_veteran().global_position = pitch.to_global(Vector3(0, 0.1, -10))
	await wait_seconds(2.0)
	assert_true(lustre.down, "he doesn't get up on his own")
	assert_string_starts_with(lustre.politician.said(), "FOOTBALL_LUSTRE_DOWN_")


func test_on_the_stretcher_it_takes_two_cops() -> void:
	lustre.fall()
	var stretcher := pitch.stretcher
	assert_lt(stretcher.mass, Grabbable.max_force_per_holder() / GameScale.GRAVITY, "empty, one cop carries it")
	stretcher.global_position = lustre.politician.global_position + Vector3(1.0, 0.1, 0)
	await wait_physics_frames(3)
	assert_eq(lustre.riding, stretcher)
	assert_true(stretcher.loaded)
	var weight := stretcher.mass
	assert_gt(weight, Grabbable.max_force_per_holder() / GameScale.GRAVITY, "one cop can't lift him")
	assert_lt(weight, Grabbable.max_force_per_holder() * 2 / GameScale.GRAVITY, "two cops can")
	await wait_physics_frames(5)
	assert_almost_eq(lustre.politician.global_position.distance_to(stretcher.bed()), 0.0, 0.1, "lying on it")


func test_at_his_bench_he_heals_and_goes_back() -> void:
	watch_signals(lustre)
	lustre.fall()
	var stretcher := pitch.stretcher
	stretcher.global_position = lustre.politician.global_position + Vector3(1.0, 0.1, 0)
	await wait_physics_frames(3)
	stretcher.global_position = pitch.to_global(FootballLustre.BENCH + Vector3(1.0, 0.1, 0))
	await wait_physics_frames(3)
	assert_null(lustre.riding)
	assert_false(stretcher.loaded)
	assert_true(lustre.down, "healing")
	await wait_seconds(FootballLustre.HEAL + 0.3)
	assert_false(lustre.down)
	assert_signal_emitted(lustre, "healed")
	assert_eq(lustre.politician.said(), "FOOTBALL_LUSTRE_BACK")


func test_the_tank_charges_and_injures_him() -> void:
	watch_signals(lustre)
	var tank := pitch.match_clock.tank
	assert_gt(tank.get_node("Model").scale.y, 1.2, "bigger than the rest")
	tank.global_position = lustre.politician.global_position + Vector3(-6, 0, 0)
	tank.playing = true
	tank.charge_in = 0.0
	await wait_physics_frames(2)
	assert_true(tank.charging)
	assert_eq(tank.said(), "FOOTBALL_TANK_CHARGE")
	await wait_until(func() -> bool: return lustre.injuries > 0, 4.0)
	assert_eq(lustre.injuries, 1)
	assert_signal_emitted_with_parameters(lustre, "injured", [1])
	assert_true(lustre.down)
	assert_false(tank.charging)


func test_a_cop_in_the_way_stops_the_tank() -> void:
	var tank := pitch.match_clock.tank
	tank.global_position = lustre.politician.global_position + Vector3(-8, 0, 0)
	cop.global_position = lustre.politician.global_position + Vector3(-3, 0.1, 0)
	tank.playing = true
	tank.charge_in = 0.0
	await wait_until(func() -> bool: return tank.said() == "FOOTBALL_TANK_BLOCKED", 4.0)
	assert_false(tank.charging)
	assert_true(cop.is_staggered(), "both on the grass")
	assert_eq(lustre.injuries, 0)
	assert_false(lustre.down)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["FOOTBALL_LUSTRE_DOWN_1", "FOOTBALL_LUSTRE_DOWN_3", "FOOTBALL_LUSTRE_STRETCHER",
			"FOOTBALL_LUSTRE_HEALING", "FOOTBALL_LUSTRE_BACK", "FOOTBALL_LUSTRE_HURT", "FOOTBALL_TANK_CHARGE",
			"FOOTBALL_TANK_BLOCKED", "HINT_FOOTBALL_DOWN", "HINT_FOOTBALL_INJURY"]:
		assert_ne(tr(key), key)
