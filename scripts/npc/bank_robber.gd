class_name BankRobber
extends CharacterBody3D

## A robber of the bank (robo-banco.md, step 2, decision 102), with a rubber animal mask. Each one stands at a task
## and looks at it, sweeping their head like the night guard of the jailbreak: the rabbit watches the entrance and
## looks everywhere, the pig watches the hostages and stops to eat his sandwich, the duck watches the drill at the
## vault with ear muffs on and a narrow cone, and El Oso, the boss, stands behind the counter by the phone. Whoever
## sees a cop in their cone says so and `spotted` goes off (the drill speeds up in step 3); seeing a hostage being
## led out, `saw_hostage` (step 4). The handcuffs only close on one who doesn't see a cop at arm's length (from behind),
## except the rabbit, who gives up as soon as he sees one; the pig, seeing one, drops his sandwich and runs to the
## van, where he hides for the getaway (step 6). Cuffed, E walks them to the patrol car (OwnerEscort). Online the
## host's decide and a guest's follow them (NpcSync, net_state). Every number here is (propuesta).

signal spotted(robber: BankRobber, cop: Node3D)
signal saw_hostage(robber: BankRobber, hostage: Node3D)
## The handcuffs closed on them.
signal cuffed_now(robber: BankRobber)
## The pig got into the van.
signal hid_in_van(robber: BankRobber)
## A grandpa robber led out by the hand as if he were a hostage got away outside (he counts as a sack taken).
signal slipped_out(robber: BankRobber)
## A cop talked the sorry robber round (robo-banco-arrepentido.md, step 2): he's on the cops' side now.
signal turned_now(robber: BankRobber)
## The sorry robber did one of his helps (one of HELPS).
signal helped(robber: BankRobber, help: String)
## The gang caught the sorry robber helping and tied him to a chair (step 4); a cop untied him.
signal tied_up(robber: BankRobber)
signal untied(robber: BankRobber)

const ANIMALS: Array[String] = ["conejo", "chancho", "pato", "oso"]
const MODELS := {
	"conejo": preload("res://assets/models/npc_ladron_conejo.glb"),
	"chancho": preload("res://assets/models/npc_ladron_chancho.glb"),
	"pato": preload("res://assets/models/npc_ladron_pato.glb"),
	"oso": preload("res://assets/models/npc_ladron_oso.glb"),
}
## The grandpa robbers (robo-banco-abuelos.md, decision 122): the same masks on retirees with cane and cardigan.
const GRANDPA_MODELS := {
	"conejo": preload("res://assets/models/npc_abuelo_conejo.glb"),
	"chancho": preload("res://assets/models/npc_abuelo_chancho.glb"),
	"pato": preload("res://assets/models/npc_abuelo_pato.glb"),
	"oso": preload("res://assets/models/npc_abuelo_oso.glb"),
}
## How fast a grandpa robber goes next to a young one.
const GRANDPA_PACE := 0.5
## Hiding among the hostages (robo-banco-abuelos.md, step 2): he walks to his spot this fast (m/s), sits there this
## close to it, and led by the hand follows the cop like a hostage, this far behind.
const HIDE_SPEED := 0.8
const HIDE_REACH := 0.3
const LED_SPEED := 0.9
const LED_KEEP_AWAY := 1.2
const POSE_CROUCH := 0.82
const KNEE_LINES := 3
const SCALES := {"conejo": 1.0, "chancho": 1.0, "pato": 1.0, "oso": 1.15}
## Each one's cone (full angle in degrees and depth in meters) and where their head looks, turned from their body.
const SIGHT := {"conejo": Vector2(100, 10), "chancho": Vector2(80, 8), "pato": Vector2(60, 6), "oso": Vector2(90, 12)}
const LOOKS := {
	"conejo": [0.0, 0.8, -0.3, -0.8, 0.3],
	"chancho": [0.0, 0.4, 0.0, -0.4],
	"pato": [0.0],
	"oso": [0.0, 0.5, 0.0, -0.5],
}
const LOOK_HOLD := 2.5
const TURN_SPEED := 1.5
const EYE_HEIGHT := 1.35
## The pig eats every EAT_EVERY seconds for EAT_TIME, looking at his sandwich: he sees nothing meanwhile.
const EAT_EVERY := 20.0
const EAT_TIME := 5.0
## The same cop doesn't count as spotted again for this long.
const SPOT_AGAIN := 5.0
const LINES := 4
## A cop this close and in sight can't cuff them: they dodge.
const DODGE_REACH := 2.5
## The pig runs this fast (m/s) and gets in the van this close to its door.
const RUN_SPEED := 3.0
const ARRIVED := 0.6
const SAY_TIME := 4.0
## The sorry robber (robo-banco-arrepentido.md, step 1, decision 123): every SOB_EVERY seconds a sob or a sorry line
## (SOB_LINES of them), the hanky up to his mask for SOB_TIME.
const SOB_EVERY := 8.0
const SOB_TIME := 2.0
const SOB_LINES := 4
const HANKY_DOWN := Vector3(0.38, 0.95, -0.32)
const HANKY_UP := Vector3(-0.02, 1.36, -0.5)
## Turned, his helps in order, one at a time (steps 2 and 3): the back door open from inside, the drill unplugged and
## two hostages walked out the back; walking there this fast (m/s), close enough this near to each point of his way,
## and back at his spot between helps for HELP_REST seconds to blend in.
const HELPS: Array[String] = ["door", "drill", "hostages"]
const HELP_SPEED := 1.6
const HELP_REACH := 0.35
const HELP_REST := 5.0
## Tied to the chair (step 4): E starts untying and the cop stays this close for UNTIE_TIME seconds; tied this many
## times he gives up helping.
const UNTIE_TIME := 2.0
const UNTIE_REACH := 1.6
const TIES_TO_QUIT := 3
const TIED_CROUCH := 0.8
## A vampire lit up hides behind his cape this long (s), and has this many lines for it (robo-banco-sangre.md).
const HIDE_TIME := 4.0
const LIGHT_LINES := 3

