class_name OvenTunnelRig
extends PizzaRaidRig

## The oven with a tunnel (allanamiento-pizzeria.md, "El horno con túnel"): Don Muzza digs from his oven to the bank
## next door. Soot prints go from the oven's mouth to his office, the story's own clue. The fire extinguisher on the
## kitchen's wall (E) puts the oven out; then E on its mouth crawls a cop into the tunnel under the yard, where the
## bank's silver bag waits at the far end, and the button by the way in brings the cop (and what they carry) back out
## in front of the oven. Every number here is (propuesta).

const EXTINGUISHER_MODEL := preload("res://assets/models/fire_extinguisher.glb")
const SOOT_MODEL := preload("res://assets/models/soot_print.glb")
## The extinguisher hangs on the kitchen's side of the wall to the office.
const EXTINGUISHER_AT := Vector3(PizzaRaid.KITCHEN_X - 0.12, PizzaRaid.FLOOR_TOP + 0.9, -2.6)
## The tunnel under the yard: its floor, its width and height, from below the oven to the chamber at its end.
const TUNNEL_FLOOR := -3.0
const TUNNEL_X := -5.5
const TUNNEL_WIDTH := 1.4
const TUNNEL_HEIGHT := 1.3
const TUNNEL_FROM_Z := -2.6
const TUNNEL_TO_Z := -7.8
## Where the bank's silver bag waits, in the chamber at the far end.
const BAG_AT := Vector3(TUNNEL_X, TUNNEL_FLOOR + 0.2, -7.3)
## Where a cop crawls in (facing the far end) and comes back out (in front of the oven, facing the kitchen).
const IN_AT := Vector3(TUNNEL_X, TUNNEL_FLOOR + 0.1, TUNNEL_FROM_Z - 0.6)
const OUT_AT := Vector3(PizzaRaid.OVEN_AT.x, PizzaRaid.FLOOR_TOP + 0.1, -1.3)
## The soot prints' path: the oven's mouth, around the dough table, through the kitchen's opening and the dining room,
## into the office to the desk. One print every PRINT_STEP meters.
const PRINT_PATH: Array[Vector3] = [Vector3(-5.4, PizzaRaid.FLOOR_TOP, -1.7), Vector3(-4.8, PizzaRaid.FLOOR_TOP, 1.2),
	Vector3(-3.0, PizzaRaid.FLOOR_TOP, 2.6), Vector3(5.0, PizzaRaid.FLOOR_TOP, 2.8),
	Vector3(5.0, PizzaRaid.FLOOR_TOP, 1.4), Vector3(3.8, PizzaRaid.FLOOR_TOP, 0.6)]
const PRINT_STEP := 0.7
const PRINT_SIDE := 0.1
const EARTH := Color(0.42, 0.3, 0.2)
const FSSH := Color(0.9, 0.95, 1.0)

var extinguisher: PushButton
var exit_button: PushButton
var first_print: ClueNote
var prints: Array[Node3D] = []
## The tunnel's room (the pizzeria's space): a cop in it crawls.
var tunnel_box: AABB
var put_out := false


func setup(place: PizzaRaid) -> void:
	super.setup(place)
	var tunnel := Node3D.new()
	tunnel.name = "OvenTunnel"
	pizzeria.add_child(tunnel)
	extinguisher = PushButton.new()
	extinguisher.prompt = "PROMPT_EXTINGUISHER"
	extinguisher.position = EXTINGUISHER_AT
	extinguisher.rotation.y = -PI / 2
	tunnel.add_child(extinguisher)
	for part in extinguisher.get_children():
		if part is MeshInstance3D:
			part.hide()
	var look: Node3D = EXTINGUISHER_MODEL.instantiate()
	look.position = Vector3(0, -0.25, -0.09)
	extinguisher.add_child(look)
	extinguisher.pressed.connect(func(_cop: Cop) -> void: put_out_oven())
	_dig()
	exit_button = PushButton.new()
	exit_button.prompt = "PROMPT_TUNNEL_OUT"
	exit_button.position = Vector3(TUNNEL_X + 0.4, TUNNEL_FLOOR + 0.6, TUNNEL_FROM_Z - 0.1)
	exit_button.rotation.y = PI
	tunnel.add_child(exit_button)
	exit_button.pressed.connect(crawl_out)
	pizzeria.oven.crawled_in.connect(crawl_in)
	_leave_prints()


