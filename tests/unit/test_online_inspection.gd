extends GutTest

## The final inspection online (inspeccion.md, step 5; docs/diseno/online.md): the host's inspector decides, and every
## guest sees a copy of her that follows, says the same and shows the same report.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL := preload("res://scenes/levels/grandpa_house.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D: return LEVEL.instantiate())


func after_each() -> void:
	Campaign.current = null
	_pcs.free_all()
	await wait_process_frames(2)


func _inspector(net: Node) -> CityInspector:
	var found := OnlinePcs.level(net).find_children("*", "CityInspector", true, false)
	return found[0] as CityInspector if not found.is_empty() else null


func test_the_guest_gets_a_copy_of_the_hosts() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	Campaign.start_new().shift = Campaign.SHIFTS
	CityInspector.join(OnlinePcs.own_cop(pcs[0]))
	await wait_until(func() -> bool: return _inspector(pcs[1]) != null, 5.0)
	var copy := _inspector(pcs[1])
	await wait_physics_frames(5)
	assert_true(copy.follower)
	assert_eq(OnlinePcs.level(pcs[1]).find_children("*", "CityInspector", true, false).size(), 1, "only one")


func test_the_report_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	Campaign.start_new().shift = Campaign.SHIFTS
	var host := CityInspector.join(OnlinePcs.own_cop(pcs[0]))
	await wait_until(func() -> bool: return _inspector(pcs[1]) != null, 5.0)
	host.report.note("cuffed")
	var copy := _inspector(pcs[1])
	await wait_until(func() -> bool: return copy.report.score == host.report.score, 5.0)
	assert_eq(copy.report.score, InspectionReport.START + InspectionReport.CUFFED)


func test_the_guest_writes_nothing_down() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	Campaign.start_new().shift = Campaign.SHIFTS
	CityInspector.join(OnlinePcs.own_cop(pcs[0]))
	await wait_until(func() -> bool: return _inspector(pcs[1]) != null, 5.0)
	var copy := _inspector(pcs[1])
	assert_false(copy.saw("donut", copy.global_position))
	assert_eq(copy.report.score, InspectionReport.START)


func test_the_shift_screen_reads_it_from_the_report() -> void:
	var screen: ShiftScreen = preload("res://scenes/ui/shift_screen.tscn").instantiate()
	add_child_autofree(screen)
	var awards: Array[Dictionary] = []
	screen.show_report(true, {"salary": 500, "evidence": 0, "fines": 0, "total": 500, "quota": 1700,
		"approved": true, "inspection": 70, "inspection_best": "solved", "inspection_worst": "crash"}, 0, awards)
	screen.show_campaign(Campaign.SHIFTS, Campaign.SHIFTS, 500, true, true)
	assert_eq(screen.get_node("%Verdict").text, tr("SHIFT_PROMOTED"))