@export var animal := "conejo"
## The town bank's El Conejo (robo-banco-pueblo.md, decision 127): he robs it alone, so he's the boss.
var alone := false
## One of the grandpa gang: slower, and their own model.
var grandpa := false
## Wading in the flooded bank (BankWater): walking and running speed times this.
var wade := 1.0
## The one who's sorry and wants to give it all back: he cries with a white hanky and doesn't shout about cops or
## hostages led out.
var sorry := false
var sobbing_left := 0.0
var _sob_left := SOB_EVERY
var _next_sob := 0
var _hanky: MeshInstance3D
## The blood bank (robo-banco-sangre.md, decision 128): a black vampire cape with its high collar and plastic fangs.
## Step 2: lit up (lit()), he hides his face behind his cape for HIDE_TIME, blind and still; the bank's lamps make him
## do it once, then he puts his sunglasses on and only a flashlight does.
var vampire := false
var hiding_left := 0.0
var shades := false
var _cape_up: MeshInstance3D
var _shades: MeshInstance3D
var _next_light_line := 0
var _home_yaw := 0.0
## Turned by a cop: the help he's on ("" resting between helps or done) and its leg (a help can take more than one
## walk: the hostages are picked up, then walked out), his way there (world positions, in order),
## whether he's on his way back to his spot, the helps done and how long he still rests.
var turned := false
var helping := ""
var help_stage := 0
var help_path: Array[Vector3] = []
var going_back := false
var helps_done: Array[String] = []
var rest_left := 0.0
## Tied to the chair by the gang, how many times, whether he gave up helping, and the cop untying him and for how much
## longer.
var tied := false
var ties := 0
var gave_up := false
var untying_by: Node3D
var untie_left := 0.0
var _rope: MeshInstance3D
## The level's: whether a loose robber other than him sees `cop`; the way to `help` and back to his spot (world
## positions); and doing `help`'s leg `stage` once there, which gives the way of its next leg (empty when it's done).
var watched: Callable
var help_way: Callable
var way_back: Callable
var do_help: Callable
## A grandpa who saw a cop took his mask off and goes (or went) to sit among the hostages: where (world position, the
## level hands it out), whether he's sitting there, and the cop leading him out by the hand as a hostage.
var unmasked := false
var hide_at := Vector3.ZERO
var posing := false
var led_by: Cop
var slipped := false
## The level's: a free spot on the hostages' floor for `robber` (a world position), and whether a position is out of
## the bank.
var claim_spot: Callable
var is_out: Callable
## Where their head looks now, turned from their body (radians).
var look := 0.0
var eating_left := 0.0
var _eat_left := EAT_EVERY
var _look_index := 0
var _look_left := LOOK_HOLD
var _next_line := 0
## The rabbit gave up: he can be cuffed from the front.
var surrendered := false
## Where the pig runs, in order (world positions; the level sets them): out of the entrance and to the van's door.
var run_path: Array[Vector3] = []
var running := false
## Whether the end of run_path is the van (the blood bank's robbers first run to the fridge and stop there).
var into_van := true
var in_van := false
## A guest's copy (NpcSync): the host's decides whether the cuffs closed.
var follower := false
var _cuffed_left := 0.0
## Cop -> seconds until they count as spotted again.
var _spotted := {}
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_robbers")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6 * SCALES[animal]
	shape.shape = capsule
	shape.position.y = capsule.height / 2
	add_child(shape)
	_model = (GRANDPA_MODELS if grandpa else MODELS)[animal].instantiate()
	_model.scale = Vector3.ONE * SCALES[animal]
	# The models face +Z; the robber faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	_show_mask(true)
	_home_yaw = rotation.y
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	if sorry:
		_add_hanky()
	if vampire:
		_add_cape()


