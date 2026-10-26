class_name QueueCar
extends CharacterBody3D

## A car that comes to the traffic control (control-transito.md, "Cómo es el caso", step 3): it drives down the lane
## toward the checkpoint, stops at the barrier or behind the car ahead and waits there until the cops let it through
## (TrafficQueue.release_front), or until the queue runs out of patience and it sneaks by along the sidewalk, knocking
## the cones over. It moves in the checkpoint's space, along local -Z, without physics: cars don't push the cops'
## things, they just stop. Stopped, its driver can be checked: the line they say at the barrier, E for the license and
## the trunk, opened by lifting its lid (step 4 of "El orden para hacerlo"). Online the host's cars drive and the
## guests' copies follow them (NpcSync). In the clown convoy (control-payasos.md) every car is the same tiny clown
## car, with the same plate and a clown at the wheel; opening its door lets out its clowns (ConvoyClown), and it
## won't move until they're all back in. In the fruit truck control (control-frutas.md) every car is a fruit seller's
## pickup, tinted by its color, with a sign on its door, watermelons in its open bed and one crate of another fruit; it
## has no trunk. Every number here is (propuesta).

const SPEED := 30.0 / 3.6
## Brakes and speeds up this hard, in m/s².
const ACCEL := 6.0
const LENGTH := 4.6
## Space left to the car ahead when stopped, in meters.
const GAP := 1.5
## Where its middle stops before the checkpoint's box edge.
const STOP_BEFORE := LENGTH / 2 + 0.5
## Sneaking, it moves over this far toward the sidewalk (the checkpoint's +X).
const SNEAK_SIDE := 4.5
## Pulled over, it waits this far toward the curb, with two wheels on the sidewalk.
const CURB_SIDE := 3.2
## Cones this close to it when sneaking get knocked over, with this kick (m/s).
const KNOCK_REACH := 1.6
const KNOCK_SPEED := 4.0
## Gone this far past the checkpoint.
const GONE_AT := -60.0
## The trunk's hinge, in the car's space (forward is +Z, so the trunk is at the back).
const TRUNK_HINGE := Vector3(0, 1.0, -1.35)
## From the hinge to the back bumper.
const TRUNK_LENGTH := LENGTH / 2 + TRUNK_HINGE.z
const TRUNK_INSIDE := Vector3(0, 0.55, -1.8)
const BAG := Color(0.45, 0.3, 0.2)
const CONTRABAND := Color(0.85, 0.75, 0.3)
## The clown cars' trunks (control-payasos.md): cream pies, and the ringmaster's safe or a cardboard one.
const PIE := Color(0.85, 0.65, 0.35)
const CREAM := Color(0.98, 0.95, 0.9)
const SAFE := Color(0.25, 0.27, 0.3)
const SAFE_DIAL := Color(0.8, 0.7, 0.3)
const GRANDPA := preload("res://assets/models/npc_abuelo.glb")
const SAY_SECONDS := 4.0
## With its tires flat (control-carrera.md, step 3): a city car limps on this fast; a racer brakes this hard.
const FLAT_SPEED := 2.0
const FLAT_BRAKE := 10.0
const FLAT_SQUASH := 0.6
const FLAT_LINES := 10
const CITY_FLAT_LINES := 3
## The clown car (escena-circo.md's getaway, control-payasos.md): 2 m long, with its own small trunk at the back.
const CLOWN_MODEL := preload("res://assets/models/clown_car.glb")
const CLOWN_DRIVER := preload("res://assets/models/npc_payaso.glb")
const CLOWN_DRIVER_AT := Vector3(0, 0.45, -0.25)
const CLOWN_DRIVER_SCALE := 0.8
const CLOWN_LENGTH := 2.0
const CLOWN_WIDTH := 1.25
const CLOWN_TRUNK_HINGE := Vector3(0, 0.95, -0.55)
## High enough to show above its round body once the trunk is open.
const CLOWN_TRUNK_INSIDE := Vector3(0, 0.82, -0.75)
const CLOWN_LID := Vector3(0.8, 0.05, 0.42)
## Its trunk's things, shrunk to fit.
const CLOWN_TRUNK_SCALE := 0.5
## The door on the driver's side (+X): its hinge at the front, closed along -Z.
const CLOWN_DOOR_HINGE := Vector3(0.64, 0.75, 0.45)
const CLOWN_DOOR := Vector3(0.05, 0.55, 0.6)
## A clown car honks its horn this often while it waits (control-payasos.md: each one sounds its own way).
const HONK_EVERY := 9.0
## How many clowns come out of one car (control-payasos.md, answer 1).
const CLOWN_RIDERS := Vector2i(3, 6)
## A city car's front door on the driver's side (control-auto-lleno.md), the riders' way out.
const SEDAN_DOOR_HINGE := Vector3(1.08, 1.0, 0.85)
const SEDAN_DOOR := Vector3(0.05, 0.85, 1.0)
const SEDAN_DOOR_OUT := Vector3(1.7, 0.0, 0.35)
## Riders pop out of a packed car one after the other, this often, and this fast (the cork of a champagne bottle).
const POP_EVERY := 0.35
const POP_SPEED := 3.5
## The fruit seller's pickup (control-frutas.md): its paint per WantedPlan.COLORS (white, yellow, green, blue).
const FRUIT_MODEL := preload("res://assets/models/fruit_truck.glb")
const FRUIT_PAINTS: Array[Color] = [Color("f2f2ee"), Color("e8c547"), Color("5b9a5a"), Color("7aa6d8")]
const FRUIT_HATS := preload("res://assets/models/fruit_hats.glb")
## The fruit seller at the wheel, by their name's place in DriverTraits.NAMES (every other one is a woman's).
const FRUIT_SELLERS: Array[PackedScene] = [preload("res://assets/models/npc_cliente.glb"),
	preload("res://assets/models/npc_clienta.glb")]
