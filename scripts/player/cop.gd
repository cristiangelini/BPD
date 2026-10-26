class_name Cop
extends CharacterBody3D

## First person cop: walk, run with stamina, crouch and jump (docs/diseno/escala.md).

const MOUSE_SENSITIVITY := 0.0025
## Render layer of the cop's own body: hidden from its own camera, but it still casts a shadow.
const OWN_BODY_LAYER := 20
## One skin color per player on the same blue uniform (decision 72; placeholder models from tools/modelgen).
const UNIFORMS: Array[PackedScene] = [
	preload("res://assets/models/cop_0.glb"), preload("res://assets/models/cop_1.glb"),
	preload("res://assets/models/cop_2.glb"), preload("res://assets/models/cop_3.glb"),
]
const RAM_SCENE := preload("res://scenes/tools/battering_ram.tscn")
const RAM_PICKUP_SCENE := preload("res://scenes/tools/ram_pickup.tscn")
## A dropped ram lands this far in front of the cop.
const DROP_AHEAD := 1.0
const GLOVE_MATERIAL := preload("res://assets/materials/rubber_glove.tres")
## Seconds a donut keeps the mouth too full to ask anything (comisaria.md, propuesta).
const MOUTH_FULL := 3.0
## A shove fades out in this many seconds.
const KNOCK_FADE := 0.5
## Seconds of running before a straight piece of disguise falls off, and a crooked one. (propuesta)
const DISGUISE_LOOSE_RUN := 4.0
const DISGUISE_CROOKED_RUN := 1.5
## Climbing onto a crouched partner's shoulders (boost_on) puts the feet this high over its feet.
const BOOST_UP := GameScale.CROUCH_HEIGHT + 0.05
## After a piece falls, the next can't fall for this long (s), so a wall doesn't knock off everything at once.
const DISGUISE_FALL_GAP := 1.0

## Crawling in a duct, and scrambling (running) there.
const CRAWL_SPEED := GameScale.CROUCH_SPEED / 2.0
const CRAWL_RUN_SPEED := GameScale.CROUCH_SPEED

@export var input_enabled := true

var stamina := GameScale.RUN_STAMINA
var is_running := false
var is_crouching := false
## In a duct (the vent jailbreak, VentDuct): down on all fours, slower, and running there is a noisy scramble.
var crawling := false
## After running out of stamina, running waits until half of it is back.
var exhausted := false
## Found in one of the pots by the grandpa's front door.
var has_key := false
## A duck float around the waist, from the patrol car's trunk in the flooding bank (BankFloats).
var duck_float := false
## The battering ram in hand, if this cop carries it. Hands are busy: no grabbing.
var ram: BatteringRam
## The wheelbarrow this cop pushes, if any. Hands are busy: E loads things into it instead of grabbing.
var wheelbarrow: Wheelbarrow
var _stagger_left := 0.0
## Letting go of E during the grandpa's story already asked him to stop (online it takes a moment to happen).
var _story_end_asked := false
## A shove (the champion grandpa) that slides the cop and fades out.
var _knock := Vector3.ZERO
## Eating a sample from the baker: the cop can walk but not grab anything (panaderia.md).
var _eating_left := 0.0
## A donut fills the mouth: no questions (R) until this runs out.
var _mouth_full_left := 0.0
## While holding E on the grandpa he tells a story; this cop can't do anything else (allanamiento.md).
var listening_to: Grandpa
## While holding E on an inmate this cop talks them down (carcel-motin.md, step 4); letting go ends it.
var talking_to: PrisonInmate
var _talk_end_asked := false
## While holding E on the flooding bank's valve this cop turns it (BankValve); letting go ends it.
var turning: Node
var _turn_end_asked := false
## Silly numbers for the joke awards at the end of the shift (decision 41).
var stats := {"ram_misses": 0, "story_seconds": 0.0, "meters_driven": 0.0, "photos": 0}
## The patrol car this cop sits in, if any: the body rides the seat and doesn't walk or collide.
var vehicle: PatrolCar
## The prison bus this cop stands in (traslado-presos.md): it walks the aisle and goes along with the bus.
var riding: PrisonBus
## The comisario is giving the case (CaseBriefing): the cop can look around but not move or use things.
var in_briefing := false
## The armero's list is open for this cop (ArmoryMenu): same as the briefing, but only for this cop.
var in_menu := false
## What this cop sits on: the pet salon's armchair with a dog, hearing Ramiro (WaitingArmchair), or an interrogation
## chair (InterrogationChair). Can look, not move; it has prompt_key() and stand_up().
var seated_in: Node
## The player's own first person hands; only a cop with a player at the keys has them.
var hands: CopHands
## Wears the armory's rubber gloves: fragile evidence in these hands loses half as much (Evidence.GLOVES_FACTOR).
var gloves := false
## Player index (0 to 3) whose skin this cop wears.
var uniform := 0
## Online, what keeps this cop the same on every PC (null when playing solo).
var sync: CopSync
## The 4 tool slots (herramientas.md).
var belt: ToolBelt
## A partner cuffed this cop: no grabbing, tools or ram until it runs out or someone frees them with E.
var _cuffed_left := 0.0
## The disguise it has on: kind ("wig", "glasses", "mustache") -> how crooked (radians, signed).
var disguise := {}
## Seconds of running that shake the disguise, and how long until a piece can fall again.
var _shaken := 0.0
## Something slows the cop down for a while (the market's cramps, Cramps): walking and running speed times this.
var slow_factor := 1.0
## Wading in the flooded bank (BankWater): walking and running speed times this too.
var wade := 1.0
var _fall_gap_left := 0.0
## Climbing over a fence (Climbable): seconds left, where it started and the climb.
var climb_left := 0.0
var _climb_from := Vector3.ZERO
var _climb := {}