## The white hanky in his right hand.
func _add_hanky() -> void:
	_hanky = MeshInstance3D.new()
	_hanky.name = "Hanky"
	var cloth := PrismMesh.new()
	cloth.size = Vector3(0.22, 0.2, 0.03)
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.97, 0.97, 0.95)
	cloth.material = white
	_hanky.mesh = cloth
	_hanky.position = HANKY_DOWN
	add_child(_hanky)


## The vampire's cape down his back, its collar up behind his head, and two fangs under the mask's snout; on the model,
## which faces +Z and is scaled with him.
func _add_cape() -> void:
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.06, 0.05, 0.07)
	var lining := StandardMaterial3D.new()
	lining.albedo_color = Color(0.6, 0.05, 0.08)
	var cape := MeshInstance3D.new()
	cape.name = "Cape"
	var cloth := BoxMesh.new()
	cloth.size = Vector3(0.78, 1.15, 0.04)
	cape.mesh = cloth
	cape.material_override = black
	cape.position = Vector3(0, 0.75, -0.24)
	cape.rotation.x = 0.08
	_model.add_child(cape)
	var inside := MeshInstance3D.new()
	var inner := BoxMesh.new()
	inner.size = Vector3(0.72, 1.1, 0.01)
	inside.mesh = inner
	inside.material_override = lining
	inside.position = Vector3(0, 0, 0.025)
	cape.add_child(inside)
	var collar := MeshInstance3D.new()
	collar.name = "Collar"
	var high := PrismMesh.new()
	high.size = Vector3(0.7, 0.4, 0.04)
	collar.mesh = high
	collar.material_override = black
	collar.position = Vector3(0, 1.5, -0.22)
	collar.rotation.x = PI
	_model.add_child(collar)
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.98, 0.98, 0.95)
	for side: float in [-1.0, 1.0]:
		var fang := MeshInstance3D.new()
		fang.name = "FangL" if side < 0 else "FangR"
		var tooth := CylinderMesh.new()
		tooth.top_radius = 0.018
		tooth.bottom_radius = 0.0
		tooth.height = 0.06
		fang.mesh = tooth
		fang.material_override = white
		fang.position = Vector3(side * 0.045, 1.2, 0.23)
		_model.add_child(fang)
	# The cape held up over his face with his arm, and the sunglasses.
	_cape_up = MeshInstance3D.new()
	_cape_up.name = "CapeUp"
	var shield := BoxMesh.new()
	shield.size = Vector3(0.62, 0.5, 0.05)
	_cape_up.mesh = shield
	_cape_up.material_override = black
	_cape_up.position = Vector3(0.05, 1.28, 0.36)
	_cape_up.rotation.z = -0.15
	_cape_up.visible = false
	_model.add_child(_cape_up)
	_shades = MeshInstance3D.new()
	_shades.name = "Shades"
	var glasses := BoxMesh.new()
	glasses.size = Vector3(0.36, 0.08, 0.03)
	_shades.mesh = glasses
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.03, 0.03, 0.04)
	dark.metallic = 0.6
	dark.roughness = 0.2
	_shades.material_override = dark
	_shades.position = Vector3(0, 1.33, 0.25)
	_shades.visible = false
	_model.add_child(_shades)


