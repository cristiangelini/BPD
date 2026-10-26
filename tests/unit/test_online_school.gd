extends GutTest

## The deputy's school visit online (politico-escuela.md, step 8; docs/diseno/online.md): the host's school decides the
## visit, the cards, the questions and the janitor, and every PC sees the same.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SCHOOL_SCENE := preload("res://scenes/levels/school_visit.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var school: SchoolVisitLevel = SCHOOL_SCENE.instantiate()
		school.case_seed = SEED
		school.get_node("Cop/Grabber").input_enabled = false
		return school)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _school(net: Node) -> SchoolVisitLevel:
	return OnlinePcs.level(net) as SchoolVisitLevel


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _school(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.tour.follower, "the guest's visit only shows the host's")
	assert_true(guest.questions.follower, "and so do its questions")
	assert_true(guest.janitor.follower, "the janitor is the host's")
	assert_true(guest.pupils[0].follower)


func test_the_visit_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _school(pcs[0])
	var guest := _school(pcs[1])
	host.tour.start()
	await wait_until(func() -> bool: return guest.tour.phase == SchoolTour.Phase.TALK, 5.0)
	assert_eq(guest.tour.phase, SchoolTour.Phase.TALK)


func test_a_swapped_card_and_a_raised_hand_reach_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _school(pcs[0])
	var guest := _school(pcs[1])
	var pupil: SchoolPupil = host.pupils.filter(func(p: SchoolPupil) -> bool: return not p.trap)[0]
	host.janitor.swap(pupil)
	host.tour.start()
	host.tour._enter(SchoolTour.Phase.QUESTIONS, host.deputy_to_class())
	pupil.raise_hand(true)
	var copy: SchoolPupil = guest.get_node(NodePath(pupil.name))
	await wait_until(func() -> bool: return copy.trap and copy.hand_up, 5.0)
	assert_eq(copy.card, pupil.card)
	assert_true(copy.hand_up)


func test_a_guest_takes_a_card_and_holds_it() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _school(pcs[0])
	var guest := _school(pcs[1])
	var cop := OnlinePcs.own_cop(pcs[1])
	var pupil: SchoolPupil = guest.pupils.filter(func(p: SchoolPupil) -> bool: return not p.trap)[0]
	var key := pupil.card
	cop.act("use", pupil)
	var grabber: Grabber = cop.get_node("Grabber")
	await wait_until(func() -> bool: return grabber.held is SchoolCard, 5.0)
	assert_eq((grabber.held as SchoolCard).key, key, "the copy of the host's card is in the guest's hands")
	var on_host: SchoolPupil = host.get_node(NodePath(pupil.name))
	assert_false(on_host.has_card(), "the host's pupil gave it")
	assert_true(on_host.crying)
	await wait_until(func() -> bool: return pupil.crying, 5.0)
	assert_true(pupil.crying, "and cries on the guest's screen too")


func test_the_gaffes_and_the_end_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _school(pcs[0])
	var guest := _school(pcs[1])
	host.questions.gaffes = 3
	await wait_until(func() -> bool: return guest.questions.gaffes == 3, 5.0)
	assert_eq(guest.questions.gaffes, 3)
	host.janitor.cuffed(Handcuffs.SECONDS)
	host.tour.finished.emit()
	await wait_until(func() -> bool: return guest.case.shift_over, SchoolCase.SHIFT_DELAY + 5.0)
	assert_true(guest.case.solved())