## Seated on the driver's side (+X), head in the open window.
const FRUIT_SELLER_AT := Vector3(0.5, -0.05, 1.1)
## How many watermelons ride in its bed (control-frutas.md, "Cómo es").
const FRUIT_MELONS := Vector2i(6, 10)
## The bed's floor and its spots for watermelons, back first; the crate takes the front right.
const FRUIT_BED := 0.84
const FRUIT_SPOTS: Array[Vector2] = [Vector2(-0.6, -1.9), Vector2(0.0, -1.9), Vector2(0.6, -1.9), Vector2(-0.6, -1.35),
	Vector2(0.0, -1.35), Vector2(0.6, -1.35), Vector2(-0.6, -0.8), Vector2(0.0, -0.8), Vector2(0.6, -0.8),
	Vector2(-0.6, -0.25), Vector2(0.0, -0.25)]
## The sign painted on the driver's door.
const FRUIT_SIGN_AT := Vector3(1.07, 1.05, 1.0)

## "coming", "waiting", "going" (let through), "sneaking", "pulled_over" (detained, by the curb) or "gone".
var state := "coming"
var checkpoint: TrafficCheckpoint
## The car right in front in the queue, if any.
var ahead: QueueCar
var look := 0
var speed := 0.0
## Its place in the checkpoint's space: x across the lane, z along it.
var at := Vector3.ZERO
## From DriverTraits.draw: name, surname, year, line and trunk.
var driver: Dictionary = {}
var plate := ""
## One of the clown convoy's clown cars.
var clown := false
var door: TrunkLid
## Its clowns out on the street; while there's any, it won't move.
var clowns_out: Array[ConvoyClown] = []
var spilled := false
## Online, a guest's copy: its clowns come from the host's (PropSync), not out of its own door.
var follower := false
## The clown at the wheel (ConvoyTraits.draw): what the clues are about.
var clown_traits := {}
## One of the fruit truck control's pickups.
var fruit := false
## Its crate of other fruit (FruitTraits.CRATES): the plan's, or else from its plate.
var crate := ""
## Its fruit seller's hat (FruitTraits.HATS): the plan's, or else from its plate.
var hat := ""
## Each watermelon's Watermelon.kind, in order (the plan's); missing ones are normal.
var melon_kinds: Array[String] = []
## In the crowded car control (control-auto-lleno.md): how many ride in it, its driver too. 0 elsewhere.
var crowd := 0
## In the ghost car control (control-auto-fantasma.md) every driver leans on their open window...
var ghost_mode := false
## ...but this one has nobody at the wheel: the Titiritero drives it by remote control.
var ghost := false
## Its window driver's shirt (one of GhostCar.SHIRTS): the plan's, or else from its plate.
var shirt := -1
## Its driver drives the ghost car by remote control, from a few cars behind it.
var puppeteer := false
## The ghost car's pranks move it this far from its place in the queue (GhostPilot), forward is -.
var lurch := 0.0
## Times a cop tried E at its empty window.
var knocked := 0
## In the wedding breathalyzer check (control-boda.md) every driver leans on their open window too...
var wedding_mode := false
## ...and most cars are the wedding's: a ribbon bow, cans tied behind and a bow tie in `tie` (one of GhostCar.SHIRTS).
var guest := false
var tie := -1
## The bride and the groom's car, with its "just married" board.
var newlyweds := false
## What its driver blows into the breathalyzer (control-boda.md): the plan's, or else -1 and WeddingCar.alcohol_of.
var alcohol := -1.0
## The couple its driver toasts with the license (WeddingCar.BRIDES and GROOMS): the plan's, El Colado's the wrong one.
var couple := 0
## A cop made the driver blow, and what they blew.
var blown := false
## Over the limit, a cop took its driver's keys and a relative took the wheel (control-boda.md, step 3).
var keys_taken := false
## Its honks to celebrate so far, and seconds rolled, for its cans.
var honks := 0
## In the street race check (control-carrera.md) some cars are racers: a spoiler, a number, a neon and sparks, as in
## `race` (RaceCar.draw's).
var race_mode := false
var racer := false
var race := {}
## In the fog check (control-neblina.md) every car has its headlights on, as in `fog` (FogCar.draw's).
var fog_mode := false
var fog := {}
## Warned in the fog (step 2) by a lit cone or a cop's flashlight, it brakes in time. Unwarned, it comes at
## FogCar.BLIND_SPEED and brakes only once it sees what's ahead (FogCar.SIGHT): behind a car it bumps into it, at the
## barrier it runs the checkpoint ("overrun").
var warned := false
## In the circus move check (control-circo.md) most of the queue are circus trucks, each with a cage and an animal
## in it, as in `circus` (CircusTruck.draw's); empty for a city car among them.
var circus_mode := false
var circus := {}
## It bumped into the car ahead in the fog (online, the guest's copy says so too).
var bumped := false
## Its horn's sound over it, seen through the fog (step 3): it answers the foghorn (FogHorn).
var horn_bubble: HornBubble
## A racer comes in a heat, out of the queue (step 2): it gathers at the back corner, revs, then races past the
## checkpoint ("gathering", "revving", "racing" in `state`); `race_slot` is its place in the heat.
var race_slot := 0
var race_left := 0.0
## Over a spike strip (SpikeStrip, step 3): its tires are flat. A racer brakes to a stop and complains ("punctured");
## a city car limps on at FLAT_SPEED.
var flat := false
var _rolled := 0.0
## Zigzagging, it turns this far (radians) with the lane it's crossing.
var _sway := 0.0
## Riders still to pop out of its open door.
var _to_pop := 0
## Riders counted so far, each with their sticker (CrowdRider.stick), and whether a cop looked in to count who stayed.
var counted := 0
var looked_inside := false
## Fined for too many riders (control-auto-lleno.md, answer 2): once all are counted, E on a packed car.
var fined := false
var _pop_left := 0.0
var _honk_left := HONK_EVERY
## The car the case is after (WantedPlan).
var wanted := false
var papers_checked := false
var trunk_checked := false
var lid: TrunkLid
var said_line := false
var _bubble: Label3D
var _bubble_left := 0.0
var _trunk: Node3D


