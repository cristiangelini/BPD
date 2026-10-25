extends GutTest

## The gym's people (infiltracion-gimnasio.md, step 2b, decision 172): the gang's members training on spots drawn with
## the seed, el Toro in front of the mirror looking at them, the receptionist who only lets in cops in gym clothes, and
## their suspicion.

const LEVEL := preload("res://scenes/levels/gym_hall.tscn")

var gym: GymHall


func before_each() -> void:
	gym = LEVEL.instantiate()
	gym.get_node("Cop").input_enabled = false
	add_child_autofree(gym)
	await wait_physics_frames(2)


func test_members_on_training_spots_and_el_toro_watching_them() -> void:
	assert_eq(gym.members.size(), GymHall.MEMBERS)
	for member: ClubMember in gym.members:
		assert_true(GymHall.TRAIN_SPOTS.any(func(at: Vector3) -> bool:
			return (at + Vector3(0, GymHall.FLOOR_TOP, 0)).distance_to(member.position) < 0.01), "on a spot")
		assert_true(member.look.begins_with("socio"))
		assert_false(member.is_boss())
	assert_eq(gym.free_spots.size(), GymHall.TRAIN_SPOTS.size() - GymHall.MEMBERS, "spots left for the cops")
	assert_eq(gym.boss, gym.toro)
	assert_true(gym.toro.is_boss())
	var toward_hall := gym.global_basis * Vector3.BACK
	assert_gt((-gym.toro.global_basis.z).dot(toward_hall), 0.9, "el Toro looks at the hall")


func test_the_treadmill_members_look_out_the_window() -> void:
	for member: ClubMember in gym.members:
		if member.position.y > GymHall.FLOOR_TOP + 0.01:
			assert_ne(gym.treadmill_at(member.global_position + Vector3.UP * 0.05), -1, "on a treadmill")
			assert_gt((-member.global_basis.z).dot(gym.global_basis * Vector3.BACK), 0.99)


func test_the_same_seed_puts_the_members_on_the_same_spots() -> void:
	var other: GymHall = LEVEL.instantiate()
	other.case_seed = gym.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in gym.members.size():
		assert_eq(other.members[i].position, gym.members[i].position)
		assert_eq(other.members[i].look, gym.members[i].look)


func test_members_gossip_and_el_toro_has_his_own_lines() -> void:
	var cop: Cop = gym.get_node("Cop")
	gym.members[0].use(cop)
	assert_true(gym.members[0].said().begins_with("GYM_GOSSIP_"))
	gym.members[0].cuffed(5.0)
	assert_eq(gym.members[0].said(), "GYM_CUFFED")
	gym.toro.use(cop)
	assert_true(gym.toro.said().begins_with("TORO_"))
	gym.toro.cuffed(5.0)
	assert_eq(gym.toro.said(), "TORO_CUFFED")


func test_the_members_watch_for_gym_clothes() -> void:
	assert_eq(gym.suspicion.disguise_look, "gym")
	assert_eq(gym.suspicion.prefix, "GYM_")
	assert_eq(gym.suspicion.boss, gym.toro)
	assert_eq(gym.suspicion.boss_found_out, "TORO_FOUND_OUT")
	var cop: Cop = gym.get_node("Cop")
	assert_gt(gym.suspicion.offence(cop, 0.0), 0.0, "a cop in uniform is suspicious")
	cop.put_on_disguise("gym_headband", 0.0)
	cop.put_on_disguise("gym_tank", 0.0)
	assert_eq(gym.suspicion.offence(cop, 0.0), 0.0, "a member standing still isn't")


## A cop walking into the doorway from the sidewalk.
func _walk_in(cop: Cop) -> void:
	cop.global_position = gym.global_transform * Vector3(GymHall.ENTRANCE_X, 0.1, GymHall.HALF_Z + 1.0)
	cop.global_rotation.y = gym.global_rotation.y
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		gym.doorman._physics_process(1.0 / 60.0)


func test_the_receptionist_wants_gym_clothes() -> void:
	var cop: Cop = gym.get_node("Cop")
	cop.put_on_disguise("gym_headband", 0.0)
	await _walk_in(cop)
	assert_eq(gym.doorman.said(), "GYMDOOR_NO_1", "a headband alone isn't enough")
	var inside_z := (gym.global_transform.affine_inverse() * cop.global_position).z
	assert_gt(inside_z, GymHall.HALF_Z - 0.5, "didn't get in")


func test_the_receptionist_lets_a_member_in() -> void:
	var cop: Cop = gym.get_node("Cop")
	cop.put_on_disguise("gym_headband", 0.0)
	cop.put_on_disguise("gym_wristbands", 0.0)
	await _walk_in(cop)
	assert_eq(gym.doorman.said(), "GYMDOOR_WELCOME")
	var inside_z := (gym.global_transform.affine_inverse() * cop.global_position).z
	assert_lt(inside_z, GymHall.HALF_Z - 0.5, "got in")


func test_the_receptionist_stays_clear_of_the_doorway_and_the_counter() -> void:
	var at := GymHall.RECEPTIONIST_AT
	assert_gt(absf(at.x - GymHall.ENTRANCE_X) - 0.55, GameScale.DOOR_WIDTH / 2, "clear of the doorway")
	assert_gt(at.z - 0.55, GymHall.RECEPTION_AT.z + GymHall.RECEPTION_SIZE.z / 2, "in front of the counter")
	assert_lt(at.z + 0.55, GymHall.HALF_Z, "inside the front wall")


func test_the_people_s_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PROMPT_TALK_GYM", "GYM_CUFFED", "PROMPT_TALK_TORO", "TORO_CUFFED", "TORO_FOUND_OUT",
		"GYMDOOR_WELCOME", "GYMDOOR_NO_0", "GYMDOOR_NO_1", "HINT_GYMDOOR_NO_DISGUISE", "HUD_GYM_SUSPICION",
		"HINT_GYM_FOUND_OUT"]
	for i in 10:
		keys.append("GYM_GOSSIP_%d" % i)
	for i in 4:
		keys.append("TORO_%d" % i)
	for i in ClubSuspicion.FOUND_OUT_LINES:
		keys.append("GYM_FOUND_OUT_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