func is_sobbing() -> bool:
	return sobbing_left > 0.0


## Every SOB_EVERY seconds a sob or a sorry line, with the hanky up to his mask.
func _sob(delta: float) -> void:
	if sobbing_left > 0.0:
		sobbing_left = maxf(sobbing_left - delta, 0.0)
	else:
		_sob_left -= delta
		if _sob_left <= 0.0:
			_sob_left = SOB_EVERY
			sobbing_left = SOB_TIME
			say("ROBBER_SORRY_SOB_%d" % (_next_sob % SOB_LINES + 1))
			_next_sob += 1
	if _hanky:
		_hanky.position = HANKY_UP if is_sobbing() else HANKY_DOWN


## How fast the pig runs to the van: half as fast for a grandpa.
func run_speed() -> float:
	return RUN_SPEED * (GRANDPA_PACE if grandpa else 1.0)


func is_boss() -> bool:
	return animal == "oso" or alone


func is_eating() -> bool:
	return eating_left > 0.0


## Where their face points now: their body's front turned by their head.
func facing() -> Vector3:
	return (-global_basis.z).rotated(Vector3.UP, look).normalized()


## Whether they see `at` (a world position): in their cone, near enough and with no wall in between (or the wall hit
## is `body` itself).
func sees(at: Vector3, body: CollisionObject3D = null) -> bool:
	if is_eating() or unmasked or is_hiding():
		return false
	var eye := global_position + Vector3.UP * EYE_HEIGHT
	var flat := Vector3(at.x - eye.x, 0, at.z - eye.z)
	if flat.length() > SIGHT[animal].y or flat.length() < 0.01:
		return false
	if facing().angle_to(flat.normalized()) > deg_to_rad(SIGHT[animal].x) / 2:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	return hit.is_empty() or (body != null and hit.collider == body)


func sees_cop(cop: Node3D) -> bool:
	return sees(cop.global_position + Vector3.UP, cop as CollisionObject3D)


## The handcuffs: they close unless they see a cop right in front of them (the rabbit who gave up lets them).
func cuffed(seconds: float) -> void:
	if follower:
		# Shown closed until the host says otherwise (they dodged them there).
		_cuffed_left = maxf(_cuffed_left, seconds)
		return
	if not surrendered and not is_cuffed():
		for cop: Node3D in get_tree().get_nodes_in_group("cops"):
			if global_position.distance_to(cop.global_position) < DODGE_REACH and sees_cop(cop):
				say("ROBBER_DODGE")
				spotted.emit(self, cop)
				return
	running = false
	posing = false
	led_by = null
	_cuffed_left = maxf(_cuffed_left, seconds)
	say("ROBBER_%s_CUFFED" % animal.to_upper())
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func is_hiding() -> bool:
	return hiding_left > 0.0


## Light on his face (the blood bank): a flashlight, or the bank's lamps (`lamps`), which he only fears once, before
## his sunglasses. He hides behind his cape for HIDE_TIME (again from the start while it keeps shining on him).
func lit(lamps := false) -> void:
	if not vampire or follower or is_cuffed() or in_van or slipped:
		return
	if lamps:
		if shades:
			return
		shades = true
	if not is_hiding():
		say("ROBBER_VAMPIRE_LIGHT_%d" % (_next_light_line % LIGHT_LINES + 1))
		_next_light_line += 1
	hiding_left = HIDE_TIME
	_show_hiding()


