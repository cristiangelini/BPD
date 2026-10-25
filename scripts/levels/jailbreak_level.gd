class_name JailbreakLevel
extends Node3D

## The jailbreak's level (fuga.md, step 1): the first time a campaign misses its quota, the cops wake up at night
## locked in their own station's cells, two in each, with the patrol car parked outside. In front of the cells the
## night guard sits at his desk with his box of donuts, one of them with the key (step 2, NightGuard), and on each
## cell's floor lies something long to fish the box with: the broom and the fishing rod (step 3, HookStick). If the
## guard's suspicion fills up (step 4), he puts the cops who are out back in the cells, locks them, takes back his box
## and the stick they used, and keeps the key on his belt; the bar at the top shows his suspicion and the catches.
## They escape when every cop sits in the patrol car and it drives ESCAPE_DISTANCE away from the station: "¡Fugados!"
## and the campaign's next shift. The guard's CATCHES-th catch calls the comisario, who comes in his pajamas, and the
## campaign is lost (step 6).
## There are two ways out, drawn by the seed: the key in the donut (the night guard, above) and the cleaning crew
## (fuga-limpieza.md): at dawn the guard went home and the comisario came in early, walking his round
## (EarlyComisario), and he catches them the same way; the third time he suspends them himself. The cells open when
## Clotilde, the cleaner, mops them (Cleaner), with the key ring on her cart, and the break room is the cleaning closet:
## the crew's caps, face masks and vests (DisguisePiece, "cleaner"), their mops and feather duster (CleaningTool) and
## the floor polisher (FloorPolisher). The comisario mustn't see them get in the patrol car.
## The floor has stains to mop (FloorStains); a cop running on the wet floor slips (WET_SLIP seconds down).
## The third way out is the guard dog (fuga-perro.md): the night guard fell asleep at his desk (SleepyGuard) and the
## key hangs from the collar of Mordisco, the station's bulldog, who walks his round (GuardDog).
## --place=jailbreak opens it from Play, and --jailbreak=<variant> forces one of VARIANTS.

const DESK_MODEL := preload("res://assets/models/station_desk.glb")
const BOX_SCENE := preload("res://scenes/props/guard_donut_box.tscn")
## In the station's own space (StationRooms): the desk 2.9 m from the bars, between the two cell doors, with the
## guard behind it facing the cells and the box on it (propuesta).
const DESK_AT := Vector3(10.5, 0, 7.4)
const GUARD_AT := Vector3(10.5, 0, 8.4)
const BOX_AT := Vector3(10.5, 0.87, 7.25)
## Something to fish the box with, lying on the floor of each cell (step 3): [model, length, grip, turn].
const STICKS := [
	["res://assets/models/broom.glb", 2.8, Vector3(9.8, 0.06, 3.9), PI / 2],
	["res://assets/models/fishing_rod.glb", 3.0, Vector3(11.2, 0.06, 3.9), -PI / 2],
]

## The cleaning crew's: Clotilde's cart in the cells room, front (and its key hook) toward the cells, and where the
## key ring lies on its top tray, in the cart's own space.
const CART_MODEL := preload("res://assets/models/cleaning_cart.glb")
const CART_AT := Vector3(13.0, 0, 7.4)
const CART_SIZE := Vector3(0.9, 0.97, 0.5)
const CART_HOOK := Vector3(0.3, 0.97, 0.25)
const CART_KEY := Vector3(0.3, 1.0, 0.15)

## The cleaning closet, in the station's own space (the break room, StationRooms): the disguise pieces in two rows on
## the floor from CLOSET_AT, one of each per cop less up to CLOSET_MISSING the seed takes away, and the tools lying
## along the wall: [model, kind, length, grip].
const CLOSET := ["cleaner_cap", "face_mask", "cleaner_vest"]
const CLOSET_AT := Vector3(6.4, 0, -1.4)
const CLOSET_GAP := Vector2(0.45, 0.4)
const CLOSET_MISSING := 2
const CLOSET_TOOLS := [
	["res://assets/models/mop.glb", "mop", 1.5, Vector3(12.0, 0.06, -0.8)],
	["res://assets/models/mop.glb", "mop", 1.5, Vector3(12.0, 0.06, -1.3)],
	["res://assets/models/feather_duster.glb", "duster", 0.8, Vector3(12.0, 0.06, -1.8)],
]
const POLISHER_AT := Vector3(13.6, 0.02, -1.3)