@onready var _shape: CollisionShape3D = $Shape
@onready var _head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var model: Node3D = $Model
@onready var _hint: Label = $Hud/Hint
@onready var _hint_timer: Timer = $Hud/Hint/Timer
@onready var _prompt: Label = $Hud/Prompt


func _ready() -> void:
	add_to_group("cops")
	InputSetup.ensure_actions()
	camera.fov = GameScale.FOV
	_apply_height(GameScale.COP_HEIGHT)
	_hint_timer.timeout.connect(_hint.hide)
	belt = ToolBelt.new(self)
	add_child(belt)
	if input_enabled:
		_hide_from_own_camera()
		hands = CopHands.new(self)
		camera.add_child(hands)
		# Online, the player's own cop brings in the other players' cops (docs/diseno/online.md).
		if Net.is_online():
			Net.spawn_cops.call_deferred(self)
		# Under investigation, the internal affairs agent comes into the case too (sobornos.md), and on the last shift
		# the city's inspector (inspeccion.md).
		_join_agent.call_deferred()


func _join_agent() -> void:
	if InternalAffairsAgent.join(self) or InternalAffairsAgent.of(self):
		show_hint("HINT_AGENT_ARRIVES")
	# On the last shift, the city's inspector comes along (inspeccion.md).
	if CityInspector.join(self) or CityInspector.of(self):
		show_hint("HINT_INSPECTOR_ARRIVES")


## What the camera points at within reach (empty if nothing), ignoring the cop's own body.
func aim_hit(reach: float) -> Dictionary:
	var eye := camera.global_transform
	var query := PhysicsRayQueryParameters3D.create(eye.origin, eye.origin - eye.basis.z * reach)
	# What's in hand doesn't hide what's behind it (the armchair under the dog).
	query.exclude = [get_rid(), $Grabber.held.get_rid()] if $Grabber.held else [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)


func equip_ram() -> void:
	belt.holster()
	ram = RAM_SCENE.instantiate()
	ram.cop = self
	camera.add_child(ram)


## Lets go of the ram: it drops on the floor in front, where E picks it up again.
func drop_ram() -> RamPickup:
	if not ram:
		return null
	ram.queue_free()
	ram = null
	var pickup: RamPickup = RAM_PICKUP_SCENE.instantiate()
	var ahead := -global_basis.z * DROP_AHEAD
	get_parent().add_child(pickup)
	pickup.global_position = global_position + ahead
	pickup.rotation.y = rotation.y
	return pickup