## The cape up over his face while he hides, and his sunglasses once he has them on.
func _show_hiding() -> void:
	if _cape_up:
		_cape_up.visible = is_hiding()
	if _shades:
		_shades.visible = shades and not is_hiding()


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if in_van or is_cuffed() or slipped:
		return
	if is_hiding():
		# Behind his cape he sees nothing and doesn't move.
		hiding_left = maxf(hiding_left - delta, 0.0)
		return
	if running:
		_run(delta)
		return
	if unmasked:
		_pose(delta)
		return
	if tied:
		if not follower:
			_untie(delta)
		return
	if turned:
		if not follower:
			_help(delta)
		return
	_turn_head(delta)
	if animal == "chancho":
		_eat(delta)
	if sorry:
		# He keeps quiet about cops and hostages: he's on their side, deep down.
		_sob(delta)
		return
	for seen: Variant in _spotted.keys():
		_spotted[seen] -= delta
		if not is_instance_valid(seen) or _spotted[seen] <= 0.0:
			_spotted.erase(seen)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if not _spotted.has(cop) and sees_cop(cop):
			_spotted[cop] = SPOT_AGAIN
			_saw_cop(cop)
	for hostage: Node3D in get_tree().get_nodes_in_group("bank_hostages"):
		if hostage.get("led_by") and not _spotted.has(hostage) \
				and sees(hostage.global_position + Vector3.UP * 0.8, hostage as CollisionObject3D):
			_spotted[hostage] = SPOT_AGAIN
			say("ROBBER_HOSTAGE")
			saw_hostage.emit(self, hostage)


func _saw_cop(cop: Node3D) -> void:
	say("ROBBER_%s_SPOT" % animal.to_upper())
	if grandpa and not is_boss():
		unmask()
	elif animal == "conejo":
		surrendered = true
	elif animal == "chancho" and not run_path.is_empty():
		running = true
		eating_left = 0.0
		var sandwich := find_child("props", true, false) as Node3D
		if sandwich:
			sandwich.hide()
	spotted.emit(self, cop)


## The sorry robber talked round: unless another robber sees the cop, he's on the cops' side and starts his helps.
func try_turn(cop: Node3D) -> bool:
	if turned or is_cuffed():
		return false
	if watched.is_valid() and watched.call(cop):
		say("ROBBER_SORRY_NOT_NOW")
		return false
	turned = true
	rest_left = 0.0
	say("ROBBER_SORRY_TURN")
	turned_now.emit(self)
	return true


## Turned: on his way to a help, doing it, back to his spot, resting there and on to the next one.
func _help(delta: float) -> void:
	sobbing_left = 0.0
	if _hanky:
		_hanky.position = HANKY_DOWN
	if help_path.is_empty():
		if helping != "":
			_finish_help()
			return
		if going_back:
			going_back = false
			rest_left = HELP_REST
			rotation.y = _home_yaw
		if rest_left > 0.0:
			rest_left = maxf(rest_left - delta, 0.0)
			return
		var next := next_help()
		if next == "":
			return
		helping = next
		help_stage = 0
		help_path = help_way.call(next) if help_way.is_valid() else []
		say("ROBBER_SORRY_GO_%s" % next.to_upper())
		return
	var to := help_path[0] - global_position
	to.y = 0.0
	if to.length() < HELP_REACH:
		help_path.remove_at(0)
		return
	_step(to.normalized() * HELP_SPEED, delta)


## The first of HELPS he hasn't done yet, or "" when he did them all or gave up.
func next_help() -> String:
	if gave_up:
		return ""
	for help in HELPS:
		if help not in helps_done:
			return help
	return ""


func _finish_help() -> void:
	var more: Array[Vector3] = []
	if do_help.is_valid():
		more = do_help.call(helping, help_stage)
	if not more.is_empty():
		help_stage += 1
		help_path = more
		return
	var help := helping
	helping = ""
	helps_done.append(help)
	helped.emit(self, help)
	going_back = true
	help_path = way_back.call(help) if way_back.is_valid() else []


## Caught helping: the gang ties him to the chair at `at` (a world position, facing `yaw`). The help he was on is
## dropped (he tries it again once free) and any hostage he had by the hand is let go; the third time he gives up.
func tie(at: Vector3, yaw: float) -> void:
	tied = true
	ties += 1
	gave_up = ties >= TIES_TO_QUIT
	helping = ""
	help_stage = 0
	help_path.clear()
	going_back = false
	untying_by = null
	for hostage: Node3D in get_tree().get_nodes_in_group("bank_hostages"):
		if hostage.get("led_by") == self:
			hostage.let_go()
	global_position = at
	rotation.y = yaw
	_show_tied(true)
	say("ROBBER_SORRY_TIED")
	tied_up.emit(self)


