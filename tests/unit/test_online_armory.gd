extends GutTest

## The armory online (docs/diseno/online.md, "Herramientas"): the host's cash box decides, every PC sees what the
## armero handed out, and a guest's list shows the host's money.

const PCS := preload("res://tests/unit/online_pcs.gd")

var pcs: PCS


func before_each() -> void:
	pcs = PCS.new(self, func(level: Node3D) -> void:
		var armero := Armero.new()
		armero.name = "Armero"
		armero.armory = Armory.new(StationWallet.new())
		level.add_child(armero))


func after_each() -> void:
	pcs.free_all()
	await wait_process_frames(2)


func _armero(net: Node) -> Armero:
	return PCS.level(net).get_node("Armero")


func test_a_guest_buys_with_the_hosts_cash_box_and_wears_the_gloves_everywhere() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest: Node = pair[1]
	_armero(host).armory.wallet.money = 500
	await wait_until(func() -> bool: return _armero(guest).armory.wallet.money == 500, 5.0)
	assert_eq(_armero(guest).armory.wallet.money, 500, "the guest's list shows the host's cash box")
	var guest_cop := PCS.own_cop(guest)
	var copy: Cop = host.cop_syncs[guest.multiplayer.get_unique_id()].cop
	guest_cop.act("armory_choose", _armero(guest), ["gloves"])
	await wait_until(func() -> bool: return _armero(host).armory.owns("gloves"), 5.0)
	assert_eq(_armero(host).armory.wallet.money, 380, "bought with the host's money")
	guest_cop.act("armory_choose", _armero(guest), ["gloves"])
	await wait_until(func() -> bool: return guest_cop.gloves, 5.0)
	assert_true(copy.gloves, "the host sees the guest's gloves")
	assert_true(guest_cop.gloves, "and the guest wears them")
	await wait_until(func() -> bool: return _armero(guest).armory.wallet.money == 380, 5.0)
	assert_eq(_armero(guest).armory.wallet.money, 380)


func test_the_donut_box_lands_in_the_guests_hands() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest: Node = pair[1]
	_armero(host).armory.wallet.items.append("donuts")
	var guest_cop := PCS.own_cop(guest)
	var copy: Cop = host.cop_syncs[guest.multiplayer.get_unique_id()].cop
	guest_cop.act("armory_choose", _armero(guest), ["donuts"])
	await wait_until(func() -> bool: return guest_cop.get_node("Grabber").held is DonutBox, 5.0)
	assert_true(copy.get_node("Grabber").held is DonutBox, "the host holds it for the guest's cop")
	assert_true(guest_cop.get_node("Grabber").held is DonutBox, "the guest has it in hand")
	var box: DonutBox = guest_cop.get_node("Grabber").held
	guest_cop.act("eat_donut", guest_cop, [box])
	var host_box: DonutBox = copy.get_node("Grabber").held
	await wait_until(func() -> bool: return host_box.donuts == DonutBox.DONUTS - 1, 5.0)
	assert_eq(host_box.donuts, DonutBox.DONUTS - 1, "one donut less on the host")
	assert_eq(box.donuts, DonutBox.DONUTS - 1, "and on the guest")


func test_the_list_opens_only_on_the_screen_of_who_asked() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest: Node = pair[1]
	var guest_cop := PCS.own_cop(guest)
	guest_cop.act("use", _armero(guest))
	await wait_until(func() -> bool: return _armero(guest).menu.visible, 5.0)
	await wait_process_frames(5)
	assert_true(_armero(guest).menu.visible, "the guest sees the armero's list")
	assert_false(_armero(host).menu.visible, "the host doesn't")
	_armero(guest).menu.close()