## The key text (tr() key) for what this cop can do right now: what's in hand, else what the camera points at.
func current_prompt() -> String:
	if vehicle:
		var reach := window_target()
		return reach.prompt_key(self) if reach else ""
	if in_briefing or in_menu:
		return ""
	if seated_in:
		return seated_in.prompt_key(self)
	if $Grabber.held:
		var aimed := _usable_target()
		if aimed is WaitingArmchair or aimed is DigSpot or aimed is InterrogationSuspect or aimed is PastryCook \
				or aimed is TunnelHole or aimed is CircusClown or aimed is CellHideout \
				or (aimed is CellDoor and $Grabber.held is CellKey) \
				or (aimed is QueueCar and $Grabber.held is Breathalyzer and aimed.breath_check_ready()) \
				or aimed is BankVine \
				or aimed is CellHeater \
				or aimed is BedSheet or aimed is SheetRope or aimed is RoofAntenna \
				or (aimed is CellDoor and ($Grabber.held is CellKey or $Grabber.held is BillWad)):
			return aimed.prompt_key(self)
		if $Grabber.held.has_method("held_prompt_key"):
			return $Grabber.held.held_prompt_key(self)
		return "PROMPT_HOLDING"
	if ram:
		return "PROMPT_RAM"
	if is_cuffed():
		return "PROMPT_CUFFED"
	if wheelbarrow:
		var aimed := aim_hit(GameScale.GRAB_REACH)
		if not aimed.is_empty() and aimed.collider is Grabbable:
			return "PROMPT_WHEELBARROW_LOAD" if wheelbarrow.can_load(aimed.collider) else "PROMPT_WHEELBARROW_FULL"
		return "PROMPT_WHEELBARROW"
	if belt.held_tool():
		return belt.held_tool().prompt_key()
	var partner := _cuffed_partner()
	if partner:
		return "PROMPT_UNCUFF"
	if _crouched_partner():
		return "PROMPT_BOOST"
	var target := _usable_target()
	if target and target.has_method("prompt_key"):
		return target.prompt_key(self)
	var hit := aim_hit(GameScale.GRAB_REACH)
	if not hit.is_empty() and hit.collider is Grabbable:
		return hit.collider.prompt_key(self) if hit.collider.has_method("prompt_key") else "PROMPT_GRAB"
	return ""


## Loses balance for a while: can't move or charge the ram.
func stagger(seconds: float) -> void:
	_stagger_left = maxf(_stagger_left, seconds)


## Shoves the cop with `push` (m/s, fading out over about KNOCK_FADE seconds) and staggers it.
func knock_back(push: Vector3, seconds: float) -> void:
	_knock = push
	stagger(seconds)


func is_staggered() -> bool:
	return _stagger_left > 0.0


## Eats something for `seconds`: lets go of what it holds and can't grab until done.
func eat(seconds: float) -> void:
	$Grabber.release()
	_eating_left = maxf(_eating_left, seconds)
	show_hint("HINT_EATING")


func is_eating() -> bool:
	return _eating_left > 0.0


## Eats a donut from the box in hand: stamina full again, and the mouth too full to ask for MOUTH_FULL seconds.
func eat_donut(box: DonutBox) -> bool:
	if not box or not box.eat_one():
		show_hint("HINT_DONUTS_GONE")
		return false
	fill_up_on_donut()
	show_hint("HINT_DONUT")
	# Eaten in front of a suspect in an interrogation, it's the bad cop's move (interrogatorio.md).
	get_tree().call_group("interrogation", "donut_eaten_by", self)
	get_tree().call_group("city_inspector", "saw_donut", self)
	return true


## What a donut does: stamina full again, and the mouth too full to ask for MOUTH_FULL seconds.
func fill_up_on_donut() -> void:
	stamina = GameScale.RUN_STAMINA
	exhausted = false
	_mouth_full_left = MOUTH_FULL


## E with a spare battery in hand (the blackout): into the flashlight, full again. Every PC does it; the host's
## PropSync takes the old battery away from the guests.
func change_battery(battery: FlashlightBattery) -> void:
	if not battery:
		return
	$Grabber.release()
	belt.flashlight.recharge()
	show_hint("HINT_BATTERY_CHANGED")
	if multiplayer.is_server():
		battery.queue_free()


## E with a visitor's thing in hand (the visiting day): opened, on every PC. The thing goes as an argument, so every
## PC finds its own copy (PropSync), since the host made it during the case.
func open_visit_item(item: VisitItem) -> void:
	if item:
		item.use(self)


## E with a crime scene clue in hand (CrimeClueItem): into a bag if aiming at the bags, or eaten.
func use_clue_in_hand(item: CrimeClueItem, aimed: Node) -> void:
	if item:
		item.used_in_hand(self, aimed)


func mouth_full() -> bool:
	return _mouth_full_left > 0.0
## Cuffed by a partner for `seconds`: lets go of everything in hand.
func cuffed(seconds: float) -> void:
	$Grabber.release()
	drop_ram()
	if wheelbarrow:
		wheelbarrow.park()
	belt.holster()
	_cuffed_left = maxf(_cuffed_left, seconds)
	show_hint("HINT_CUFFED")


