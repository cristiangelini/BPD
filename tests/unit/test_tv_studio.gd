extends GutTest

## The TV channel (politico-debate.md, step 1, decision 230): its own lot in the city, the studio with the set, the
## big screen and the stand full of public, and the east wing with the makeup room and, up the stairs, the control
## room that looks into the studio.

const LEVEL := preload("res://scenes/levels/tv_studio.tscn")
const TICK := 1.0 / 60.0

var studio: TvStudio


func before_each() -> void:
	studio = LEVEL.instantiate()
	studio.case_seed = 7
	studio.get_node("Cop").input_enabled = false
	add_child_autofree(studio)
	await wait_physics_frames(2)


func test_it_has_its_own_lot_in_the_city() -> void:
	var lot := CityLayout.place("tv_studio")
	assert_eq(lot.block, Vector2i(1, 4))
	assert_eq(lot.side, "n")
	assert_eq(PlaceDraw.PLACES.get("debate", ""), "res://scenes/levels/tv_studio.tscn")
	assert_eq(lot.size.x, TvStudio.HALF_X * 2, "the building fills its lot")
	assert_eq(lot.size.z, TvStudio.HALF_Z * 2)


func test_the_set_has_two_lecterns_a_desk_and_the_screen() -> void:
	assert_eq(studio.lecterns.size(), 2)
	assert_lt(studio.lecterns[0].position.x, studio.lecterns[1].position.x, "Malvón on the west, Lustre on the east")
	assert_not_null(studio.get_node_or_null("Built/Desk"))
	assert_not_null(studio.screen)
	assert_true(studio.in_studio(studio.to_global(TvStudio.SCREEN_AT)), "the screen is in the studio")
	assert_not_null(studio.on_air)


func test_the_public_sits_on_the_stand() -> void:
	assert_eq(studio.public.size(), TvStudio.PUBLIC)
	await wait_physics_frames(20)
	for fan in studio.public:
		var local := studio.to_local(fan.global_position)
		assert_gt(local.y, TvStudio.STEP.y * 0.8, "%s is up on a step" % fan.name)
		assert_gt(local.z, TvStudio.STAND_FRONT)


func test_the_control_room_is_up_the_stairs_and_looks_into_the_studio() -> void:
	var level := GameScale.FLOOR_HEIGHT
	var console := studio.get_node("Built/Console") as Node3D
	assert_true(studio.in_control_room(console.global_position + Vector3.UP * 0.1))
	assert_false(studio.in_studio(console.global_position))
	# From the console's chairs, a ray through the window reaches the set without hitting a wall.
	var space := studio.get_world_3d().direct_space_state
	var from := studio.to_global(Vector3(TvStudio.CHAIRS_X, level + 1.6, -7.0))
	var to := studio.to_global(TvStudio.LECTERNS[1] + Vector3.UP * 1.0)
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	assert_false(hit.is_empty())
	var local := studio.to_local(hit.position)
	assert_almost_eq(local.x, TvStudio.WING_X, 0.1, "the first thing in the way is the wing's wall...")
	assert_between(local.y, GameScale.FLOOR_HEIGHT + TvStudio.WINDOW.x, GameScale.FLOOR_HEIGHT + TvStudio.WINDOW.y,
		"...where the glass is")


func test_a_cop_walks_up_the_stairs_to_the_control_room() -> void:
	var cop := studio.get_node("Cop") as Cop
	cop.global_transform = Transform3D(Basis.IDENTITY, studio.to_global(TvStudio.STAIRS_FOOT + Vector3(0, 0.2, 1.0)))
	for i in 20:
		cop.step(TICK, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	for i in 150:
		cop.step(TICK, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	assert_true(studio.in_control_room(cop.global_position), "up there")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PLACE_TV_STUDIO", "TV_STUDIO_DOOR", "TV_LOBBY_DOOR", "TV_ON_AIR", "TV_NAME_0", "TV_NAME_1"]:
		assert_ne(tr(key), key)