## Slipping on the wet floor: how long down, how hard the push, and how long until it can slip again.
const WET_SLIP := 2.0
const WET_PUSH := 3.0
const WET_AGAIN := 3.0

## How many times the guard can catch them (step 6 ends the campaign at the last one).
const CATCHES := 3
## How far from its parking spot the patrol car must get with everyone on board.
const ESCAPE_DISTANCE := 25.0
## Seconds between the last catch (the comisario coming in) and the end screen.
const LOST_DELAY := 3.0
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## The comisario at the cells room's door, facing in, when he's called.
const COMISARIO_AT := Vector3(6.8, 0, 6.4)

## The ways out, drawn by the seed (fuga-limpieza.md and fuga-perro.md, question 1: in thirds, propuesta).
const VARIANTS := ["donut", "cleaning", "dog"]

## Same seed, same jailbreak. 0 draws one.
@export var case_seed := 0
## Which way out (VARIANTS); empty draws it from the seed Play drew, and without one it's the donut.
@export var variant := ""
var city: City
var guard: NightGuard
var box: DonutBox
var sticks: Array[HookStick] = []
var box_home: Transform3D
var suspicion_bar: ProgressBar
var caught_label: Label
var car_home: Transform3D
## The cleaning crew's jailbreak: Clotilde and the key ring on her cart.
var cleaner: Cleaner
## Mordisco, in the guard dog's jailbreak.
var dog: GuardDog
var cart_key: CellKey
var tools: Array[CleaningTool] = []
var polisher: FloorPolisher
## How many disguise pieces the comisario took back to the closet.
var _returned := 0
var stains: FloorStains
## Cop -> seconds until it can slip again.
var _slipped := {}
var _cart: Transform3D
var end_screen: CanvasLayer
## A guest: how many catches it already followed (-1 until it first looks).
var _seen_catches := -1


func _ready() -> void:
	var drawn := 0
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
		drawn = case_seed
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	if variant == "":
		variant = pick_variant(drawn, OS.get_cmdline_user_args())
	city = $City
	# At night the comisario and the armero went home.
	for npc: Node in [city.comisario, city.armero]:
		if npc:
			npc.queue_free()
	for door in city.cell_doors:
		door.lock()
	if is_cleaning():
		_early_comisario()
	elif is_dog():
		_dog_night()
	else:
		_guard_desk()
	_hud()
	$Cop.global_transform = cop_spawn(0)
	car_home = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	$PatrolCar.global_transform = car_home
	if Campaign.current:
		guard.times_caught = Campaign.current.jail_catches
	var hint: String = {"cleaning": "HINT_JAILED_CLEANING", "dog": "HINT_JAILED_DOG"}.get(variant, "HINT_JAILED")
	($Cop as Cop).show_hint.call_deferred(hint)


## The way out for this seed: from --jailbreak=<variant> among the user args, or drawn. Without a seed from Play (0)
## it's the donut, the first one.
static func pick_variant(drawn_seed: int, args: PackedStringArray) -> String:
	for arg in args:
		if arg.begins_with("--jailbreak=") and VARIANTS.has(arg.trim_prefix("--jailbreak=")):
			return arg.trim_prefix("--jailbreak=")
	if drawn_seed == 0:
		return VARIANTS[0]
	return VARIANTS[hash(["jailbreak variant", drawn_seed]) % VARIANTS.size()]


func is_cleaning() -> bool:
	return variant == "cleaning"


func is_dog() -> bool:
	return variant == "dog"


