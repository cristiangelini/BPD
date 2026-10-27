extends GutTest

## The studio's cameras and the screen (politico-debate.md, step 2, decision 230): 3 heavy cameras on wheels that one
## cop drags slowly and two move fast, that never tip over, that E turns to where the cop looks, and the big screen
## that shows what the camera on air sees.

const LEVEL := preload("res://scenes/levels/tv_studio.tscn")

var studio: TvStudio


func before_each() -> void:
	studio = LEVEL.instantiate()
	studio.case_seed = 7
	var cop := studio.get_node("Cop") as Cop
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(studio)
	await wait_physics_frames(3)


## Pulls `camera` along +X for `frames` physics frames with `hands` holders, the way cops walking with it do.
func _drag(camera: TvCamera, hands: int, frames: int) -> float:
	var start := camera.global_position
	for i in frames:
		for h in hands:
			camera.hold(1000 + h, camera.global_position + Vector3(1.5, 0.8, 0))
		await wait_physics_frames(1)
	for h in hands:
		camera.let_go(1000 + h)
	return Vector2(camera.global_position.x - start.x, camera.global_position.z - start.z).length()


func test_three_heavy_cameras_aimed_at_the_set() -> void:
	assert_eq(studio.cameras.size(), 3)
	for i in studio.cameras.size():
		var camera := studio.cameras[i]
		assert_eq(camera.mass, TvCamera.KG)
		assert_true(camera.frames(studio.to_global(TvStudio.SHOTS[i])), "%s shoots what it should" % camera.name)
	assert_true(studio.cameras[2].frames(studio.to_global(TvStudio.LECTERNS[1] + Vector3.UP * 1.5)), "Lustre's")
	assert_false(studio.cameras[2].frames(studio.to_global(TvStudio.LECTERNS[0] + Vector3.UP * 1.5)), "not Malvón")


func test_one_cop_drags_it_slowly_and_two_fast() -> void:
	var alone := await _drag(studio.cameras[0], 1, 60)
	var together := await _drag(studio.cameras[2], 2, 60)
	assert_gt(alone, 0.5, "one cop moves it")
	assert_gt(together, alone * 1.5, "two move it much faster")


func test_it_never_tips_over() -> void:
	var camera := studio.cameras[1]
	for i in 40:
		camera.hold(1000, camera.global_position + Vector3(0.5, 2.5, 1.5))
		await wait_physics_frames(1)
	camera.let_go(1000)
	await wait_physics_frames(10)
	assert_almost_eq(camera.global_basis.y.dot(Vector3.UP), 1.0, 0.01)


func test_e_turns_it_to_where_the_cop_looks() -> void:
	var cop := studio.get_node("Cop") as Cop
	var camera := studio.cameras[2]
	cop.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), camera.global_position + Vector3(0, 0, 1.2))
	assert_eq(camera.prompt_key(cop), "PROMPT_AIM_TV_CAMERA")
	camera.use(cop)
	assert_almost_eq((-camera.global_basis.z).dot(-cop.global_basis.z), 1.0, 0.001, "it looks where the cop looks")
	assert_false(camera.frames(studio.to_global(TvStudio.SHOTS[2])), "off Lustre now")


func test_the_screen_shows_the_camera_on_air() -> void:
	assert_eq(studio.on_air_index, TvStudio.FIRST_ON_AIR)
	assert_eq(studio.camera_on_air(), studio.cameras[2])
	var material := studio.screen.material_override as StandardMaterial3D
	assert_eq(material.albedo_texture, studio.feed.get_texture(), "the screen shows the feed")
	studio.put_on_air(0)
	await wait_process_frames(2)
	assert_true(studio.cameras[0].on_air)
	assert_false(studio.cameras[2].on_air, "one tally lit at a time")
	assert_lt(studio.feed_camera.global_position.distance_to(studio.cameras[0].lens().origin), 0.05, "the feed follows it")
	assert_gt((-studio.feed_camera.global_basis.z).dot(-studio.cameras[0].lens().basis.z), 0.999)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	assert_ne(tr("PROMPT_AIM_TV_CAMERA"), "PROMPT_AIM_TV_CAMERA")