func _ready() -> void:
	add_to_group("queue_cars")
	if fruit:
		_build_fruit_truck()
		_build_labels()
		return
	if not circus.is_empty():
		CircusTruck.build(self, circus)
		_build_labels()
		return
	# The body leaves the trunk's top free, so the cops' hands reach the lid: the cabin and hood, and under the trunk.
	var width := CLOWN_WIDTH if clown else 2.1
	var trunk_length := length() / 2 + trunk_hinge().z
	_add_box(Vector3(width, trunk_hinge().y + 0.4, length() - trunk_length),
		Vector3(0, 0.2 + (trunk_hinge().y + 0.4) / 2, trunk_length / 2))
	var under := trunk_hinge().y - 0.3
	_add_box(Vector3(width, under, trunk_length), Vector3(0, 0.2 + under / 2, -length() / 2 + trunk_length / 2))
	if clown:
		add_child(CLOWN_MODEL.instantiate())
		var driver_model: Node3D = CLOWN_DRIVER.instantiate()
		driver_model.name = "Driver"
		driver_model.position = CLOWN_DRIVER_AT
		driver_model.scale = Vector3.ONE * CLOWN_DRIVER_SCALE
		add_child(driver_model)
		ConvoyTraits.dress(driver_model, clown_traits)
	else:
		var model: Node3D = TrafficCar.MODELS[look % TrafficCar.MODELS.size()].instantiate()
		model.name = "Model"
		add_child(model)
		if CrowdedCar.packed(crowd):
			CrowdedCar.dress(self, plate, crowd)
		for i in SuspectCar.SEDAN_WHEELS.size():
			var wheel: Node3D = TrafficCar.WHEEL.instantiate()
			wheel.name = "Wheel%d" % i
			wheel.position = SuspectCar.SEDAN_WHEELS[i]
			add_child(wheel)
		if ghost:
			GhostCar.rig(self)
			var pilot := GhostPilot.new()
			pilot.name = "Pilot"
			add_child(pilot)
		elif ghost_mode or wedding_mode:
			GhostCar.dress_driver(self, plate, shirt)
		if guest:
			WeddingCar.dress(self, plate, tie, newlyweds)
			_honk_left = WeddingCar.honk_every(plate)
		if racer:
			RaceCar.dress(self, race)
		if fog_mode:
			FogCar.dress(self, fog)
			horn_bubble = HornBubble.new()
			horn_bubble.name = "HornBubble"
			horn_bubble.position = Vector3(0, FogCar.HORN_UP, 0)
			add_child(horn_bubble)
	_build_trunk()
	if clown or crowd > 0:
		_build_door()
	_build_labels()


func _build_labels() -> void:
	var plate_label := Label3D.new()
	plate_label.name = "Plate"
	plate_label.text = shown_plate()
	plate_label.font_size = 48
	plate_label.pixel_size = 0.004
	plate_label.modulate = Color(0.1, 0.1, 0.12)
	plate_label.outline_modulate = Color(0.95, 0.95, 0.9)
	plate_label.outline_size = 18
	var truck := fruit or not circus.is_empty()
	plate_label.position = Vector3(0, 0.5 if clown else 0.62, -length() / 2 - (0.06 if truck else 0.03))
	plate_label.rotation.y = PI
	add_child(plate_label)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.6, 0.6)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	_place()


func length() -> float:
	return CLOWN_LENGTH if clown else LENGTH


func trunk_hinge() -> Vector3:
	return CLOWN_TRUNK_HINGE if clown else TRUNK_HINGE


## Where its middle stops before the checkpoint's box edge.
func stop_before() -> float:
	return length() / 2 + 0.5


## The plate it shows: every clown car has the same one painted on.
func shown_plate() -> String:
	return tr("PLATE_CLOWN") if clown else plate


## Its fruit seller's pickup: the cab and the open bed, with the watermelons sitting in it.
func _build_fruit_truck() -> void:
	_add_box(Vector3(2.1, 1.55, 1.95), Vector3(0, 0.975, 1.325))
	_add_box(Vector3(2.1, 0.64, 2.65), Vector3(0, 0.52, -0.975))
	for side in [-1.0, 1.0]:
		_add_box(Vector3(0.08, 0.45, 2.65), Vector3(side * 1.01, 1.05, -0.975))
	_add_box(Vector3(2.1, 0.45, 0.08), Vector3(0, 1.05, -2.26))
	var model: Node3D = FRUIT_MODEL.instantiate()
	model.name = "Model"
	add_child(model)
	paint_model(model, look)
	if crate.is_empty():
		crate = FruitTraits.CRATES[absi(hash(["fruit crate", plate])) % FruitTraits.CRATES.size()]
	if hat.is_empty():
		hat = FruitTraits.HATS[absi(hash(["fruit hat", plate])) % FruitTraits.HATS.size()]
	for kind in FruitTraits.CRATES:
		var node := model.find_child("crate_" + kind, true, false) as Node3D
		if node:
			node.visible = kind == crate
	for wheel_at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.position = wheel_at
		add_child(wheel)
	_build_seller()
	var bed := Node3D.new()
	bed.name = "Bed"
	add_child(bed)
	for i in melons():
		var melon := Watermelon.new()
		melon.name = "%sMelon%d" % [name, i]
		melon.kind = melon_kinds[i] if i < melon_kinds.size() else "normal"
		melon.position = Vector3(FRUIT_SPOTS[i].x, FRUIT_BED + 0.17, FRUIT_SPOTS[i].y)
		melon.put_in_bed(self)
		bed.add_child(melon)
	var sign := Label3D.new()
	sign.name = "Sign"
	sign.text = tr("FRUIT_SIGN") % driver.get("name", "")
	sign.font_size = 56
	sign.pixel_size = 0.004
	sign.modulate = Color(0.75, 0.15, 0.1)
	sign.outline_modulate = Color(0.98, 0.95, 0.85)
	sign.outline_size = 14
	sign.position = FRUIT_SIGN_AT
	sign.rotation.y = PI / 2
	add_child(sign)