## The guard dog's jailbreak: the guard asleep at his desk with no donuts, and Mordisco walking his round with the key.
func _dog_night() -> void:
	var lot := city.transform * CityLayout.lot("station")
	var desk := _desk()
	var sleepy := SleepyGuard.new()
	sleepy.name = "NightGuard"
	add_child(sleepy)
	sleepy.global_transform = lot * Transform3D(Basis(Vector3.UP, PI), GUARD_AT)
	sleepy.doze(case_seed)
	sleepy.outside_cells = outside_cells
	sleepy.see_through = [desk.get_rid()]
	sleepy.caught.connect(_on_caught)
	guard = sleepy
	dog = GuardDog.new()
	dog.name = "GuardDog"
	add_child(dog)
	dog.setup_round(case_seed, lot)


## The cleaning crew's jailbreak: dawn, no guard at the desk, and the comisario walking his round instead.
func _early_comisario() -> void:
	var comisario := EarlyComisario.new()
	comisario.name = "EarlyComisario"
	add_child(comisario)
	comisario.setup_round(case_seed, city.transform * CityLayout.lot("station"))
	comisario.outside_cells = outside_cells
	comisario.caught.connect(_on_caught)
	comisario.car = $PatrolCar
	guard = comisario
	_cleaner()
	_closet()
	stains = FloorStains.new()
	stains.name = "FloorStains"
	add_child(stains)
	stains.setup(case_seed, city.transform * CityLayout.lot("station"))
	stains.cleaned.connect(func(_index: int, at: Vector3) -> void: (guard as EarlyComisario).saw_cleaning(at))
	_dawn()


## The break room as the cleaning closet: the disguises on the floor and the tools along the wall.
func _closet() -> void:
	var lot := city.transform * CityLayout.lot("station")
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["cleaning closet", case_seed])
	var pieces: Array[String] = []
	for i in 4:
		pieces.append_array(CLOSET)
	for i in rng.randi_range(0, CLOSET_MISSING):
		pieces.remove_at(rng.randi_range(0, pieces.size() - 1))
	for i in pieces.size():
		var piece: DisguisePiece = DisguisePiece.scene_of(pieces[i]).instantiate()
		piece.name = "Closet%d" % i
		add_child(piece)
		piece.global_position = lot * (CLOSET_AT + Vector3((i % 6) * CLOSET_GAP.x, 0.12, floorf(i / 6.0) * CLOSET_GAP.y))
	for item: Array in CLOSET_TOOLS:
		var tool := CleaningTool.new()
		tool.name = "Tool%d" % tools.size()
		tool.model = load(item[0])
		tool.kind = item[1]
		tool.length = item[2]
		add_child(tool)
		tool.global_transform = lot * Transform3D(Basis(Vector3.UP, PI / 2), item[3])
		tools.append(tool)
	polisher = FloorPolisher.new()
	polisher.name = "FloorPolisher"
	add_child(polisher)
	polisher.global_transform = lot * Transform3D(Basis(Vector3.UP, -PI / 2), POLISHER_AT)


## Clotilde beside her cart, with the cells' key ring on its tray. The comisario doesn't mind the keys on the cart,
## so they aren't one of the guard's clues.
func _cleaner() -> void:
	var lot := city.transform * CityLayout.lot("station")
	var cart := StaticBody3D.new()
	cart.name = "CleaningCart"
	add_child(cart)
	_cart = lot * Transform3D(Basis(Vector3.UP, PI), CART_AT)
	cart.global_transform = _cart
	cart.add_child(CART_MODEL.instantiate())
	var shape := CollisionShape3D.new()
	var solid := BoxShape3D.new()
	solid.size = CART_SIZE
	shape.shape = solid
	shape.position.y = CART_SIZE.y / 2
	cart.add_child(shape)
	cart_key = NightGuard.KEY_SCENE.instantiate()
	cart_key.name = "CartKey"
	add_child(cart_key)
	cart_key.remove_from_group("guard_clues")
	cart_key.global_position = _cart * CART_KEY
	cleaner = Cleaner.new()
	cleaner.name = "Cleaner"
	add_child(cleaner)
	cleaner.setup(case_seed, lot, city.cell_doors, cart_key, _cart * CART_HOOK)


