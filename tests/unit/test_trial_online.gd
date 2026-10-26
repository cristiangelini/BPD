extends GutTest

## The fast trial online (fuga-juicio.md, "Online"): the host runs the guard and the judge; a guest's cop takes the
## stand and answers on the signs, and the guest sees the same trial.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL := preload("res://scenes/levels/jailbreak.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_jail)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_jail() -> Node3D:
	var jail: JailbreakLevel = LEVEL.instantiate()
	jail.case_seed = 6161
	jail.variant = "trial"
	return jail


func test_a_guest_testifies() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	var host_guard := host_level.guard as TrialGuard
	host_guard.call_to_trial()
	await wait_until(func() -> bool: return (guest_level.guard as TrialGuard).phase == "briefing", 5.0)
	assert_true(guest_level.city.cell_doors.all(func(door: CellDoor) -> bool: return door.is_open), "open on the guest")
	var host_cop := OnlinePcs.own_cop(pcs[0])
	host_cop.put_on_disguise("lawyer_jacket", 0.0)
	host_guard.phase = "court"
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	await wait_until(func() -> bool: return guest_level.judge.state == "calling", 5.0)
	assert_true(guest_level.judge.is_witness(guest_cop), "the guest is called")
	guest_cop.act("use", guest_level.get_node("TrialStand"))
	await wait_until(func() -> bool: return host_level.judge.state == "asking", 5.0)
	assert_eq(host_level.judge.state, "asking", "on the stand on the host")
	await wait_until(func() -> bool: return guest_level.signs[0].answer_key() != "", 5.0)
	var key := TrialAlibi.answer(guest_level.judge.alibi, guest_level.judge.asking())
	var right: TrialSign
	for sign_board in guest_level.signs:
		if sign_board.answer_key() == key:
			right = sign_board
	guest_cop.act("use", right)
	await wait_until(func() -> bool: return host_level.judge.question == 1, 5.0)
	assert_eq(host_level.judge.contradictions, 0, "the right answer on the host")
	await wait_until(func() -> bool: return guest_level.judge.question == 1, 5.0)
	assert_eq(guest_level.judge.question, 1, "and the guest follows")