func uncuff() -> void:
	_cuffed_left = 0.0


## Frees a cuffed `partner` (E on them). Through act(), so it happens on every PC.
func free_partner(partner: Cop) -> void:
	if partner:
		partner.uncuff()


## The belt's actions, through act() so every PC sees the same tool in hand, the same light and the same cuffs.
func belt_select(index: int) -> void:
	belt.select(index)


func belt_flashlight() -> void:
	belt.flashlight.toggle()


func belt_cuff(body: Node, at: Vector3) -> void:
	var target := (belt.tools[0] as Handcuffs).cuff_body(body, at)
	if target:
		get_tree().call_group("city_inspector", "saw_cuffed", self, target)


## This cop took a bribe of `amount` from whoever `body` belongs to (sobornos.md): they stay free and won't offer
## again. Through act(), so every PC counts it for the joke award; the host's campaign adds it to the shift, unless
## the internal affairs agent saw it (decision 192).
## Whoever `body` belongs to offered a bribe (Handcuffs): they won't offer again, to any cop on any PC.
func belt_bribe_offered(body: Node) -> void:
	var from := Handcuffs.cuffable(body) if body else null
	if from:
		(from as Node).set_meta("bribe_offered", true)


func belt_bribe(body: Node, amount: int) -> void:
	var from := Handcuffs.cuffable(body) if body else null
	if from:
		(from as Node).set_meta("bribe_offered", true)
	stats["bribes"] = stats.get("bribes", 0) + 1
	var agent := InternalAffairsAgent.of(self)
	var seen := agent != null and agent.sees(self)
	if seen:
		agent.caught_bribe()
		show_hint("HINT_BRIBE_CAUGHT")
	if Campaign.current:
		Campaign.current.take_bribe(amount, seen)
	get_tree().call_group("city_inspector", "saw_bribe", self)


func belt_photo(subject: Node, caught: Array) -> void:
	(belt.tools[2] as PhotoCamera).develop(subject, caught)


func belt_prints(target: Node, at: Vector3) -> void:
	if target:
		(belt.tools[3] as PrintKit).reveal(target, at)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## Busy: staggered, listening to the grandpa, sitting in the car or in the salon's armchair, hearing the comisario
## or at the armero's list. No walking, grabbing or ramming.
func is_busy() -> bool:
	return is_staggered() or listening_to != null or vehicle != null or in_briefing or in_menu or seated_in != null


## Something this cop can reach out of the patrol car's window (the "window_reach" group: the toy helicopter's rope),
## which E grabs instead of getting out.
func window_target() -> Node:
	for node in get_tree().get_nodes_in_group("window_reach"):
		if node.can_reach(self):
			return node
	return null


## Rides `seat` of `car`, facing forward, until stand_up(). Lets go of whatever it was holding.
func sit_in(car: PatrolCar, seat: Node3D) -> void:
	$Grabber.release()
	if wheelbarrow:
		wheelbarrow.park()
	vehicle = car
	velocity = Vector3.ZERO
	_shape.disabled = true
	reparent(seat, false)
	transform = Transform3D.IDENTITY
	_head.rotation.x = 0.0


## Gets out of the car and stands at `at` (world position), turned to `yaw`.
func stand_up(at: Vector3, yaw: float) -> void:
	var world := vehicle.get_parent()
	vehicle = null
	reparent(world, false)
	global_transform = Transform3D(Basis(Vector3.UP, yaw), at + Vector3.UP * 0.1)
	_shape.disabled = false


## The host put something in this cop's hands (a donut, the key): online, the owner's hands are told.
func handed(item: Grabbable) -> void:
	$Grabber.grab(item)
	if sync and not sync.is_multiplayer_authority() and sync.multiplayer.is_server():
		sync.tell_held()


## Tucked away out of sight (inside the garbage jailbreak's bag): nobody sees it and it bumps into nothing.
func tuck_away(away: bool) -> void:
	visible = not away
	_shape.disabled = away
	velocity = Vector3.ZERO


## The same name for this cop on every PC (its CopSync's), for what the host sends about it.
func net_id() -> String:
	return String(sync.name) if sync else String(name)


## Puts the cop at `to` at once, empty-handed (the jailbreak's guard putting it back in its cell). Online, the host
## moving another player's cop tells its owner, who moves it for everyone.
func warp(to: Transform3D) -> void:
	$Grabber.release()
	velocity = Vector3.ZERO
	global_transform = to
	if sync and not sync.is_multiplayer_authority() and sync.multiplayer.is_server():
		sync.tell_warp(to)