## 5:30 in the morning: the sky starts to light up orange and the moon's light turns warm.
func _dawn() -> void:
	var light: DirectionalLight3D = $Moon
	light.light_color = Color(1.0, 0.72, 0.5)
	light.light_energy = 0.4
	var world: WorldEnvironment = $Environment
	var env: Environment = world.environment.duplicate(true)
	var sky := env.sky.sky_material as ProceduralSkyMaterial
	sky.sky_top_color = Color(0.22, 0.28, 0.48)
	sky.sky_horizon_color = Color(0.95, 0.6, 0.42)
	sky.ground_horizon_color = Color(0.95, 0.6, 0.42)
	env.ambient_light_energy = 0.3
	world.environment = env


## Where the cop in `slot` wakes up: two in each cell (Net puts every player's cop here online).
func cop_spawn(slot: int) -> Transform3D:
	return ($City as Node3D).transform * CityLayout.jail_spawn(slot).translated(Vector3.UP * 0.1)


func _guard_desk() -> void:
	var lot := city.transform * CityLayout.lot("station")
	var desk := _desk()
	box = BOX_SCENE.instantiate()
	box.name = "GuardDonutBox"
	add_child(box)
	box_home = lot * Transform3D(Basis(Vector3.UP, PI), BOX_AT)
	box.global_transform = box_home
	guard = NightGuard.new()
	guard.name = "NightGuard"
	add_child(guard)
	guard.global_transform = lot * Transform3D(Basis(Vector3.UP, PI), GUARD_AT)
	guard.setup(case_seed, box)
	guard.outside_cells = outside_cells
	guard.see_through = [desk.get_rid()]
	guard.caught.connect(_on_caught)
	guard.found_key.connect(func() -> void: get_tree().call_group("cops", "show_hint", "HINT_KEY_ON_BELT"))
	for item: Array in STICKS:
		var stick := HookStick.new()
		stick.name = "Broom" if sticks.is_empty() else "FishingRod"
		stick.model = load(item[0])
		stick.length = item[1]
		add_child(stick)
		stick.global_transform = lot * Transform3D(Basis(Vector3.UP, item[3]), item[2])
		sticks.append(stick)


## The guard's desk in front of the cells.
func _desk() -> StaticBody3D:
	var desk := StaticBody3D.new()
	desk.name = "GuardDesk"
	add_child(desk)
	desk.global_transform = city.transform * CityLayout.lot("station") * Transform3D(Basis(Vector3.UP, PI), DESK_AT)
	desk.add_child(DESK_MODEL.instantiate())
	var shape := CollisionShape3D.new()
	var solid := BoxShape3D.new()
	solid.size = StationRooms.SOLID["station_desk"]
	shape.shape = solid
	shape.position.y = solid.size.y / 2
	desk.add_child(shape)
	return desk


## Whether a world position is out of both cells (through an open door or never in).
func outside_cells(at: Vector3) -> bool:
	var local := (city.transform * CityLayout.lot("station")).affine_inverse() * at
	return not (local.x > StationRooms.FRONT_X and local.x < StationRooms.HALF_X
		and local.z > StationRooms.SPLIT_Z and local.z < StationRooms.CELL_FRONT_Z)


## The guard caught them: back in the cells, both doors locked, his box on the desk, the stick they used taken away,
## the key on his belt and his donuts out of their hands.
func _on_caught(times: int) -> void:
	if Campaign.current:
		Campaign.current.jail_catches = times
		Campaign.current.save()
	if times >= CATCHES:
		if is_cleaning():
			guard.say("EARLY_SUSPENDED", LOST_DELAY + 2.0)
		else:
			_call_comisario()
		get_tree().create_timer(LOST_DELAY).timeout.connect(finish.bind("lost"))
	var slot := 0
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if outside_cells(cop.global_position):
			var car: PatrolCar = $PatrolCar
			if car.seat_of(cop) >= 0:
				car.exit(cop)
				if cop.sync and cop.sync.net.actions:
					cop.sync.net.actions.tell_guests(cop, "exit", car)
			if is_cleaning():
				_undress(cop)
			cop.warp(cop_spawn(slot))
			slot += 1
		cop.show_hint("HINT_COMISARIO_CAUGHT" if is_cleaning() else "HINT_GUARD_CAUGHT")
	for clue: Node in get_tree().get_nodes_in_group("guard_clues"):
		if clue is CellKey or (clue is LooseDonut and clue.has_key):
			guard.key_on_belt = true
		_drop(clue as Grabbable)
		clue.queue_free()
	for door in city.cell_doors:
		door.lock()
	for stick in sticks.duplicate():
		if stick.is_held() or stick.hooked or outside_cells(stick.global_position):
			stick.unhook()
			_drop(stick)
			sticks.erase(stick)
			stick.queue_free()
	if cleaner:
		cleaner.reset()
		if is_instance_valid(cart_key):
			_drop(cart_key)
			cart_key.linear_velocity = Vector3.ZERO
			cart_key.global_position = _cart * CART_KEY
	if polisher:
		polisher.is_on = false
	if box:
		_drop(box)
		box.linear_velocity = Vector3.ZERO
		box.global_transform = box_home


