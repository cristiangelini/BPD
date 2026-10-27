extends GutTest

## The TV debate online (politico-debate.md, step 8; docs/diseno/online.md): the host's studio runs the debate and the
## tricks, and every PC sees the same clock, turn, image, trick, technician and end.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const STUDIO_SCENE := preload("res://scenes/levels/tv_studio.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var studio: TvStudio = STUDIO_SCENE.instantiate()
		studio.case_seed = SEED
		studio.get_node("Cop/Grabber").input_enabled = false
		return studio)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _studio(net: Node) -> TvStudio:
	return OnlinePcs.level(net) as TvStudio


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _studio(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.debate.follower, "the guest's debate only shows the host's")
	assert_true(guest.sabotage.follower)
	assert_true(guest.technician.follower)
	assert_false(_studio(pcs[0]).case.follower)


func test_the_clock_the_turn_and_the_image_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _studio(pcs[0])
	var guest := _studio(pcs[1])
	host.debate.start()
	host.debate.blunder("light")
	await wait_until(func() -> bool: return guest.debate.state == TvDebate.State.BLOCK \
		and guest.debate.blunders == 1, 5.0)
	assert_eq(guest.debate.speaker, "moderator")
	assert_eq(guest.debate.image, host.debate.image)
	assert_eq(guest.on_air_index, TvDebate.CAMERA_OF.moderator, "the same camera on air")


func test_a_trick_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _studio(pcs[0])
	var guest := _studio(pcs[1])
	host.debate.start()
	host.sabotage.warn("teleprompter")
	host.sabotage.pull()
	await wait_until(func() -> bool: return guest.sabotage.phase == TvSabotage.Phase.ON, 5.0)
	assert_eq(guest.sabotage.kind, "teleprompter")
	assert_true(guest.warning.visible, "the yellow light there too")
	assert_eq(guest.prompter.text(), host.prompter.text(), "the same nonsense")


func test_the_clues_and_the_cuffs_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _studio(pcs[0])
	var guest := _studio(pcs[1])
	host.technician.use(host.get_node("Cop"))
	host.technician.cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return guest.technician.is_cuffed() and guest.case.clues.size() == 1, 5.0)
	assert_true(guest.technician.is_cuffed())
	assert_eq(guest.case.clues, ["cup"] as Array[String])
	assert_false(guest.sabotage.active, "no more tricks there either")


func test_the_getaway_and_the_end_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _studio(pcs[0])
	var guest := _studio(pcs[1])
	host.debate.state = TvDebate.State.OVER
	host.debate.finished.emit()
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_not_null(guest.case.chase, "the technician drives off there too")
	assert_false(guest.technician.visible)
	host.case.chase.ended.emit(true)
	await wait_until(func() -> bool: return guest.case.shift_over, DebateCase.SHIFT_DELAY + 5.0)
	assert_true(guest.case.technician_detained())