## Shows a short line at the bottom of this cop's screen. `key` is a tr() key. Online, a hint the host gives its copy
## of another player's cop goes to that player's screen.
## `decided_here`: the host alone decided it (the jailbreak's key), so it goes to the owner even inside the owner's
## own action.
func show_hint(key: String, decided_here := false) -> void:
	if sync and not sync.is_multiplayer_authority() and sync.multiplayer.is_server():
		if decided_here or not (sync.net.actions and sync.net.actions.performing):
			sync.tell_hint(key)
	_hint.text = key
	_hint.show()
	_hint_timer.start()


## Swaps the body for the skin of player `index` (0 to 3).
func set_uniform(index: int) -> void:
	uniform = index
	var old: Node3D = get_node("Model")
	var fresh: Node3D = UNIFORMS[index % UNIFORMS.size()].instantiate()
	fresh.transform = old.transform
	remove_child(old)
	old.queue_free()
	fresh.name = "Model"
	add_child(fresh)
	model = fresh
	if input_enabled and is_node_ready():
		_hide_from_own_camera()
	if hands:
		hands.set_skin(index)
	if gloves:
		put_on_gloves()


## Puts on the armory's yellow rubber gloves: on the body everyone sees and on the own first person hands.
func put_on_gloves() -> void:
	gloves = true
	for s: float in [-1.0, 1.0]:
		var glove := MeshInstance3D.new()
		var ball := SphereMesh.new()
		ball.radius = 0.085
		ball.height = 0.17
		ball.material = GLOVE_MATERIAL
		glove.mesh = ball
		glove.position = Vector3(s * 0.49, 0.64, 0.09)
		model.add_child(glove)
	if hands:
		hands.set_gloves(true)


func _hide_from_own_camera(part: Node3D = null) -> void:
	for mesh in (part if part else model).find_children("*", "VisualInstance3D", true, false):
		(mesh as VisualInstance3D).layers = 1 << (OWN_BODY_LAYER - 1)
	camera.cull_mask &= ~(1 << (OWN_BODY_LAYER - 1))


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look(event.relative * MOUSE_SENSITIVITY)
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("drop"):
		if wheelbarrow:
			act("wheelbarrow_dump", self)
		elif ram:
			act("drop_ram", self)
	elif event.is_action_pressed("ask"):
		# Sat on something that takes R (the talent show's jury chair, its score card).
		if seated_in and seated_in.has_method("ask"):
			act("ask", seated_in)
		else:
			ask()
	elif event.is_action_pressed("use"):
		if vehicle and window_target():
			act("use", window_target())
		elif vehicle:
			act("exit", vehicle)
		elif seated_in:
			seated_in.stand_up()
		else:
			use()


func _physics_process(delta: float) -> void:
	# Without local input someone else drives this cop through step() (tests, later the network).
	if not input_enabled:
		return
	var prompt := current_prompt()
	_prompt.text = prompt
	_prompt.visible = prompt != ""
	if vehicle:
		return
	if listening_to and not Input.is_action_pressed("use"):
		if not _story_end_asked:
			_story_end_asked = true
			act("end_story", listening_to)
	elif not listening_to:
		_story_end_asked = false
	if talking_to and not Input.is_action_pressed("use"):
		if not _talk_end_asked:
			_talk_end_asked = true
			act("end_talk", talking_to)
	elif not talking_to:
		_talk_end_asked = false
	if turning and not Input.is_action_pressed("use"):
		if not _turn_end_asked:
			_turn_end_asked = true
			act("end_turn", turning, [self])
	elif not turning:
		_turn_end_asked = false
	var wish := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	step(delta, wish, Input.is_action_pressed("run"), Input.is_action_pressed("crouch"),
		Input.is_action_just_pressed("jump"))