## The comisario takes the caught cop's cleaning disguise back to the closet: it comes off on every PC and the host
## puts the pieces back on the closet's floor, in a row of their own.
func _undress(cop: Cop) -> void:
	var lot := city.transform * CityLayout.lot("station")
	var parent := cop.get_parent()
	for kind: String in cop.disguise.keys():
		var before := parent.get_child_count()
		cop.lose_disguise(kind)
		if cop.sync and cop.sync.net.actions:
			cop.sync.net.actions.tell_guests(cop, "lose_disguise", cop, [kind])
		for i in range(before, parent.get_child_count()):
			var piece := parent.get_child(i) as DisguisePiece
			if piece:
				piece.linear_velocity = Vector3.ZERO
				piece.global_position = lot * (CLOSET_AT + Vector3((_returned % 6) * CLOSET_GAP.x, 0.12,
					(2 + floorf(_returned / 6.0)) * CLOSET_GAP.y))
				_returned += 1


## Out of every cop's hands.
func _drop(item: Grabbable) -> void:
	for cop: Cop in item.handling_cops(0.0):
		cop.get_node("Grabber").release()


func _hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "SuspicionHud"
	var box_ui := VBoxContainer.new()
	box_ui.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box_ui.position.y = 16
	var title := Label.new()
	title.text = "HUD_SUSPICION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_ui.add_child(title)
	suspicion_bar = ProgressBar.new()
	suspicion_bar.custom_minimum_size = Vector2(320, 18)
	suspicion_bar.show_percentage = false
	suspicion_bar.modulate = Color(1, 0.45, 0.3)
	box_ui.add_child(suspicion_bar)
	caught_label = Label.new()
	caught_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_ui.add_child(caught_label)
	hud.add_child(box_ui)
	add_child(hud)


func _physics_process(delta: float) -> void:
	if stains:
		_slip_on_wet(delta)


## This PC's own cop running on the wet floor slips: down for a while, dropping what it holds.
func _slip_on_wet(delta: float) -> void:
	for cop: Variant in _slipped.keys():
		_slipped[cop] -= delta
		if _slipped[cop] <= 0.0 or not is_instance_valid(cop):
			_slipped.erase(cop)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.sync and not cop.sync.is_multiplayer_authority():
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if _slipped.has(cop) or not cop.is_running or flat.length() <= EarlyComisario.RUN_SPEED \
				or not stains.wet_at(cop.global_position):
			continue
		_slipped[cop] = WET_AGAIN
		cop.get_node("Grabber").release()
		cop.knock_back(flat.normalized() * WET_PUSH, WET_SLIP)
		cop.show_hint("HINT_WET_SLIP")


func _process(_delta: float) -> void:
	if not multiplayer.is_server():
		_follow_catches()
	suspicion_bar.value = guard.suspicion
	caught_label.text = tr("HUD_COMISARIO_CAUGHT" if is_cleaning() else "HUD_GUARD_CAUGHT") % [guard.times_caught, CATCHES]
	if guard.outcome != "":
		# A guest learns how it ended from the guard (the host's state).
		if not end_screen:
			_show_end(guard.outcome)
	elif multiplayer.is_server() and escaped():
		finish("escaped")