## The tunnel's floor, walls and ceiling, a light, and the chamber at the end where the bag waits.
func _dig() -> void:
	var build := PlaceBuilder.new(pizzeria.get_node("Built"))
	var x0 := TUNNEL_X - TUNNEL_WIDTH / 2
	var x1 := TUNNEL_X + TUNNEL_WIDTH / 2
	var length := TUNNEL_FROM_Z - TUNNEL_TO_Z
	var mid_z := (TUNNEL_FROM_Z + TUNNEL_TO_Z) / 2
	var wall := PlaceBuilder.WALL
	build.slab(x0, x1, TUNNEL_TO_Z, TUNNEL_FROM_Z, TUNNEL_FLOOR, EARTH)
	build.box(Vector3(TUNNEL_X, TUNNEL_FLOOR + TUNNEL_HEIGHT + wall / 2, mid_z), Vector3(TUNNEL_WIDTH, wall, length), EARTH)
	for x: float in [x0 - wall / 2, x1 + wall / 2]:
		build.box(Vector3(x, TUNNEL_FLOOR + TUNNEL_HEIGHT / 2, mid_z), Vector3(wall, TUNNEL_HEIGHT, length), EARTH)
	for z: float in [TUNNEL_FROM_Z + wall / 2, TUNNEL_TO_Z - wall / 2]:
		build.box(Vector3(TUNNEL_X, TUNNEL_FLOOR + TUNNEL_HEIGHT / 2, z), Vector3(TUNNEL_WIDTH + wall * 2, TUNNEL_HEIGHT,
			wall), EARTH)
	build.light(Vector3(TUNNEL_X, TUNNEL_FLOOR + TUNNEL_HEIGHT - 0.2, mid_z))
	tunnel_box = AABB(Vector3(x0, TUNNEL_FLOOR - 0.5, TUNNEL_TO_Z), Vector3(TUNNEL_WIDTH, TUNNEL_HEIGHT + 0.5, length))


## Soot prints from the oven to the office, left and right; the first one is the clue.
func _leave_prints() -> void:
	var left := true
	for leg in PRINT_PATH.size() - 1:
		var from := PRINT_PATH[leg]
		var to := PRINT_PATH[leg + 1]
		var along := (to - from).normalized()
		var side := along.cross(Vector3.UP) * (PRINT_SIDE if left else -PRINT_SIDE)
		var steps := maxi(1, floori(from.distance_to(to) / PRINT_STEP))
		for i in steps:
			var at := from + along * (i * PRINT_STEP) + side + Vector3.UP * 0.003
			left = not left
			side = -side
			var turn := atan2(-along.x, -along.z)
			if prints.is_empty():
				first_print = clue_item("SootPrint", SOOT_MODEL, Vector3(0.12, 0.02, 0.26), at, "PROMPT_SOOT_PRINTS",
					"CLUE_SOOT_PRINTS")
				first_print.freeze = true
				first_print.rotation.y = turn
				prints.append(first_print)
				continue
			var soot: Node3D = SOOT_MODEL.instantiate()
			soot.position = at
			soot.rotation.y = turn
			pizzeria.add_child(soot)
			prints.append(soot)


## The extinguisher puts the oven out for good: its fire goes, nothing burns, and its mouth lets a cop in.
func put_out_oven() -> void:
	if put_out:
		return
	put_out = true
	pizzeria.oven.lit = false
	pizzeria.oven.button.prompt = "PROMPT_OVEN_CRAWL"
	for fire in pizzeria.oven_model.find_children("fire*", "", true, false):
		(fire as Node3D).hide()
	pizzeria.raid.float_label(tr("OVEN_FSSH"), pizzeria.oven.global_position + Vector3.UP * 0.6, FSSH)


## Into the put-out oven: the cop comes out at the tunnel's near end, still holding what they held.
func crawl_in(cop: Cop) -> void:
	_carry_warp(cop, pizzeria.global_transform * Transform3D(Basis.IDENTITY, IN_AT))
	cop.show_hint("HINT_TUNNEL_CRAWL")


## The button at the tunnel's near end: back out in front of the oven, with what they carry.
func crawl_out(cop: Cop) -> void:
	_carry_warp(cop, pizzeria.global_transform * Transform3D(Basis(Vector3.UP, PI), OUT_AT))
	cop.crawling = false


func _carry_warp(cop: Cop, to: Transform3D) -> void:
	var grabber := cop.get_node("Grabber")
	var held: Grabbable = grabber.held
	cop.warp(to)
	if held:
		held.global_position = to.origin + Vector3.UP * 0.6 - to.basis.z * 0.5
		grabber.grab(held)


## In the tunnel a cop crawls, as in the jail's duct.
func _physics_process(_delta: float) -> void:
	for cop: Cop in pizzeria.get_tree().get_nodes_in_group("cops"):
		var inside := tunnel_box.has_point(pizzeria.to_local(cop.global_position))
		cop.crawling = inside
		if inside and not cop.is_crouching:
			cop.set_crouching(true)


func net_state() -> Variant:
	return put_out


func apply_net_state(state: Variant) -> void:
	if state and not put_out:
		put_out_oven()