## Uses what the camera points at (a pot, a door...), if it can be used. Returns true if something was used.
func use() -> bool:
	# A bribe on offer with the cuffs in hand: E takes it (sobornos.md).
	if belt.held_tool() is Handcuffs and (belt.held_tool() as Handcuffs).take_offer():
		return true
	if $Grabber.held is DonutBox and (_usable_target() is InterrogationSuspect or _usable_target() is PastryCook
			or _usable_target() is CircusClown):
		act("use", _usable_target())
		return true
	# The circus's clowns take the sponge and the loaves from the hand too (escena-circo.md).
	if ($Grabber.held is ClownSponge or $Grabber.held is ClownSign or $Grabber.held is Bread) \
			and _usable_target() is CircusClown:
		act("use", _usable_target())
		return true
	# The wedding check's breathalyzer, to a stopped driver (control-boda.md).
	if $Grabber.held is Breathalyzer and _usable_target() is QueueCar and _usable_target().breath_check_ready():
		act("use", _usable_target())
		return true
	# A donut or a croissant for a hostage at the bank's party (robo-banco-rehenes.md, step 4).
	if BankHostage.food_of(self) and _usable_target() is BankHostage and (_usable_target() as BankHostage).wants_food():
		act("use", _usable_target())
		return true
	if $Grabber.held is BankCroissant:
		act("use", $Grabber.held)
		return true
	if $Grabber.held is DonutBox:
		if ($Grabber.held as DonutBox).donuts == 0:
			show_hint("HINT_DONUTS_GONE")
			return false
		act("eat_donut", self, [$Grabber.held])
		return true
	if $Grabber.held is HookStick or $Grabber.held is LooseDonut or $Grabber.held is SamplePlate \
			or $Grabber.held is FloorPolisher or $Grabber.held is Watermelon or $Grabber.held is KitchenVessel:
		act("use", $Grabber.held)
		return true
	if $Grabber.held is VisitItem:
		act("open_visit_item", self, [$Grabber.held])
		return true
	if $Grabber.held is FlashlightBattery:
		act("change_battery", self, [$Grabber.held])
		return true
	if $Grabber.held is CrimeClueItem:
		act("use_clue_in_hand", self, [$Grabber.held, _usable_target()])
		return true
	if wheelbarrow:
		return _use_wheelbarrow()
	var partner := _cuffed_partner()
	if partner:
		act("free_partner", self, [partner])
		return true
	var below := _crouched_partner()
	if below:
		act("boost_on", self, [below])
		return true
	var target := _usable_target()
	if not target:
		return false
	act("use", target, target.use_args(self) if target.has_method("use_args") else [])
	return true


## Does `method` on `target` (this cop itself for "drop_ram") with `args`. Online it happens on every PC in the same
## order (ActionSync); solo it just happens.
func act(method: String, target: Node, args := []) -> void:
	if sync and sync.net.actions:
		sync.net.actions.act(self, method, target, args)
	else:
		target.callv(method, ([self] if method in ActionSync.ACTOR_METHODS else []) + args)


## Pushing the wheelbarrow, E loads what the camera points at, or parks it when it points at nothing to load.
func _use_wheelbarrow() -> bool:
	var aimed := aim_hit(GameScale.GRAB_REACH)
	if not aimed.is_empty() and aimed.collider is Grabbable:
		if wheelbarrow.can_load(aimed.collider):
			act("wheelbarrow_load", self, [aimed.collider])
		else:
			show_hint("HINT_WHEELBARROW_FULL")
		return true
	act("wheelbarrow_park", self)
	return true


## The wheelbarrow's actions, through act() so it carries the same load on every PC.
func wheelbarrow_load(item: Grabbable) -> void:
	if wheelbarrow and item:
		wheelbarrow.add(item)


func wheelbarrow_park() -> void:
	if wheelbarrow:
		wheelbarrow.park()


func wheelbarrow_dump() -> void:
	if wheelbarrow:
		wheelbarrow.dump()


## Asks what the camera points at a question (R), if it can be asked (the grandpa). Returns true if it answered.
func ask() -> bool:
	var target := _usable_target()
	if is_busy() or not target or not target.has_method("ask"):
		return false
	if mouth_full():
		show_hint("HINT_MOUTH_FULL")
		return false
	if sync and sync.net.actions:
		sync.net.actions.act(self, "ask", target)
		return true
	return target.ask(self)


## A cuffed cop the camera points at within reach, if any.
func _cuffed_partner() -> Cop:
	var hit := aim_hit(GameScale.GRAB_REACH)
	if not hit.is_empty() and hit.collider is Cop and (hit.collider as Cop).is_cuffed():
		return hit.collider
	return null


## A crouched cop the camera points at within reach: E climbs onto its shoulders (fuga-techo.md, "hacer pie").
func _crouched_partner() -> Cop:
	var hit := aim_hit(GameScale.GRAB_REACH)
	if not hit.is_empty() and hit.collider is Cop and (hit.collider as Cop).is_crouching \
			and not (hit.collider as Cop).is_cuffed():
		return hit.collider
	return null