## Its watermelons still in the bed.
func bed_melons() -> Array[Watermelon]:
	var out: Array[Watermelon] = []
	var bed := get_node_or_null("Bed")
	if bed:
		for melon in bed.get_children():
			if melon is Watermelon and (melon as Watermelon).in_bed:
				out.append(melon)
	return out


## The fruit seller at the wheel, in their hat, the only thing on their head.
func _build_seller() -> void:
	var seller: Node3D = FRUIT_SELLERS[maxi(DriverTraits.NAMES.find(driver.get("name", "")), 0) % 2].instantiate()
	seller.name = "Driver"
	seller.position = FRUIT_SELLER_AT
	add_child(seller)
	for id in ["cap", "props", "hair"]:
		var part := seller.find_child(id, true, false) as Node3D
		if part:
			part.visible = false
	var hats: Node3D = FRUIT_HATS.instantiate()
	hats.name = "Hat"
	hats.position = Vector3(0, 1.5, 0)
	seller.add_child(hats)
	for kind in FruitTraits.HATS:
		var node := hats.find_child("hat_" + kind, true, false) as Node3D
		if node:
			node.visible = kind == hat


## Tints every "paint" part of a fruit_truck model in the paint of `look` (the chase's runaway pickup too).
static func paint_model(model: Node, paint_look: int) -> void:
	var paint := StandardMaterial3D.new()
	paint.albedo_color = FRUIT_PAINTS[paint_look % FRUIT_PAINTS.size()]
	_paint(model, paint)


static func _paint(node: Node, material: Material) -> void:
	for child in node.get_children():
		if child is MeshInstance3D and (child.name.begins_with("paint") or child.get_parent().name == "paint"):
			child.material_override = material
		_paint(child, material)


## How many watermelons ride in its bed: from its plate, so every PC agrees.
func melons() -> int:
	return melon_count(plate)


static func melon_count(of_plate: String) -> int:
	return FRUIT_MELONS.x + absi(hash(["fruit melons", of_plate])) % (FRUIT_MELONS.y - FRUIT_MELONS.x + 1)


## How many clowns ride in it: from its plate, so every PC agrees.
func riders() -> int:
	return CLOWN_RIDERS.x + absi(hash(["clown riders", plate])) % (CLOWN_RIDERS.y - CLOWN_RIDERS.x + 1)


## Where its clowns get out and back in, in world space: just outside the door.
func door_point() -> Vector3:
	if crowd > 0:
		return global_transform * SEDAN_DOOR_OUT
	return global_transform * (CLOWN_DOOR_HINGE + Vector3(0.6, -0.75, -CLOWN_DOOR.z / 2))


## It can drive off: no clown of it left on the street.
func can_go() -> bool:
	return clowns_out.is_empty() and _to_pop == 0


func _build_door() -> void:
	door = TrunkLid.new()
	door.name = "Door"
	door.side = true
	door.action = "open_door"
	door.size = SEDAN_DOOR if crowd > 0 else CLOWN_DOOR
	door.position = SEDAN_DOOR_HINGE if crowd > 0 else CLOWN_DOOR_HINGE
	if crowd > 0:
		door.door_prompt = "PROMPT_CAR_DOOR"
	add_child(door)
	door.opened.connect(spill)


## The door opened on some PC: open on this one too.
func open_door() -> void:
	if door and not door.is_open:
		door.set_angle(TrunkLid.MAX_ANGLE)


## Out come its clowns, one after the other, the driver first; its seat is left empty.
func spill() -> void:
	if spilled or not (clown or crowd > 0):
		return
	spilled = true
	if crowd > 0:
		_to_pop = 0 if follower else riders_out()
		_pop_left = 0.0
		return
	var seat := get_node_or_null("Driver") as Node3D
	if seat:
		seat.visible = false
	if follower:
		return
	for i in riders():
		var out := ConvoyClown.new()
		out.name = "%sClown%d" % [name, i]
		out.car = self
		out.is_driver = i == 0
		out.traits = clown_traits if i == 0 else _rider_traits(i)
		clowns_out.append(out)
		_street().add_child(out)
		out.global_position = door_point() + global_basis.z * (0.5 * i - 1.0) + Vector3.UP * 0.1


## How many riders get out of it when its door opens: all of a few; in a packed car, someone always stays in.
func riders_out() -> int:
	return crowd - CrowdedCar.stay_in(plate, crowd)


## A cop counted one of its riders: the next number goes on their sticker and the car says how many so far.
func count_rider(rider: CrowdRider) -> void:
	if rider.sticker > 0:
		return
	counted += 1
	rider.stick(counted)
	say(tr("CROWD_COUNT") % count_so_far())


## How many riders the cops have counted, those who stayed in too once someone looked in.
func count_so_far() -> int:
	return counted + (CrowdedCar.stay_in(plate, crowd) if looked_inside else 0)


## E on its open door: who stayed in gets counted.
func look_inside() -> void:
	if looked_inside or crowd == 0:
		return
	looked_inside = true
	var stay := CrowdedCar.stay_in(plate, crowd)
	say((tr("CROWD_INSIDE") % [stay, count_so_far()]) if stay > 0 else tr("CROWD_INSIDE_NONE") % count_so_far())


## Too many riders and every one counted, out and in, and not fined yet.
func can_fine() -> bool:
	return CrowdedCar.packed(crowd) and not fined and looked_inside and count_so_far() >= crowd


func fine() -> void:
	if not can_fine():
		return
	fined = true
	say(tr("CROWD_FINED") % crowd)
	var case := TrafficCase.of(self)
	if case:
		case.crowd_fined(self)


