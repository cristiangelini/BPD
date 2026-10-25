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
			CrowdedCar.dress(self)
		for wheel_at in SuspectCar.SEDAN_WHEELS:
			var wheel: Node3D = TrafficCar.WHEEL.instantiate()
			wheel.position = wheel_at
			add_child(wheel)
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
	plate_label.position = Vector3(0, 0.5 if clown else 0.62, -length() / 2 - (0.06 if fruit else 0.03))
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


## The other clowns in the car: from its plate, so every PC dresses them alike.
func _rider_traits(i: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["clown rider", plate, i])
	return ConvoyTraits.draw(rng)


## Its horn, in its bubble.
func honk() -> void:
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
		"safe", "prop_safe":
			builder.mesh_box(Vector3(0, 0.35, 0), Vector3(0.8, 0.7, 0.6), SAFE)
			builder.mesh_box(Vector3(0, 0.4, -0.31), Vector3(0.18, 0.18, 0.03), SAFE_DIAL)
		"grandpa":
			var grandpa: Node3D = GRANDPA.instantiate()
			grandpa.scale = Vector3.ONE * 0.6
			grandpa.rotation.y = PI
			_trunk.add_child(grandpa)


## Online (NpcSync): what a guest's copy needs before it's added (which car it is, not whether it's the wanted one).
func net_setup() -> Dictionary:
	return {"plate": plate, "driver": driver, "clown": clown, "clown_traits": clown_traits, "fruit": fruit,
		"crate": crate, "hat": hat, "melon_kinds": melon_kinds, "crowd": crowd}


## Online: where it is in the queue and whether its trunk is open.
func net_state() -> Array:
	return [state, lid.is_open if lid else false]


func apply_net_state(net: Array) -> void:
	state = net[0]
	if net[1]:
		open_trunk()


## The trunk opened on some PC: open on this one too (TrunkLid asks every PC through its cop).
func open_trunk() -> void:
	if lid and not lid.is_open:
		lid.set_angle(TrunkLid.MAX_ANGLE)


func prompt_key(_cop: Cop) -> String:
	if waiting() and can_fine():
		return "PROMPT_CROWD_FINE"
	return "PROMPT_PAPERS" if waiting() else ""


## E on a stopped car: a packed one all counted gets its fine; else the driver hands the license.
func use(_cop: Cop) -> void:
	if waiting() and can_fine():
		fine()
		return
	if not waiting() or driver.is_empty():
		return
	papers_checked = true
	say(DriverTraits.license_text(driver))


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
	var case := TrafficCase.of(self)
	if case and waiting():
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
	if _to_pop > 0:
		_pop_left -= delta
		if _pop_left <= 0.0:
			_pop_left = POP_EVERY
			_pop()
	if clown and in_queue() and not _bubble.visible:
		_honk_left -= delta
		if _honk_left <= 0.0:
			_honk_left = HONK_EVERY
			honk()
	var stop := _stop_z()
	var room := at.z - stop
	# Slows down to stop right at `stop`: v² = 2·a·d.
	var top := SPEED if room == INF else minf(SPEED, sqrt(maxf(2.0 * ACCEL * room, 0.0)))
	speed = move_toward(speed, top, ACCEL * delta)
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
		if not said_line and not driver.is_empty() and not (is_instance_valid(ahead) and ahead.in_queue()):
			said_line = true
			say(tr(driver.line) if not clown else tr(ConvoyTraits.horn_text(clown_traits)) + " " + tr(driver.line))
			_honk_left = HONK_EVERY
	elif state == "waiting" and speed > 0.0:
		state = "coming"
	if at.z < GONE_AT:
		state = "gone"
		queue_free()
		return
	_place()
	if state == "sneaking":
		_knock_cones()


func _place() -> void:
	if checkpoint:
		global_transform = checkpoint.global_transform * Transform3D(Basis(Vector3.UP, PI), at + Vector3.UP * 0.05)


func _knock_cones() -> void:
	for cone: TrafficCone in get_tree().get_nodes_in_group("traffic_cones"):
		var off := cone.global_position - global_position
		off.y = 0
		if off.length() < KNOCK_REACH and cone.standing():
			cone.linear_velocity = (off.normalized() + Vector3.UP * 0.6) * KNOCK_SPEED
			cone.angular_velocity = Vector3(randf_range(-6, 6), 0, randf_range(-6, 6))
