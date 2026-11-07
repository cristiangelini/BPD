extends GutTest

## The pawn shop online (allanamiento-empenos.md, step 8): Don Regateo, Chicharra and the customers are run by the host
## and followed by the guests, what breaks on the host breaks on the guest, the counter's prices and money are the
## host's, the cookie and the parrot work from any PC and the stories' host-only moments reach the guests.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SHOP := preload("res://scenes/levels/pawn_shop.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "train_watches"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_shop)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_shop() -> Node3D:
	var shop: PawnShop = SHOP.instantiate()
	shop.case_seed = SEED
	shop.story_id = _story
	return shop


func test_regateo_chicharra_and_the_customers_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PawnShop = OnlinePcs.level(pcs[0])
	var guest: PawnShop = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_boss.is_physics_processing(), "the guest's Don Regateo only follows")
	assert_false(guest.parrot.is_physics_processing(), "and so does Chicharra")
	assert_false(guest.customers[0].is_physics_processing(), "and the customers")
	host.owner_boss.complaint = 30.0
	host.parrot._squawk_left = 0.01
	host._turn_left = 0.01
	await wait_until(func() -> bool: return absf(guest.owner_boss.complaint - 30.0) < 0.5 \
		and guest.parrot.said() != "" and guest.customers[0].on_turn == false \
		and guest.customers[0].global_position.distance_to(host.customers[0].global_position) < 0.3 \
		and host.customers[0].position.distance_to(host.customers[0].home) > 0.5, 8.0)
	assert_almost_eq(guest.owner_boss.complaint, 30.0, 0.5)
	assert_eq(guest.parrot.said(), host.parrot.said(), "he squawks on every PC")
	assert_lt(guest.customers[0].global_position.distance_to(host.customers[0].global_position), 0.3,
		"the customer walks to the counter on every PC")
	assert_null(guest.on_turn, "only the host gives the turns")


func test_a_guest_feeds_chicharra_and_every_pc_gets_the_clue() -> void:
	TranslationServer.set_locale("es")
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PawnShop = OnlinePcs.level(pcs[0])
	var guest: PawnShop = OnlinePcs.level(pcs[1])
	var cop := OnlinePcs.own_cop(pcs[1])
	cop.act("use", guest.cookie_jar)
	cop.act("use", guest.parrot)
	await wait_until(func() -> bool: return host.parrot.has_told and guest.parrot.has_told, 5.0)
	assert_has(host.raid.clues_found, host.parrot.clue, "on the host")
	assert_has(guest.raid.clues_found, guest.parrot.clue, "and on the guest")


func test_what_breaks_and_the_counters_prices_reach_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PawnShop = OnlinePcs.level(pcs[0])
	var guest: PawnShop = OnlinePcs.level(pcs[1])
	host.break_case(2)
	host.knock_armor()
	var trophy := host.goods[0]
	host.counter.for_sale.erase(trophy)
	host.counter._untag(trophy)
	host.counter.spent = 8
	host.counter.for_sale[host.main] = 40
	host.counter._tag(host.main, 40)
	await wait_until(func() -> bool: return guest.cases_broken[2] and guest.armor_down and guest.counter.spent == 8 \
		and guest.counter.for_sale.has(guest.main), 5.0)
	assert_true(guest.cases_broken[2])
	assert_true(guest.armor_down)
	assert_eq(guest.counter.spent, 8)
	assert_null(guest.goods[0].get_node_or_null("PriceTag"), "bought: no tag")
	assert_eq((guest.main.get_node("PriceTag") as Label3D).text, "$40", "pawned: its tag")


func test_the_walking_armor_steps_on_every_pc() -> void:
	_story = "walking_armor"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PawnShop = OnlinePcs.level(pcs[0])
	var guest: PawnShop = OnlinePcs.level(pcs[1])
	(host.rig as WalkingArmorRig).step()
	(host.rig as WalkingArmorRig).step()
	await wait_until(func() -> bool: return (guest.rig as WalkingArmorRig).steps == 2, 5.0)
	assert_almost_eq(guest.armor_at, host.armor_at, Vector3.ONE * 0.01)
	await wait_physics_frames(10)
	assert_eq((guest.rig as WalkingArmorRig).steps, 2, "only the host's clock walks it")


func test_the_crocodile_tinkles_and_drops_its_pearl_on_every_pc() -> void:
	_story = "croc_smuggler"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: PawnShop = OnlinePcs.level(pcs[0])
	var guest: PawnShop = OnlinePcs.level(pcs[1])
	(host.rig as CrocSmugglerRig).tinkle()
	(host.rig as CrocSmugglerRig).drop_pearl()
	await wait_until(func() -> bool: return (guest.rig as CrocSmugglerRig).tinkled \
		and (guest.rig as CrocSmugglerRig).pearl != null, 5.0)
	assert_true((guest.rig as CrocSmugglerRig).tinkled)
	assert_not_null((guest.rig as CrocSmugglerRig).pearl)
