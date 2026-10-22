extends GutTest

## The jailbreak, step 5b (fuga.md): every cop singing puts the night guard to sleep, and asleep his key can be taken
## off his belt, by hand or with the stick.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")

var level: Node3D
var cop: Cop
var guard: NightGuard
var lot: Transform3D


func before_each() -> void:
	level = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	guard = level.guard
	lot = level.city.transform * CityLayout.lot("station")
	guard.set_physics_process(false)


## Runs the guard for `seconds` with `singers` singing all along (VoiceChat tells him every half second).
func _run(seconds: float, singers: Array = []) -> void:
	for i in int(seconds / 0.1):
		if i % 5 == 0:
			for singer: Node3D in singers:
				guard.heard_singing(singer)
		guard._physics_process(0.1)


func test_everyone_singing_puts_him_to_sleep() -> void:
	_run(NightGuard.LULLABY + 0.2, [cop])
	assert_true(guard.is_asleep())
	assert_eq(guard.said(), "GUARD_ASLEEP")


func test_asleep_he_doesnt_watch_or_eat() -> void:
	_run(NightGuard.LULLABY + 0.2, [cop])
	cop.global_position = lot * Vector3(9.5, 0.1, 6.0)
	guard.eat_left = 0.05
	await wait_physics_frames(2)
	_run(5.0)
	assert_eq(guard.suspicion, 0.0, "he doesn't see the cop out")
	assert_eq(guard.box.donuts, 6, "nor eat")


func test_if_not_everyone_sings_he_only_gets_sleepy() -> void:
	var other: Cop = COP_SCENE.instantiate()
	other.input_enabled = false
	level.add_child(other)
	other.global_transform = level.cop_spawn(1)
	await wait_physics_frames(2)
	_run(6.0, [cop])
	assert_false(guard.is_asleep(), "one of two singing isn't enough")
	_run(NightGuard.LULLABY + 0.2, [cop, other])
	assert_true(guard.is_asleep(), "the two together are")


func test_he_wakes_up_after_a_while_or_with_a_shout() -> void:
	guard.fall_asleep()
	_run(NightGuard.SLEEP + 0.2)
	assert_false(guard.is_asleep())
	assert_eq(guard.said(), "GUARD_AWAKE")
	guard.fall_asleep()
	guard.shouted_by(cop)
	assert_false(guard.is_asleep(), "a shout wakes him up")


func test_asleep_the_key_comes_off_his_belt_by_hand() -> void:
	guard.key_on_belt = true
	cop.global_position = lot * Vector3(10.5, 0.1, 6.6)
	await wait_physics_frames(2)
	var to := guard.global_position + Vector3.UP * 0.9 - cop.camera.global_position
	cop.global_rotation.y = atan2(-to.x, -to.z)
	cop.camera.get_parent().rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	await wait_physics_frames(2)
	assert_eq(cop.current_prompt(), "", "awake, nothing to do with him")
	guard.fall_asleep()
	assert_eq(cop.current_prompt(), "PROMPT_TAKE_GUARD_KEY")
	cop.use()
	await wait_physics_frames(1)
	assert_is(cop.get_node("Grabber").held, CellKey, "the key in the cop's hands")
	assert_false(guard.key_on_belt)


func test_asleep_the_stick_hooks_the_key_off_his_belt() -> void:
	guard.key_on_belt = true
	guard.fall_asleep()
	var rod: HookStick = level.sticks[1]
	# A cop already out, in front of the desk, reaching over it with the rod.
	cop.global_position = lot * Vector3(10.5, 0.1, 4.9)
	await wait_physics_frames(2)
	var to := guard.belt() - cop.camera.global_position
	cop.global_rotation.y = atan2(-to.x, -to.z)
	cop.camera.get_parent().rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	cop.get_node("Grabber").grab(rod)
	await wait_physics_frames(20)
	# Slides the cop so the tip lands on the belt.
	var miss := guard.belt() - rod.tip()
	cop.global_position += Vector3(miss.x, 0, miss.z)
	await wait_physics_frames(20)
	assert_eq(rod.held_prompt_key(cop), "PROMPT_HOOK_KEY")
	cop.use()
	await wait_physics_frames(1)
	assert_is(rod.hooked, CellKey, "the key hangs from the tip")
	assert_eq(rod.hooked.collision_mask, 0, "and goes through the bars")
	assert_false(guard.key_on_belt)
	assert_eq(rod.held_prompt_key(cop), "PROMPT_UNHOOK_KEY")
	var key: CellKey = rod.hooked
	cop.use()
	assert_null(rod.hooked)
	assert_eq(key.collision_mask, 15, "let go, it falls on the floor")


func test_holding_h_hums_to_him() -> void:
	cop.input_enabled = true
	Input.action_press("hum")
	Net.voice._check_singing(1.0)
	Input.action_release("hum")
	cop.input_enabled = false
	assert_true(guard._singers.has(cop), "humming counts as singing")


func test_voice_that_goes_on_counts_as_singing() -> void:
	var meter := SongMeter.new()
	var loud := PackedByteArray()
	loud.resize(960 * 2)
	for i in 960:
		loud.encode_s16(i * 2, 8000 if i % 2 == 0 else -8000)
	var now := 0.0
	for i in 30:
		meter.feed(loud, 48000, now)
		now += 0.02
	assert_false(meter.is_singing(now), "a few words aren't a song")
	for i in 80:
		meter.feed(loud, 48000, now)
		now += 0.02
	assert_true(meter.is_singing(now), "two seconds without stopping is")
	assert_false(meter.is_singing(now + 1.0), "and it ends when the voice stops")