## The next rider pops out of its door, out toward the sidewalk, the driver first.
func _pop() -> void:
	var i := riders_out() - _to_pop
	_to_pop -= 1
	var out := CrowdRider.new()
	out.name = "%sRider%d" % [name, i]
	out.car = self
	out.is_driver = i == 0
	out.traits = CrowdRider.look_of(plate, i)
	clowns_out.append(out)
	_street().add_child(out)
	out.global_position = global_transform * (SEDAN_DOOR_OUT + Vector3(-0.3, 0.3, 0))
	out.linear_velocity = global_basis.x * POP_SPEED + Vector3.UP * 2.0 + global_basis.z * randf_range(-1.0, 1.0)
	CrowdedCar.show_inside(self, crowd - clowns_out.size())


## Where its clowns walk: the level (its queue's parent), so each one has the same path on every PC.
func _street() -> Node:
	var queue := get_parent()
	return queue.get_parent() if queue is TrafficQueue and queue.get_parent() else queue


## A clown of it out on the street, on any PC (a guest's come from the host's).
func add_clown_out(out: ConvoyClown) -> void:
	if not out.boarded.is_connected(_on_boarded):
		out.boarded.connect(_on_boarded)
	if not out in clowns_out:
		clowns_out.append(out)
	if crowd > 0:
		CrowdedCar.show_inside(self, crowd - clowns_out.size())


## The other clowns in the car: from its plate, so every PC dresses them alike.
func _rider_traits(i: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["clown rider", plate, i])
	return ConvoyTraits.draw(rng)


## Its horn, in its bubble: a clown's own, or a wedding guest's celebration.
func honk() -> void:
	if guest:
		say(tr(WeddingCar.honk_line(honks)))
		honks += 1
		return
	say(tr(ConvoyTraits.horn_text(clown_traits)))


## Where its driver gets out to be cuffed: where he stands if he's out already, else by the door.
func driver_out_at() -> Vector3:
	for out in clowns_out:
		if is_instance_valid(out) and out.is_driver:
			return out.global_position
	return Vector3.INF if not clown else door_point()


## Every clown of it still out hops back in (its driver's been detained).
func recall_clowns() -> void:
	for out in clowns_out.duplicate():
		if is_instance_valid(out):
			out.board()
	clowns_out.clear()
	_on_boarded(null)


## The detained clown is out for good: nobody at the wheel.
func empty_seat() -> void:
	var seat := get_node_or_null("Driver") as Node3D
	if seat:
		seat.queue_free()


func _on_boarded(back: ConvoyClown) -> void:
	clowns_out.erase(back)
	if crowd > 0:
		CrowdedCar.show_inside(self, crowd - clowns_out.size() - _to_pop)
	if clowns_out.is_empty() and _to_pop == 0:
		var seat := get_node_or_null("Driver") as Node3D
		if seat:
			seat.visible = true
		if door:
			door.set_angle(0.0)
			door.is_open = false