## Up onto `partner`'s shoulders (it's crouched): standing on it, high enough to reach a cell's skylight.
func boost_on(partner: Cop) -> void:
	warp(Transform3D(global_basis, partner.global_position + Vector3.UP * BOOST_UP))
	show_hint("HINT_BOOSTED")


## What the camera points at within reach that can be used with E (a door's body is a child of the door).
func _usable_target() -> Node:
	var hit := aim_hit(GameScale.GRAB_REACH)
	if hit.is_empty():
		return null
	var target: Node = hit.collider
	if target is Cop:
		return null
	if not target.has_method("use"):
		target = target.get_parent()
	return target if target.has_method("use") else null


## Rotates the view: x turns the body, y tilts the head.
func look(amount: Vector2) -> void:
	rotate_y(-amount.x)
	_head.rotation.x = clampf(_head.rotation.x - amount.y, deg_to_rad(-89.0), deg_to_rad(89.0))


## One movement tick. Kept apart from input so tests can drive it.
func step(delta: float, wish: Vector2, want_run: bool, want_crouch: bool, want_jump: bool) -> void:
	# Tucked away in something that carries it (the garbage bag, the truck): it only goes where that goes.
	if seated_in and seated_in.has_method("hold_point"):
		global_position = seated_in.hold_point(self)
		velocity = Vector3.ZERO
		return
	_update_crouch(want_crouch)
	var moving := wish.length() > 0.1
	if stamina <= 0.0:
		exhausted = true
	elif stamina >= GameScale.RUN_STAMINA * GameScale.STAMINA_RESUME:
		exhausted = false
	is_running = want_run and moving and (crawling or not is_crouching) and not exhausted
	if is_running:
		stamina = maxf(stamina - delta, 0.0)
	else:
		stamina = minf(stamina + delta * GameScale.RUN_STAMINA / GameScale.STAMINA_RECOVERY, GameScale.RUN_STAMINA)

	_stagger_left = maxf(_stagger_left - delta, 0.0)
	_eating_left = maxf(_eating_left - delta, 0.0)
	_mouth_full_left = maxf(_mouth_full_left - delta, 0.0)
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if climb_left > 0.0:
		_climbing(delta)
		return
	# The world's turn, so a cop standing in the moving prison bus (a child of it) walks where it looks.
	var direction := (global_basis * Vector3(wish.x, 0.0, wish.y)).normalized()
	direction.y = 0.0
	direction = direction.normalized()
	var speed := 0.0 if is_busy() else current_speed()
	velocity.x = direction.x * speed + _knock.x
	velocity.z = direction.z * speed + _knock.z
	_knock = _knock.move_toward(Vector3.ZERO, _knock.length() / KNOCK_FADE * delta) if _knock.length() > 0.05 else Vector3.ZERO
	if is_on_floor():
		if want_jump and not is_crouching and not _start_climb():
			velocity.y = GameScale.jump_velocity()
	else:
		velocity.y -= GameScale.GRAVITY * delta
	move_and_slide()
	_shake_disguise(delta)


## Jumping against a fence climbs it (ciudad-viva.md, step 4). Returns true if a climb started.
func _start_climb() -> bool:
	if is_busy():
		return false
	_climb = Climbable.find(get_world_3d().direct_space_state, global_position, -global_basis.z, [get_rid()])
	if _climb.is_empty():
		return false
	_climb_from = global_position
	climb_left = Climbable.CLIMB_TIME
	return true


func _climbing(delta: float) -> void:
	climb_left = maxf(climb_left - delta, 0.0)
	velocity = Vector3.ZERO
	global_position = Climbable.along(_climb_from, _climb, 1.0 - climb_left / Climbable.CLIMB_TIME)


## Running shakes the disguise (but not sportswear, DisguisePiece.TIGHT): the most crooked piece falls off after DISGUISE_CROOKED_RUN seconds of running (a
## straight one after DISGUISE_LOOSE_RUN), and running into a wall knocks it off at once. The cop's own PC decides.
func _shake_disguise(delta: float) -> void:
	_fall_gap_left = maxf(_fall_gap_left - delta, 0.0)
	var shakable := disguise.keys().filter(func(kind: String) -> bool: return not DisguisePiece.TIGHT.has(kind))
	if shakable.is_empty():
		_shaken = 0.0
		return
	_shaken = _shaken + delta if is_running else maxf(_shaken - delta, 0.0)
	var loosest: String = shakable[0]
	for kind: String in shakable:
		if absf(disguise[kind]) > absf(disguise[loosest]):
			loosest = kind
	var limit := DISGUISE_CROOKED_RUN if absf(disguise[loosest]) > DisguisePiece.CROOKED else DISGUISE_LOOSE_RUN
	if _fall_gap_left > 0.0 or not ((is_running and is_on_wall()) or _shaken >= limit):
		return
	_shaken = 0.0
	_fall_gap_left = DISGUISE_FALL_GAP
	act("lose_disguise", self, [loosest])