## The vault is open and he wants no sack: no more helps, and he lets himself be cuffed from the front.
func wait_for_cops() -> void:
	gave_up = true
	surrendered = true
	helping = ""
	help_path.clear()
	say("ROBBER_SORRY_WAIT")


## E on him tied: `cop` starts untying him, staying close.
func start_untie(cop: Node3D) -> void:
	if untying_by == cop:
		return
	untying_by = cop
	untie_left = UNTIE_TIME
	say("ROBBER_SORRY_UNTYING")


## Tied: the cop untying him has to stay close UNTIE_TIME seconds; then he walks back to his spot (and on with his
## helps, unless he gave up).
func _untie(delta: float) -> void:
	if not untying_by:
		return
	if not is_instance_valid(untying_by) or global_position.distance_to(untying_by.global_position) > UNTIE_REACH:
		untying_by = null
		return
	untie_left -= delta
	if untie_left > 0.0:
		return
	tied = false
	untying_by = null
	_show_tied(false)
	say("ROBBER_SORRY_QUIT" if gave_up else "ROBBER_SORRY_FREE")
	going_back = true
	help_path = way_back.call("") if way_back.is_valid() else []
	untied.emit(self)


## Sitting on the chair with a rope round him, or up again.
func _show_tied(on: bool) -> void:
	_model.scale.y = SCALES[animal] * (TIED_CROUCH if on else 1.0)
	if on and not _rope:
		_rope = MeshInstance3D.new()
		_rope.name = "Rope"
		var ring := TorusMesh.new()
		ring.inner_radius = 0.48
		ring.outer_radius = 0.56
		var brown := StandardMaterial3D.new()
		brown.albedo_color = Color(0.62, 0.45, 0.25)
		ring.material = brown
		_rope.mesh = ring
		_rope.position.y = 0.75
		add_child(_rope)
	if _rope:
		_rope.visible = on


## A grandpa seeing a cop: off with the mask, into the cardigan's pocket (a bit sticks out), and to a free spot among
## the hostages.
func unmask() -> void:
	unmasked = true
	_show_mask(false)
	say("ROBBER_GRANDPA_UNMASK")
	if claim_spot.is_valid():
		hide_at = claim_spot.call(self)
	else:
		hide_at = global_position


func _show_mask(on: bool) -> void:
	var mask := _model.find_child("mask", true, false) as Node3D
	if mask:
		mask.visible = on
	var pocket := _model.find_child("pocket", true, false) as Node3D
	if pocket:
		pocket.visible = not on


## Unmasked: walking to his spot and sitting there like a hostage, or led by the hand and getting away once out.
func _pose(delta: float) -> void:
	if led_by:
		if is_out.is_valid() and is_out.call(global_position):
			slip_out()
			return
		var to := led_by.global_position - global_position
		to.y = 0.0
		_step(to.normalized() * LED_SPEED if to.length() > LED_KEEP_AWAY else Vector3.ZERO, delta)
		return
	if posing:
		return
	var to := hide_at - global_position
	to.y = 0.0
	if to.length() < HIDE_REACH:
		_sit()
		return
	_step(to.normalized() * HIDE_SPEED, delta)


func _step(wish: Vector3, delta: float) -> void:
	if wish.length() > 0.05:
		look_at(global_position + wish, Vector3.UP)
	velocity = Vector3(wish.x * wade, 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta, wish.z * wade)
	move_and_slide()


## Down on the floor facing the counter, like the hostages around him.
func _sit() -> void:
	posing = true
	rotation.y = 0.0
	_model.scale.y = SCALES[animal] * POSE_CROUCH


## Led out of the bank as a hostage, he's off down the street with what's in his pockets.
func slip_out() -> void:
	slipped = true
	led_by = null
	say("ROBBER_GRANDPA_BYE")
	hide()
	collision_layer = 0
	slipped_out.emit(self)


