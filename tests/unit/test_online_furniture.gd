extends GutTest

## The furniture store raid online (allanamiento-muebleria.md, step 7): Don Cajón is run by the host and followed by
## the guests, a guest trying a sofa brings him over on the host, the host decides the broken goods, the tipped
## wardrobes and the fallen chair tower for everyone, and Tablita's shelf held by a guest's cop is screwed in on every
## PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const STORE := preload("res://scenes/levels/furniture_store.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "stuffed_sofas"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_store)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_store() -> Node3D:
	var store: FurnitureStore = STORE.instantiate()
	store.case_seed = SEED
	store.story_id = _story
	return store


func test_don_cajon_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FurnitureStore = OnlinePcs.level(pcs[0])
	var guest: FurnitureStore = OnlinePcs.level(pcs[1])
	assert_false(guest.cajon.is_physics_processing(), "the guest's Don Cajón only follows")
	host.cajon.scold(30.0, "CAJON_SAW")
	await wait_until(func() -> bool: return absf(guest.cajon.complaint - host.cajon.complaint) < 0.5 \
		and guest.cajon.complaint > 20.0 \
		and guest.cajon.global_position.distance_to(host.cajon.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.cajon.complaint, host.cajon.complaint, 1.5, "a decay step apart at most")
	assert_almost_eq(guest.complaint_bar.value, guest.cajon.complaint, 0.01, "and the guest's bar shows it")


func test_a_guest_trying_a_sofa_brings_him_over_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FurnitureStore = OnlinePcs.level(pcs[0])
	var guest: FurnitureStore = OnlinePcs.level(pcs[1])
	var cop := OnlinePcs.own_cop(pcs[1])
	cop.global_position = guest.sofas[0].global_position + Vector3(0, 0.5, 1.0)
	cop.act("use", guest.sofas[0])
	await wait_until(func() -> bool: return host.pitch.is_jammed, 5.0)
	assert_true(host.pitch.is_jammed, "the guest's E reached the host")
	assert_eq(host.cajon.errand(), "printer", "and Don Cajón goes to sell it")


func test_goods_wardrobes_and_the_tower_go_down_on_the_guest_too() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FurnitureStore = OnlinePcs.level(pcs[0])
	var guest: FurnitureStore = OnlinePcs.level(pcs[1])
	host.break_good(1)
	host.wardrobes[0].tip()
	host.chair_tower.knock_over(Vector3.RIGHT)
	await wait_until(func() -> bool: return guest.broken.has(1) and guest.wardrobes[0].is_tipped \
		and guest.chair_tower.has_fallen, 5.0)
	assert_eq(guest.broken, [1] as Array[int], "only that one broke on the guest")
	assert_true(guest.wardrobes[0].is_tipped)
	assert_false(guest.wardrobes[1].is_tipped)
	assert_true(guest.chair_tower.has_fallen)
	var loose := guest.find_children("*", "LooseChair", true, false).size() \
		+ guest.get_parent().find_children("*", "LooseChair", true, false).size()
	assert_gt(loose, 0, "the loose chairs came over as props")


## The other player's cop in `pc`'s level (with two PCs, the copy of the other one's own cop).
func _other_cop(pc: Node) -> Cop:
	var level := OnlinePcs.level(pc)
	for node in level.get_tree().get_nodes_in_group("cops"):
		if node != OnlinePcs.own_cop(pc) and level.is_ancestor_of(node):
			return node
	return null


func test_one_pull_on_a_guest_doesnt_tip_a_wardrobe() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest: FurnitureStore = OnlinePcs.level(pcs[1])
	guest.wardrobes[0].use(_other_cop(pcs[1]))
	guest.wardrobes[0].use(OnlinePcs.own_cop(pcs[1]))
	assert_false(guest.wardrobes[0].is_tipped, "the host decides the pair")


func test_tablitas_shelf_held_by_a_guest_is_screwed_in_everywhere() -> void:
	_story = "comisario_chair"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FurnitureStore = OnlinePcs.level(pcs[0])
	var guest: FurnitureStore = OnlinePcs.level(pcs[1])
	var cop := OnlinePcs.own_cop(pcs[1])
	cop.global_position = guest.shelf.global_position + Vector3(0, 0, 1.0)
	var copy := _other_cop(pcs[0])
	await wait_until(func() -> bool: return copy.global_position.distance_to(host.to_global(guest.to_local(
		cop.global_position))) < 0.05, 5.0)
	# The player keeps E down while holding it (both PCs share this process's keys).
	Input.action_press("use")
	cop.act("use", guest.shelf)
	await wait_until(func() -> bool: return host.shelf.holder != null and guest.shelf.holder != null, 5.0)
	host.shelf.held_for = BookcaseShelf.HOLD_TIME - 0.05

	await wait_until(func() -> bool: return guest.tablita.has_told, 5.0)
	Input.action_release("use")
	assert_true(host.tablita.has_told, "Tablita talked on the host")
	assert_true(guest.tablita.has_told, "and on the guest")
	assert_null(guest.shelf.holder)
	assert_null(cop.turning, "the guest's cop is free again")
	assert_false(guest.shelf.is_down(), "screwed in, not fallen")


func test_only_the_hosts_don_cajon_offers_installments() -> void:
	_story = "endless_installments"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: FurnitureStore = OnlinePcs.level(pcs[0])
	var guest: FurnitureStore = OnlinePcs.level(pcs[1])
	var cop := OnlinePcs.own_cop(pcs[1])
	var eye := guest.cajon.global_position + Vector3.UP * FloorBoss.EYE
	cop.global_position = guest.cajon.global_position + Vector3(0, 0, 3.0)
	cop.camera.look_at(eye, Vector3.UP)
	await wait_physics_frames(3)
	assert_eq((guest.rig as EndlessInstallmentsRig).offers, 0, "not on the guest")
	(host.rig as EndlessInstallmentsRig).offer(host.get_tree().get_nodes_in_group("cops")[0])
	await wait_until(func() -> bool: return (guest.cajon.get_node("Bubble") as Label3D).text.begins_with("CAJON_OFFER"), 5.0)
	assert_string_starts_with((guest.cajon.get_node("Bubble") as Label3D).text, "CAJON_OFFER", "his bubble shows it")