## Wears a piece of disguise (DisguisePiece put it there), `tilt` radians crooked.
func put_on_disguise(kind: String, tilt: float) -> void:
	disguise[kind] = tilt
	var holder := get_node_or_null("Disguise") as Node3D
	if not holder:
		holder = Node3D.new()
		holder.name = "Disguise"
		add_child(holder)
	var old := holder.get_node_or_null(kind)
	if old:
		holder.remove_child(old)
		old.queue_free()
	var worn: Node3D = DisguisePiece.MODELS[kind].instantiate()
	worn.name = kind
	worn.position = DisguisePiece.SLOTS[kind]
	# The models face +Z and the cop -Z.
	worn.rotation = Vector3(0, PI, tilt)
	holder.add_child(worn)
	if input_enabled:
		_hide_from_own_camera(worn)


## A piece of disguise falls off in front of the cop (the host makes the one on the floor), or the cop took it off
## (`hint` says which).
func lose_disguise(kind: String, hint := "HINT_DISGUISE_FELL") -> void:
	if not disguise.has(kind):
		return
	var at := DisguisePiece.slot_on(self, kind)
	disguise.erase(kind)
	var worn := get_node_or_null("Disguise/" + kind)
	if worn:
		worn.get_parent().remove_child(worn)
		worn.queue_free()
	show_hint(hint)
	if not multiplayer.is_server() or not get_parent():
		return
	var piece: DisguisePiece = DisguisePiece.scene_of(kind).instantiate()
	get_parent().add_child(piece)
	piece.global_position = at - global_basis.z * 0.35
	piece.linear_velocity = -global_basis.z * 1.5 + Vector3.UP


## Enough disguise on to pass for `look` (DisguisePiece.LOOKS): a grandparent by default, or a chorister.
func is_disguised(look := "grandparent") -> bool:
	var wanted: Dictionary = DisguisePiece.LOOKS[look]
	return wanted.pieces.filter(func(kind: String) -> bool: return disguise.has(kind)).size() >= wanted.needed


func current_speed() -> float:
	var factor := (BatteringRam.SPEED_FACTOR if ram else 1.0) * slow_factor * wade
	if wheelbarrow:
		factor = Wheelbarrow.SPEED_FACTOR * slow_factor * wade
	if crawling:
		return (CRAWL_RUN_SPEED if is_running else CRAWL_SPEED) * factor
	if is_crouching:
		return GameScale.CROUCH_SPEED * factor
	if is_running:
		return GameScale.RUN_SPEED * factor
	return GameScale.WALK_SPEED * factor


func head_pitch() -> float:
	return _head.rotation.x


func set_head_pitch(pitch: float) -> void:
	_head.rotation.x = pitch


## Crouches or stands right away, without checking the ceiling: for a copy of another player's cop.
func set_crouching(crouching: bool) -> void:
	if crouching != is_crouching:
		is_crouching = crouching
		_apply_height(GameScale.CROUCH_HEIGHT if is_crouching else GameScale.COP_HEIGHT)


func _update_crouch(want_crouch: bool) -> void:
	if want_crouch == is_crouching:
		return
	if not want_crouch and _blocked_above():
		return
	is_crouching = want_crouch
	_apply_height(GameScale.CROUCH_HEIGHT if is_crouching else GameScale.COP_HEIGHT)


func _apply_height(height: float) -> void:
	var capsule := _shape.shape as CapsuleShape3D
	capsule.height = height
	_shape.position.y = height / 2.0
	_head.position.y = height - (GameScale.COP_HEIGHT - GameScale.EYE_HEIGHT)


func _blocked_above() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	var standing := CapsuleShape3D.new()
	standing.radius = GameScale.COP_RADIUS
	standing.height = GameScale.COP_HEIGHT
	query.shape = standing
	query.transform = global_transform.translated(Vector3.UP * (GameScale.COP_HEIGHT / 2.0 + 0.05))
	query.exclude = [get_rid()]
	return not get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