## The pig running along run_path; at its end he gets in the van and is gone until the getaway.
func _run(delta: float) -> void:
	var to := run_path[0] - global_position
	to.y = 0.0
	if to.length() < ARRIVED:
		run_path.remove_at(0)
		if run_path.is_empty():
			running = false
			if not into_van:
				return
			in_van = true
			hide()
			collision_layer = 0
			hid_in_van.emit(self)
		return
	look_at(global_position + to, Vector3.UP)
	velocity = to.normalized() * run_speed() * wade
	velocity.y = 0.0 if is_on_floor() else -GameScale.GRAVITY * delta
	move_and_slide()


func _turn_head(delta: float) -> void:
	var looks: Array = LOOKS[animal]
	_look_left -= delta
	if _look_left <= 0.0:
		_look_left = LOOK_HOLD
		_look_index = (_look_index + 1) % looks.size()
	look = move_toward(look, looks[_look_index], TURN_SPEED * delta)


func _eat(delta: float) -> void:
	if eating_left > 0.0:
		eating_left = maxf(eating_left - delta, 0.0)
		return
	_eat_left -= delta
	if _eat_left <= 0.0:
		_eat_left = EAT_EVERY
		eating_left = EAT_TIME
		say("ROBBER_CHANCHO_EAT")


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	if posing or led_by:
		# He passes for a hostage.
		return "PROMPT_LET_GO_HOSTAGE" if led_by == cop else "PROMPT_LEAD_HOSTAGE"
	if tied:
		return "PROMPT_UNTIE_SORRY"
	if sorry and not turned:
		return "PROMPT_TALK_SORRY"
	return "PROMPT_TALK_ROBBER"


## E on a robber: a line of their own, a different one each time; cuffed, the escort to the patrol car.
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	if led_by == cop:
		# Let go, he goes back to his spot.
		led_by = null
		posing = false
		_model.scale.y = SCALES[animal]
		return
	if posing:
		led_by = cop
		_model.scale.y = SCALES[animal]
		say("ROBBER_GRANDPA_KNEE_%d" % (_next_line % KNEE_LINES + 1))
		_next_line += 1
		return
	if tied:
		start_untie(cop)
		return
	if sorry and not turned:
		try_turn(cop)
		return
	if turned:
		say("ROBBER_SORRY_HELPING")
		return
	say("ROBBER_%s_%d" % [animal.to_upper(), _next_line % LINES + 1])
	_next_line += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


## What the escort calls (OwnerEscort): a line for `seconds`; robbers have no complaint meter.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key)
	_bubble_left = seconds


func _raise(_points: float) -> void:
	pass


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## What a guest's copy needs besides where they are and what they say (NpcSync): cuffed, gave up, running, in the van,
## gone with a sack, where their head points, the pig's sandwich, a grandpa, whether he took the mask off and sits
## among the hostages, the sorry robber's hanky up, whether he was turned and whether he's tied, and a vampire hiding
## behind his cape and his sunglasses.
func net_state() -> Array:
	return [is_cuffed(), surrendered, running, in_van, visible, snappedf(look, 0.01), eating_left > 0.0, unmasked,
		posing, sobbing_left > 0.0, turned, tied, is_hiding(), shades]


func apply_net_state(state: Variant) -> void:
	_cuffed_left = Handcuffs.SECONDS if state[0] else 0.0
	surrendered = state[1]
	running = state[2]
	in_van = state[3]
	if visible and not state[4]:
		hide()
		collision_layer = 0
	look = state[5]
	eating_left = EAT_TIME if state[6] else 0.0
	var sandwich := find_child("props", true, false) as Node3D
	if sandwich and running:
		sandwich.hide()
	if state.size() > 8:
		if state[7] and not unmasked:
			unmasked = true
			_show_mask(false)
		posing = state[8]
		_model.scale.y = SCALES[animal] * (POSE_CROUCH if posing else 1.0)
	if state.size() > 9:
		sobbing_left = SOB_TIME if state[9] else 0.0
		turned = state[10]
		if state[11] != tied:
			tied = state[11]
			_show_tied(tied)
		if _hanky:
			_hanky.position = HANKY_UP if is_sobbing() else HANKY_DOWN
	if state.size() > 13:
		hiding_left = HIDE_TIME if state[12] else 0.0
		shades = state[13]
		_show_hiding()


func _process(delta: float) -> void:
	if vampire:
		_show_hiding()
	# The escort turns them with their +Z ahead.
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and (escort.escorted_by or escort.in_car) else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