func _add_box(size: Vector3, center: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = center
	add_child(shape)


func _build_trunk() -> void:
	lid = TrunkLid.new()
	lid.name = "TrunkLid"
	lid.position = trunk_hinge()
	if clown:
		lid.size = CLOWN_LID
	add_child(lid)
	lid.opened.connect(_on_trunk_opened)
	_trunk = Node3D.new()
	_trunk.name = "Trunk"
	_trunk.position = CLOWN_TRUNK_INSIDE if clown else TRUNK_INSIDE
	if clown:
		_trunk.scale = Vector3.ONE * CLOWN_TRUNK_SCALE
	_trunk.visible = false
	add_child(_trunk)
	var builder := PlaceBuilder.new(_trunk)
	match driver.get("trunk", "bags"):
		"bags":
			builder.mesh_box(Vector3(-0.4, 0.2, 0), Vector3(0.7, 0.4, 0.5), BAG)
			builder.mesh_box(Vector3(0.4, 0.15, 0.05), Vector3(0.6, 0.3, 0.45), BAG.darkened(0.3))
		"contraband":
			for i in 3:
				builder.mesh_box(Vector3(-0.5 + i * 0.5, 0.15, 0), Vector3(0.4, 0.3, 0.4), CONTRABAND)
		"balloons":
			for i in 3:
				var balloon := MeshInstance3D.new()
				var sphere := SphereMesh.new()
				sphere.radius = 0.25
				sphere.height = 0.6
				balloon.mesh = sphere
				var material := StandardMaterial3D.new()
				material.albedo_color = ConvoyClown.BALL_COLORS[i]
				balloon.material_override = material
				balloon.position = Vector3(-0.5 + i * 0.5, 0.3, 0)
				_trunk.add_child(balloon)
		"pies":
			for i in 2:
				builder.mesh_box(Vector3(-0.35 + i * 0.7, 0.1, 0), Vector3(0.5, 0.2, 0.5), PIE)
				builder.mesh_box(Vector3(-0.35 + i * 0.7, 0.23, 0), Vector3(0.45, 0.06, 0.45), CREAM)
		"envelopes":
			# The wedding's gift envelopes (control-boda.md): a pile of white, a pink ribbon.
			for i in 4:
				builder.mesh_box(Vector3(-0.45 + i * 0.3, 0.04 + 0.03 * (i % 2), 0), Vector3(0.28, 0.04, 0.18), CREAM)
			builder.mesh_box(Vector3(0, 0.08, 0), Vector3(1.2, 0.05, 0.04), WeddingCar.RIBBON_PINK)
		"safe", "prop_safe":
			builder.mesh_box(Vector3(0, 0.35, 0), Vector3(0.8, 0.7, 0.6), SAFE)
			builder.mesh_box(Vector3(0, 0.4, -0.31), Vector3(0.18, 0.18, 0.03), SAFE_DIAL)
		"lamp":
			# The lighthouse's lamp (control-neblina.md), still lit.
			var lamp: Node3D = LighthouseLamp.MODEL.instantiate()
			lamp.position = Vector3(0, 0, 0.05)
			_trunk.add_child(lamp)
			var glow := FogCar.halo(LighthouseLamp.GLOW)
			glow.position.y = 0.25
			lamp.add_child(glow)
		"grandpa":
			var grandpa: Node3D = GRANDPA.instantiate()
			grandpa.scale = Vector3.ONE * 0.6
			grandpa.rotation.y = PI
			_trunk.add_child(grandpa)


## Online (NpcSync): what a guest's copy needs before it's added (which car it is, not whether it's the wanted one).
func net_setup() -> Dictionary:
	return {"plate": plate, "driver": driver, "clown": clown, "clown_traits": clown_traits, "fruit": fruit,
		"crate": crate, "hat": hat, "melon_kinds": melon_kinds, "crowd": crowd, "ghost_mode": ghost_mode,
		"ghost": ghost, "shirt": shirt, "puppeteer": puppeteer, "wedding_mode": wedding_mode, "guest": guest,
		"tie": tie, "newlyweds": newlyweds, "alcohol": alcohol, "couple": couple, "race_mode": race_mode,
		"racer": racer, "race": race, "race_slot": race_slot,
		"fog_mode": fog_mode, "fog": fog, "circus_mode": circus_mode, "circus": circus}


## Online: where it is in the queue and whether its trunk is open; the ghost car's, how many pranks and the last one;
## the wedding check's, whether its driver blew and gave up the keys; the street race's, its flat tires and sparks.
func net_state() -> Array:
	var rig := get_node_or_null("Pilot") as GhostPilot
	if rig:
		return [state, lid.is_open if lid else false, rig.pranks, rig.last_prank]
	if wedding_mode:
		return [state, lid.is_open if lid else false, blown, keys_taken]
	if fog_mode:
		return [state, lid.is_open if lid else false, bumped]
	if race_mode:
		var sparks := get_node_or_null("Exhaust/Sparks") as CPUParticles3D
		return [state, lid.is_open if lid else false, flat, sparks != null and sparks.emitting]
	return [state, lid.is_open if lid else false]


func apply_net_state(net: Array) -> void:
	if race_mode and racer and net[0] == "revving" and state != "revving":
		_start_revving()
	state = net[0]
	if net[1]:
		open_trunk()
	var rig := get_node_or_null("Pilot") as GhostPilot
	if rig and net.size() > 3:
		rig.copy_prank(net[2], net[3])
	if wedding_mode and not rig and net.size() > 3:
		blown = blown or net[2]
		if net[3] and not keys_taken:
			# The host's cop took the keys: its relative drives here too.
			keys_taken = true
			_relative_takes_over()
	if fog_mode and net.size() > 2 and net[2] and not bumped:
		# It bumped into the car ahead on the host: its driver says so here too.
		bumped = true
		say(tr(FogCar.bump_line(plate)))
	if race_mode and net.size() > 3:
		if net[2] and not flat:
			# Punctured on the host: flat here too, and its driver says so.
			flat = true
			_flatten()
			say(tr(flat_line()))
		RaceCar.spark(self, RaceCar.SPARKS_FROM * 2.0 if net[3] else 0.0)
	# The host's detained the pilot: he's out of his window here too.
	var leaning := get_node_or_null("WindowDriver")
	if leaning and state == "pulled_over":
		leaning.queue_free()


## The trunk opened on some PC: open on this one too (TrunkLid asks every PC through its cop).
func open_trunk() -> void:
	if lid and not lid.is_open:
		lid.set_angle(TrunkLid.MAX_ANGLE)


func prompt_key(cop: Cop) -> String:
	if can_take_keys():
		return "PROMPT_TAKE_KEYS"
	if can_blow() and cop and cop.get_node("Grabber").held is Breathalyzer:
		return "PROMPT_BLOW"
	if waiting() and can_fine():
		return "PROMPT_CROWD_FINE"
	return "PROMPT_PAPERS" if waiting() else ""


## E on a stopped car: with the breathalyzer in hand its driver blows; a packed one all counted gets its fine; else
## the driver hands the license.
func use(cop: Cop = null) -> void:
	if can_take_keys():
		take_keys()
		return
	if can_blow() and cop and cop.get_node("Grabber").held is Breathalyzer:
		blow(cop.get_node("Grabber").held)
		return
	if waiting() and can_fine():
		fine()
		return
	if ghost and waiting():
		say(tr(GhostCar.nobody_line(knocked)))
		knocked += 1
		(get_node("Pilot") as GhostPilot).scare()
		return
	if not waiting() or driver.is_empty():
		return
	papers_checked = true
	if guest:
		# A guest hands it over toasting the couple (control-boda.md, answer 2).
		say(DriverTraits.license_text(driver) + "\n" + WeddingCar.toast(plate, couple, newlyweds))
		return
	say(DriverTraits.license_text(driver))


## Someone at its wheel to blow: a stopped car with a driver, in the wedding check, not blown yet.
func can_blow() -> bool:
	return wedding_mode and waiting() and not driver.is_empty() and not blown


## With the breathalyzer in hand, E on it does something: blow, or take the keys.
func breath_check_ready() -> bool:
	return can_blow() or can_take_keys()


## Its driver blew over the limit and still has the keys.
func can_take_keys() -> bool:
	return wedding_mode and waiting() and blown and not keys_taken and alcohol_level() > WeddingCar.DRUNK_ABOVE


## Whoever drives it now drank over the limit: its driver, until a cop takes the keys.
func drunk_at_wheel() -> bool:
	return wedding_mode and not keys_taken and alcohol_level() > WeddingCar.DRUNK_ABOVE


## A cop takes the drunk driver's keys: a relative from the back seat takes the wheel, sober, and says so.
func take_keys() -> void:
	if not can_take_keys():
		return
	keys_taken = true
	_relative_takes_over()
	var case := TrafficCase.of(self)
	if case:
		case.keys_taken(self)


## The drunk leaves the window and a relative from the back seat takes the wheel, and says so.
func _relative_takes_over() -> void:
	var drunk := get_node_or_null("WindowDriver")
	if drunk:
		remove_child(drunk)
		drunk.queue_free()
	GhostCar.dress_driver(self, plate + " relative", shirt)
	say(tr(WeddingCar.relative_line(plate)))


## What its driver blows: the plan's, or else from its plate.
func alcohol_level() -> float:
	return alcohol if alcohol >= 0.0 else WeddingCar.alcohol_of(plate, guest)


## Its driver blows into `breathalyzer`: the reading on its screen, and in the bubble with what they say.
func blow(breathalyzer: Breathalyzer) -> void:
	if not can_blow():
		return
	blown = true
	var value := alcohol_level()
	if breathalyzer:
		breathalyzer.show_reading(value)
	say(tr("BLOW_READING") % WeddingCar.reading_text(value) + "\n" + tr(WeddingCar.blow_line(plate, guest)))


func say(text: String) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = SAY_SECONDS


## The bubble's text while it shows, for tests.
func saying() -> String:
	return _bubble.text if _bubble.visible else ""


func _on_trunk_opened() -> void:
	trunk_checked = true
	_trunk.visible = true
	if ghost:
		(get_node("Pilot") as GhostPilot).prank("bolt")
	match driver.get("trunk", "bags"):
		"contraband":
			say(tr("TRUNK_CONTRABAND"))
		"grandpa":
			say(tr("TRUNK_GRANDPA"))
		"pies":
			say(tr("TRUNK_PIES"))
		"prop_safe":
			say(tr("TRUNK_PROP_SAFE"))
		"safe":
			say(tr("TRUNK_SAFE"))
		"envelopes":
			say(tr("TRUNK_ENVELOPES"))
		"lamp":
			say(tr("TRUNK_LAMP"))


func waiting() -> bool:
	return state == "waiting"


## In the queue, stopped or rolling up to it: not let through, not sneaking, not gone.
func in_queue() -> bool:
	return state == "coming" or state == "waiting"


func let_through() -> void:
	if in_queue() and can_go():
		state = "going"


## The handcuffs (Handcuffs.cuffable) on a stopped car cuff its driver: the case detains them (TrafficCase).
func cuffed(_seconds: float) -> void:
	if ghost:
		# Nobody at its wheel to cuff (control-auto-fantasma.md).
		say(tr("GHOST_NO_ONE_TO_CUFF"))
		return
	var case := TrafficCase.of(self)
	if case and (waiting() or stopped_racer()):
		case.detain(self)


## The cuffs on the car itself come off right away: they're on the driver.
func is_cuffed() -> bool:
	return false


## Detained: it moves over to the curb, out of the lane, and stays there.
func pull_over() -> void:
	if in_queue():
		state = "pulled_over"


func sneak() -> void:
	if in_queue() and can_go():
		state = "sneaking"


## Its horn answers the foghorn after `delay` seconds (the further, the later): its bubble shows over it.
func honk_back(delay := 0.0) -> void:
	if not horn_bubble:
		return
	if delay <= 0.0:
		horn_bubble.say(tr(FogCar.horn_text(fog.get("horn", 0))))
		return
	get_tree().create_timer(delay).timeout.connect(func() -> void:
		if is_instance_valid(self) and state != "gone":
			honk_back())


## Too fast in the fog to stop where it should: behind a car it bumps into it and stops there; at the barrier it
## runs the checkpoint, barrier, cones and all (TrafficQueue.overran).
func _overrun() -> void:
	warned = true
	if is_instance_valid(ahead) and ahead.in_queue():
		speed = 0.0
		bumped = true
		say(tr(FogCar.bump_line(plate)))
		return
	state = "overrun"
	var queue := get_parent() as TrafficQueue
	if queue:
		queue.overran(self)


## Where it wants to stop, in the checkpoint's z; INF for no stop.
func _stop_z() -> float:
	if state == "pulled_over" or not can_go():
		return at.z
	if not in_queue():
		return -INF
	var stop := TrafficCheckpoint.ZONE.y / 2 + stop_before() if checkpoint.barrier_ok() else -INF
	if is_instance_valid(ahead) and ahead.in_queue():
		stop = maxf(stop, ahead.at.z + (length() + ahead.length()) / 2 + GAP)
	return stop


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	if state == "gone" or not checkpoint:
		return
	if racer and state in ["gathering", "revving", "racing", "punctured"]:
		_race(delta)
		return
	if _to_pop > 0:
		_pop_left -= delta
		if _pop_left <= 0.0:
			_pop_left = POP_EVERY
			_pop()
	if (clown or guest) and in_queue() and not _bubble.visible:
		_honk_left -= delta
		if _honk_left <= 0.0:
			_honk_left = WeddingCar.honk_every(plate) if guest else HONK_EVERY
			honk()
	var stop := _stop_z()
	var room := at.z - stop
	# Slows down to stop right at `stop`: v² = 2·a·d.
	var top := SPEED if room == INF else minf(SPEED, sqrt(maxf(2.0 * ACCEL * room, 0.0)))
	var blind := fog_mode and not warned and state == "coming"
	if blind and FogCar.warned(self):
		warned = true
		blind = false
	if blind:
		top = FogCar.BLIND_SPEED if room > FogCar.SIGHT else 0.0
	if flat:
		top = minf(top, FLAT_SPEED)
	speed = move_toward(speed, top, ACCEL * delta)
	if blind and room != INF and at.z - speed * delta < stop and speed > FogCar.STOP_SPEED:
		_overrun()
	if room <= 0.05:
		speed = 0.0
	# Never past where it stops, even with a long tick.
	at.z = maxf(at.z - speed * delta, stop)
	if state == "sneaking":
		at.x = move_toward(at.x, SNEAK_SIDE, 2.5 * delta)
	if state == "pulled_over":
		at.x = move_toward(at.x, CURB_SIDE, 1.5 * delta)
	if state == "coming" and speed == 0.0:
		state = "waiting"
		# At the barrier, the driver says their piece.
		var first := not (is_instance_valid(ahead) and ahead.in_queue())
		if not said_line and not ghost and not driver.is_empty() and first:
			said_line = true
			say(tr(driver.line) if not clown else tr(ConvoyTraits.horn_text(clown_traits)) + " " + tr(driver.line))
			_honk_left = WeddingCar.honk_every(plate) if guest else HONK_EVERY
	elif state == "waiting" and speed > 0.0:
		state = "coming"
	if at.z < GONE_AT:
		state = "gone"
		queue_free()
		return
	_place()
	if guest:
		WeddingCar.rattle(self, speed, _rolled)
	if racer:
		RaceCar.spark(self, speed)
	_rolled += delta
	if state == "going" and drunk_at_wheel():
		# A drunk let through zigzags off, and takes the cones with it (control-boda.md, step 3).
		at.x = sin(_rolled * WeddingCar.ZIGZAG_RATE) * WeddingCar.ZIGZAG
		_sway = -cos(_rolled * WeddingCar.ZIGZAG_RATE) * WeddingCar.SWAY
		_knock_cones()
	if state == "sneaking":
		_knock_cones()
	if state == "overrun":
		_knock_barrier()
		_knock_cones()


## A racer's heat (control-carrera.md, step 2): it waits, revs shaking (the warning), then races down its lane,
## swerving to clip the barrier's end and the cones on its way.
func _race(delta: float) -> void:
	race_left -= delta
	_rolled += delta
	match state:
		"gathering":
			if race_left <= 0.0:
				state = "revving"
				race_left = RaceCar.REV_SECONDS
				_start_revving()
		"revving":
			lurch = sin(_rolled * RaceCar.SHAKE_RATE) * RaceCar.SHAKE
			if race_left <= 0.0:
				state = "racing"
				lurch = 0.0
		"racing":
			speed = move_toward(speed, RaceCar.SPEED, RaceCar.ACCEL * delta)
			var step := speed * delta
			at.z -= step
			var x := RaceCar.lane_x(at.z)
			if step > 0.0:
				_sway = -atan2(x - at.x, step)
			at.x = x
			_knock_cones()
			_knock_barrier()
		"punctured":
			# Rolling on the rims, sparks and all, to a stop: then the driver complains.
			var was_rolling := speed > 0.0
			speed = move_toward(speed, 0.0, FLAT_BRAKE * delta)
			at.z -= speed * delta
			# Not into the one ahead in its heat, stopped on its rims too.
			if is_instance_valid(ahead) and ahead.state == "punctured" and at.z < ahead.at.z + LENGTH + GAP:
				at.z = ahead.at.z + LENGTH + GAP
				speed = 0.0
			at.x = RaceCar.lane_x(at.z)
			if was_rolling and speed == 0.0:
				say(tr(flat_line()))
	RaceCar.spark(self, speed if state in ["racing", "punctured"] else RaceCar.SPARKS_FROM * 2.0 if state == "revving" \
		else 0.0)
	if at.z < GONE_AT:
		state = "gone"
		queue_free()
		return
	_place()


## It roars (and the first of its heat warns the cops), on every PC.
func _start_revving() -> void:
	say(tr(RaceCar.rev_line(plate)))
	if race_slot == 0:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			cop.show_hint("HINT_RACE_REVVING")


## A racer stopped on its rims (control-carrera.md): its driver can be cuffed.
func stopped_racer() -> bool:
	return racer and state == "punctured" and speed == 0.0


## Rolling over a spike strip punctures it, once: moving, not out of the way at the curb.
func can_puncture() -> bool:
	return not flat and speed > 0.5 and state not in ["pulled_over", "gone"]


## Its four tires go flat (SpikeStrip): a racing racer brakes to a stop, a city car limps on and complains.
func puncture() -> void:
	if flat:
		return
	flat = true
	_flatten()
	if racer and state == "racing":
		state = "punctured"
	elif not racer:
		say(tr(flat_line()))
	var queue := get_parent() as TrafficQueue
	if queue:
		queue.punctured.emit(self)


## Its wheels squashed flat.
func _flatten() -> void:
	for i in SuspectCar.SEDAN_WHEELS.size():
		var wheel := get_node_or_null("Wheel%d" % i) as Node3D
		if wheel:
			wheel.scale.y = FLAT_SQUASH
			wheel.position.y = SuspectCar.SEDAN_WHEELS[i].y * FLAT_SQUASH


## What its driver says about the flat tires: a racer one of FLAT_LINES, a city driver one of CITY_FLAT_LINES.
func flat_line() -> String:
	var roll := absi(hash(["flat", plate]))
	return "RACE_FLAT_%d" % (roll % FLAT_LINES) if racer else "CITY_FLAT_%d" % (roll % CITY_FLAT_LINES)


func _knock_barrier() -> void:
	for barrier: RoadBarrier in get_tree().get_nodes_in_group("road_barriers"):
		# In the checkpoint's space, before its body touches it: across, its half and the barrier's; along, ahead.
		var off := checkpoint.to_local(barrier.global_position) - at
		if absf(off.x) < RaceCar.BARRIER_REACH.x and absf(off.z) < RaceCar.BARRIER_REACH.y:
			var away := (barrier.global_position - global_position) * Vector3(1, 0, 1)
			barrier.knock((away.normalized() + global_basis.z + Vector3.UP * 0.5) * RaceCar.BARRIER_PUSH)


func _place() -> void:
	if checkpoint:
		global_transform = checkpoint.global_transform * Transform3D(Basis(Vector3.UP, PI + _sway),
			at + Vector3(0, 0.05, lurch))


func _knock_cones() -> void:
	for cone: TrafficCone in get_tree().get_nodes_in_group("traffic_cones"):
		var off := cone.global_position - global_position
		off.y = 0
		if off.length() < KNOCK_REACH and cone.standing():
			cone.linear_velocity = (off.normalized() + Vector3.UP * 0.6) * KNOCK_SPEED
			cone.angular_velocity = Vector3(randf_range(-6, 6), 0, randf_range(-6, 6))
