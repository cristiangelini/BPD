extends GutTest

## The apartment building online (docs/diseno/edificio.md, step 9): the host runs the elevator, the scaffold, Doña
## Pepa's walks and the pigeons, and the guests' copies follow; what a guest's cop does to them reaches the host.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const TOWER := preload("res://scenes/levels/apartment_tower.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "stolen_aquarium"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_tower)


func after_each() -> void:
	Engine.time_scale = 1.0
	_pcs.free_all()
	await wait_process_frames(2)


func _make_tower() -> Node3D:
	var tower: ApartmentTower = TOWER.instantiate()
	tower.case_seed = SEED
	tower.story_id = _story
	return tower


func test_a_guest_calls_the_elevator_and_every_pc_sees_it_ride() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: ApartmentTower = OnlinePcs.level(pcs[0])
	var guest: ApartmentTower = OnlinePcs.level(pcs[1])
	assert_false(guest.elevator.is_physics_processing(), "the guest's car only follows")
	OnlinePcs.own_cop(pcs[1]).act("use", guest.calls[1])
	await wait_until(func() -> bool: return host.elevator.moving and guest.elevator.moving, 5.0)
	assert_true(host.elevator.moving, "the guest's call reached the host")
	Engine.time_scale = 4.0
	await wait_until(func() -> bool: return not host.elevator.moving and not guest.elevator.moving \
		and guest.elevator.is_open(), 30.0)
	assert_eq(host.elevator.at_stop, 1)
	assert_eq(guest.elevator.at_stop, 1, "up at 30 on the guest too")
	await wait_until(func() -> bool: return guest.elevator.global_position.distance_to(host.elevator.global_position) < 0.05, 5.0)
	assert_almost_eq(guest.elevator.global_position.y, host.elevator.global_position.y, 0.05)
	assert_eq(guest.elevator.current_floor(), ApartmentTower.FLOORS, "its display says 30")


func test_the_scaffold_goes_down_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: ApartmentTower = OnlinePcs.level(pcs[0])
	var guest: ApartmentTower = OnlinePcs.level(pcs[1])
	assert_false(guest.scaffold.is_physics_processing(), "the guest's scaffold only follows")
	OnlinePcs.own_cop(pcs[1]).act("use", guest.scaffold.buttons[0])
	await wait_until(func() -> bool: return host.scaffold.direction == -1 and guest.scaffold.direction == -1, 5.0)
	assert_eq(host.scaffold.direction, -1, "the guest's button reached the host")
	await wait_seconds(2.0)
	assert_lt(host.scaffold.deck_y, ApartmentTower.TOP_Y - 1.0, "going down")
	assert_almost_eq(guest.scaffold.global_position.y, host.scaffold.global_position.y, 0.6, "the guest's copy follows")


func test_a_guest_walks_cuqui_and_lets_go_when_the_host_says() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: ApartmentTower = OnlinePcs.level(pcs[0])
	var guest: ApartmentTower = OnlinePcs.level(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.global_position = guest.to_global(ApartmentTower.PEPA_AT + Vector3(0, 0.1, 1.0))
	await wait_physics_frames(5)
	guest_cop.act("use", guest.pepa)
	await wait_until(func() -> bool: return host.pepa.walker() != null and guest.pepa.walker() == guest_cop, 5.0)
	assert_not_null(host.pepa.walker(), "the leash went to the guest's cop on the host")
	assert_eq(guest_cop.leash, guest.pepa.dog, "and on the guest")
	# The guest's cop takes the elevator with the leash: on the host the walk ends and Cuqui runs home.
	host.pepa._end_walk(false)
	await wait_until(func() -> bool: return guest.pepa.walker() == null, 5.0)
	assert_null(guest_cop.leash, "the guest's hands are free again")


func test_the_pigeons_fly_on_every_pc_and_a_guest_takes_the_necklace() -> void:
	_story = "carrier_pigeons"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: ApartmentTower = OnlinePcs.level(pcs[0])
	var guest: ApartmentTower = OnlinePcs.level(pcs[1])
	var host_rig := host.rig as CarrierPigeonsRig
	var guest_rig := guest.rig as CarrierPigeonsRig
	await wait_physics_frames(5)
	host_rig.send_pigeon()
	await wait_until(func() -> bool: return guest_rig.pigeon.state == MessengerPigeon.State.LANDED, 10.0)
	assert_true(guest_rig.pigeon.visible, "it landed on the guest's loft too")
	assert_true(guest_rig.pigeon.carries)
	await wait_seconds(0.5)
	assert_lt(guest_rig.pigeon.global_position.distance_to(host_rig.pigeon.global_position), 0.1, "on the same spot")
	OnlinePcs.own_cop(pcs[1]).act("use", guest_rig.pigeon)
	await wait_until(func() -> bool: return host_rig.necklace.visible and guest_rig.necklace.visible, 5.0)
	assert_false(host_rig.necklace.freeze, "the host simulates it")
	assert_true(guest_rig.necklace.freeze, "the guest's copy only follows")


func test_the_guest_never_sends_pigeons_of_its_own() -> void:
	_story = "carrier_pigeons"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest: ApartmentTower = OnlinePcs.level(pcs[1])
	var guest_rig := guest.rig as CarrierPigeonsRig
	guest_rig._next = 0.0
	await wait_physics_frames(5)
	assert_eq(guest_rig.pigeon.state, MessengerPigeon.State.AWAY)


func test_the_31_button_from_a_guest_takes_the_hosts_car_up() -> void:
	_story = "floor_31"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: ApartmentTower = OnlinePcs.level(pcs[0])
	var guest: ApartmentTower = OnlinePcs.level(pcs[1])
	(host.rig as Floor31Rig).opened = true
	(guest.rig as Floor31Rig).opened = true
	OnlinePcs.own_cop(pcs[1]).act("use", (guest.rig as Floor31Rig).button)
	await wait_until(func() -> bool: return host.elevator.moving, 5.0)
	Engine.time_scale = 4.0
	await wait_until(func() -> bool: return guest.elevator.at_stop == Floor31Rig.SECRET_STOP \
		and not guest.elevator.moving, 30.0)
	assert_eq(host.elevator.at_stop, Floor31Rig.SECRET_STOP, "the host's car went up to 31")
	assert_eq(guest.elevator.at_stop, Floor31Rig.SECRET_STOP, "and the guest's")