## A guest: the guard (the host's) caught them once more, so its cell doors lock again too. The rest comes from the
## host: the cops' places, the props it took away and the hints.
func _follow_catches() -> void:
	if _seen_catches < 0:
		_seen_catches = guard.times_caught
	if guard.times_caught <= _seen_catches:
		return
	_seen_catches = guard.times_caught
	for door in city.cell_doors:
		door.lock()
	sticks.assign(sticks.filter(func(stick: Object) -> bool: return is_instance_valid(stick)))


## Every cop in the patrol car, and the car far enough from the station.
func escaped() -> bool:
	var car: PatrolCar = $PatrolCar
	var cops := get_tree().get_nodes_in_group("cops")
	if cops.is_empty() or cops.any(func(cop: Node) -> bool: return car.seat_of(cop) < 0):
		return false
	return car.global_position.distance_to(car_home.origin) >= ESCAPE_DISTANCE


## The host closes the jailbreak: "escaped" goes on to the next shift, "lost" ends the campaign.
func finish(result: String) -> void:
	if guard.outcome != "":
		return
	guard.outcome = result
	if Campaign.current and Campaign.current.jailed:
		Campaign.current.finish_jailbreak(result == "escaped")
		Campaign.current.save()
	_show_end(result)


## The comisario comes in his pajamas, woken up by the guard's call.
func _call_comisario() -> void:
	guard.say("GUARD_CALLS_COMISARIO", LOST_DELAY + 2.0)
	var comisario := Comisario.new()
	comisario.name = "PajamaComisario"
	comisario.in_pajamas = true
	add_child(comisario)
	comisario.global_transform = city.transform * CityLayout.lot("station") * Transform3D(Basis(Vector3.UP, PI / 2),
		COMISARIO_AT)
	var shout := Label3D.new()
	shout.text = "COMISARIO_PAJAMAS"
	shout.position.y = 2.1
	shout.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	shout.no_depth_test = true
	shout.pixel_size = 0.004
	shout.outline_size = 8
	shout.font_size = 36
	shout.width = 900.0
	shout.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	comisario.add_child(shout)


## The short screen at the end: "¡Fugados!" and the next shift, or "Suspendidos" and back to the menu.
func _show_end(result: String) -> void:
	# The early comisario is already there: nobody calls him in his pajamas.
	if result == "lost" and not is_cleaning() and not has_node("PajamaComisario"):
		_call_comisario()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
	end_screen = CanvasLayer.new()
	end_screen.name = "JailbreakEnd"
	end_screen.layer = 10
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	var box_ui := VBoxContainer.new()
	box_ui.add_theme_constant_override("separation", 16)
	var title := Label.new()
	title.text = "JAILBREAK_ESCAPED" if result == "escaped" else "JAILBREAK_LOST"
	title.add_theme_font_size_override("font_size", 64)
	title.modulate = Color(0.45, 1, 0.5) if result == "escaped" else Color(1, 0.4, 0.35)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_ui.add_child(title)
	var line := Label.new()
	line.add_theme_font_size_override("font_size", 26)
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var campaign := Campaign.current
	var next := result == "escaped" and not (campaign and campaign.is_over())
	if result == "lost":
		line.text = "JAILBREAK_LOST_LINE_CLEANING" if is_cleaning() else "JAILBREAK_LOST_LINE"
	elif campaign and campaign.is_promoted():
		line.text = "SHIFT_PROMOTED"
	else:
		line.text = tr("JAILBREAK_ESCAPED_LINE") % (campaign.shift if campaign else 1)
	box_ui.add_child(line)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 24)
	if next and multiplayer.is_server():
		var again := Button.new()
		again.name = "NextShift"
		again.text = "JAILBREAK_NEXT_SHIFT"
		again.pressed.connect(_next_shift)
		buttons.add_child(again)
	var menu := Button.new()
	menu.name = "Menu"
	menu.text = "SHIFT_MENU"
	menu.pressed.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))
	buttons.add_child(menu)
	box_ui.add_child(buttons)
	panel.add_child(box_ui)
	center.add_child(panel)
	end_screen.add_child(center)
	add_child(end_screen)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## The host plays the campaign's next shift with everyone (solo, just this PC).
func _next_shift() -> void:
	if Net.is_online():
		Net.start_match()
	else:
		PlaceDraw.start(get_tree())
