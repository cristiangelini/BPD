extends GutTest

## The prison talent show online (carcel-talentos.md, step 7; docs/diseno/online.md): the host's show, tricks and
## case decide, and every PC sees the same acts, curtain, cards, audience, tricks and counts.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const TALENT_SCENE := preload("res://scenes/levels/prison_talent.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = TALENT_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func _skip(plan: TalentPlan) -> void:
	plan.phase_left = 0.0
	await wait_physics_frames(2)


## Host: straight into `act` with the curtain open.
func _into(plan: TalentPlan, act: String) -> void:
	plan.start()
	plan.act_now = plan.acts.find(act) - 1
	plan._enter(TalentPlan.Phase.ANNOUNCE)
	plan._enter(TalentPlan.Phase.ACT)
	await wait_physics_frames(2)


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.talent_case.follower)
	assert_true(guest.talent.follower)
	assert_true(guest.talent.tricks.follower)
	assert_true(guest.talent.inmates[0].follower, "only the host's inmates decide")
	assert_eq(guest.talent.acts, host.talent.acts, "the same show from the same seed")


func test_the_show_and_the_curtain_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.talent.start()
	await _skip(host.talent)
	await _skip(host.talent)
	assert_eq(host.talent.phase, TalentPlan.Phase.ACT)
	await wait_until(func() -> bool: return guest.talent.phase == TalentPlan.Phase.ACT, 5.0)
	await wait_until(func() -> bool: return guest.talent.stage.is_open, 5.0)
	var act: String = host.talent.acts[0]
	var copy: TalentInmate = guest.talent.performers[act][0]
	await wait_until(func() -> bool: return copy.visible, 5.0)
	assert_string_contains(guest.talent_case.rows()[1].text, tr("TALENT_ACT_%s" % act.to_upper()))


func test_the_offended_audience_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.talent.start()
	for i in 4:
		await _skip(host.talent)
	var angry := host.talent.angry_ones()
	assert_eq(angry.size(), TalentPlan.ANGRY)
	var copy := guest.talent.inmates[host.talent.inmates.find(angry[0])]
	await wait_until(func() -> bool: return copy.angry and not copy.seated, 5.0)
	assert_eq(copy.prompt_key(guest.get_node("Cop")), "PROMPT_CALM_AUDIENCE")


func test_the_magic_box_and_a_runner_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	await _into(host.talent, "magician")
	host.talent.tricks._act_time = TalentTricks.MAGIC_IN - 0.01
	await wait_physics_frames(2)
	await wait_until(func() -> bool: return guest.talent.tricks.box.closed and guest.talent.tricks.box.visible, 5.0)
	host.talent.tricks._act_time = TalentTricks.MAGIC_VANISH - 0.01
	await wait_until(func() -> bool: return guest.talent.tricks.runners.size() == 1, 5.0)
	await wait_physics_frames(2)
	assert_not_null(OwnerEscort.of(guest.talent.tricks.runners[0]), "the guest's cops can walk it to the cell")


func test_the_smoke_and_the_counts_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	await _into(host.talent, "smoke")
	await wait_until(func() -> bool: return guest.talent.tricks._smoke != null, 5.0)
	host.talent.tricks._on_runner_escaped()
	await wait_until(func() -> bool: return guest.talent.tricks.escaped == 1, 5.0)
	host.talent.tricks._smoke_off()
	await wait_until(func() -> bool: return guest.talent.tricks._clear_left > 0.0 or guest.talent.tricks._smoke == null,
		5.0)
	assert_false(guest.talent.tricks.machine.running)


func test_the_guest_cannot_foil_by_itself() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _level(pcs[1])
	var box := guest.talent.tricks.box
	box.occupied = true
	box.set_closed(true)
	box.use(guest.get_node("Cop"))
	await wait_physics_frames(3)
	assert_eq(guest.talent.tricks.foiled, 0, "the host decides")
