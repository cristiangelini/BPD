extends GutTest

## The ice rink raid online (allanamiento-pista.md, step 8): Doña Pirueta is run by the host and followed by the
## guests; the resurfacer and the DJ's song go from any PC; the glass, the cups, Copito and the stories' scoreboard and
## clang are decided on the host and show on every guest.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const RINK := preload("res://scenes/levels/rink.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "ice_surprise"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_rink)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_rink() -> Node3D:
	var rink: Rink = RINK.instantiate()
	rink.case_seed = SEED
	rink.story_id = _story
	return rink


func test_dona_pirueta_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Rink = OnlinePcs.level(pcs[0])
	var guest: Rink = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_npc.is_physics_processing(), "the guest's Doña Pirueta only follows")
	host.owner_npc.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.owner_npc.complaint - 30.0) < 0.5 \
		and guest.owner_npc.global_position.distance_to(host.owner_npc.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.owner_npc.complaint, host.owner_npc.complaint, 0.5)


func test_the_resurfacer_and_the_song_from_a_guest_work_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Rink = OnlinePcs.level(pcs[0])
	var guest: Rink = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.resurfacer_button)
	await wait_until(func() -> bool: return host.resurfacer.is_running() and guest.resurfacer.is_running(), 5.0)
	assert_true(host.resurfacer.is_running(), "the guest's button reached the host")
	await wait_seconds(1.0)
	assert_lt(absf(guest.resurfacer.along - host.resurfacer.along), IceResurfacer.SYNC_SLACK + 0.2, "side by side")
	OnlinePcs.own_cop(pcs[1]).act("use", guest.song.button)
	await wait_until(func() -> bool: return host.song.is_dancing() and guest.song.is_dancing(), 5.0)
	assert_eq(guest.song.distractions, host.song.distractions)
	host.song.fix()
	await wait_until(func() -> bool: return not guest.song.is_dancing(), 5.0)
	assert_false(guest.song.is_dancing(), "her routine ends on the guest when it ends on the host")


func test_glass_broken_on_the_host_breaks_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Rink = OnlinePcs.level(pcs[0])
	var guest: Rink = OnlinePcs.level(pcs[1])
	host.break_glass(2)
	host.break_trophies()
	await wait_until(func() -> bool: return guest.glass_left() == host.glass_left() and guest.trophies_cracked, 5.0)
	assert_eq(guest.glass_left(), Rink.GLASS_XS.size() - 1)
	assert_true(guest.trophies_cracked)
	assert_eq(guest.fines, host.fines)


func test_a_cup_poured_and_spilled_on_the_host_spills_on_the_guest_and_copito_talks_on_both() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Rink = OnlinePcs.level(pcs[0])
	var guest: Rink = OnlinePcs.level(pcs[1])
	var cup := host.pour_cocoa()
	await wait_until(func() -> bool: return guest.get_node_or_null(NodePath(cup.name)) != null, 5.0)
	var copy := guest.get_node_or_null(NodePath(cup.name)) as CocoaCup
	assert_not_null(copy, "the guest got a copy with the same name")
	assert_true(copy.full)
	cup.spill()
	await wait_until(func() -> bool: return not copy.full, 5.0)
	assert_false(copy.full, "spilled on the guest too")
	host.copito._tell("COPITO_THANKS", 4.0)
	await wait_until(func() -> bool: return guest.copito.news_count == host.copito.news_count, 5.0)
	assert_eq((guest.copito.get_node("Bubble") as Label3D).text, "COPITO_THANKS", "he says it on the guest")


func test_a_goal_on_the_host_scoreboard_shows_on_the_guest() -> void:
	_story = "fixed_match"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Rink = OnlinePcs.level(pcs[0])
	var guest: Rink = OnlinePcs.level(pcs[1])
	var host_rig := host.rig as FixedMatchRig
	var guest_rig := guest.rig as FixedMatchRig
	host_rig.goal()
	host_rig.goal()
	await wait_until(func() -> bool: return guest_rig.goals == 2, 5.0)
	assert_eq(guest_rig.home_label.text, host_rig.home_label.text)
	assert_eq(guest_rig.away_label.text, host_rig.away_label.text)


func test_the_golden_skate_clangs_on_the_guest_when_it_does_on_the_host() -> void:
	_story = "golden_skate"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Rink = OnlinePcs.level(pcs[0])
	var guest: Rink = OnlinePcs.level(pcs[1])
	(host.rig as GoldenSkateRig).clang()
	await wait_until(func() -> bool: return (guest.rig as GoldenSkateRig).clangs == 1, 5.0)
	assert_eq((guest.rig as GoldenSkateRig).clangs, 1)
	assert_has(guest.raid.objective_facts().clues, tr("CLUE_HEAVY_SKATE"), "the clue is on every checklist")
