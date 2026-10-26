class_name ChaseSuspect
extends CharacterBody3D

## The chase suspect once his vehicle is stopped (persecucion.md, "Cómo es el caso"): he gets out, gives up and
## stands by it complaining, until a cop cuffs him. Cuffed, the cops walk him to the patrol car like a raid's owner
## (OwnerEscort). What he says shows over his head.

const MODELS := {
	"ice_cream": preload("res://assets/models/npc_heladero.glb"),
	"moving_truck": preload("res://assets/models/npc_mudancero.glb"),
	"school_bus": preload("res://assets/models/npc_sospechoso.glb"),
	"rain": preload("res://assets/models/npc_sospechoso.glb"),
	"night": preload("res://assets/models/npc_sospechoso.glb"),
	"moto": preload("res://assets/models/npc_repartidor.glb"),
	"wheelchair": preload("res://assets/models/npc_abuelo.glb"),
	"highway": preload("res://assets/models/npc_sospechoso.glb"),
	"tow_truck": preload("res://assets/models/npc_mudancero.glb"),
	"golf_cart": preload("res://assets/models/npc_sospechoso.glb"),
	"golf_runner": preload("res://assets/models/npc_preso.glb"),
	# The raids' owners who got away (persecucion-final.md).
	"grandpa": preload("res://assets/models/npc_abuelo.glb"),
	"baker": preload("res://assets/models/npc_panadera.glb"),
	"groomer": preload("res://assets/models/npc_peluquero.glb"),
	"dangerous": preload("res://assets/models/npc_sospechoso.glb"),
	# The pastry contest's culprit, off his bike (escena-del-crimen.md).
	"cook": preload("res://assets/models/npc_pastelero.glb"),
	# The traffic control's wanted driver (control-transito.md).
	"driver": preload("res://assets/models/npc_cliente.glb"),
	# Doña Chela, off her motorized walker (infiltracion.md).
	"chela": preload("res://assets/models/npc_chela.glb"),
	# Maestro Ernesto, out of his getaway (infiltracion-coro.md).
	"ernesto": preload("res://assets/models/npc_ernesto.glb"),
	# Maestra Pausa, out of her getaway (infiltracion-mimos.md).
	"pausa": preload("res://assets/models/npc_pausa.glb"),
	# The Sargento Trucho, out of his getaway (infiltracion-fiesta.md).
	"trucho": preload("res://assets/models/npc_invitado.glb"),
	# El Toro, off his jog (infiltracion-gimnasio.md).
	"toro": preload("res://assets/models/npc_toro.glb"),
	# The Director of the thieves' school, out of his getaway (infiltracion-escuela.md).
	"director": preload("res://assets/models/npc_director.glb"),
	# The Chef Flambé, off his delivery scooter (infiltracion-restaurante.md).
	"flambe": preload("res://assets/models/npc_flambe.glb"),
	"alfil": preload("res://assets/models/npc_alfil.glb"),
	"cromado": preload("res://assets/models/npc_cromado.glb"),
	"martillo": preload("res://assets/models/npc_martillo.glb"),
	# El Oso, out of the robbers' van or off his run with the sack (robo-banco.md).
	"oso": preload("res://assets/models/npc_ladron_oso.glb"),
	# The grandpa Oso, off his motor walker (robo-banco-abuelos.md).
	"oso_grandpa": preload("res://assets/models/npc_abuelo_oso.glb"),
	# The bank's manager who was the boss, out of his car (robo-banco-gerente.md).
	"manager": preload("res://assets/models/npc_gerente.glb"),
	# The prison's last ringleader, off the food cart (carcel-motin.md).
	"ringleader": preload("res://assets/models/npc_preso.glb"),
	# An inmate off the transfer bus, with the ball and chain (traslado-presos.md).
	"transfer_inmate": preload("res://assets/models/npc_preso.glb"),
	# The market's spiteful vendor, off his vegetable trike (politico-mercado.md).
	"vendor": preload("res://assets/models/npc_puestero.glb"),
}
const HECKLER := "heckler_"
## The golf thief who runs off (persecucion-lugares.md): at this speed (m/s), away from cops this close, staying
## this far inside the club's fence and off its lakes. Cuffed, he stops; once the cuffs run out he runs again.
const RUN_SPEED := 5.0
const RUN_FROM := 30.0
const FENCE_KEEP := 3.0
## Seconds a line stays over his head, and between two complaints.
const LINE_SECONDS := 3.0
const COMPLAIN_EVERY := 5.0

## Which suspect he is (ChaseCase.SUSPECTS): his model and his lines.
var kind := "ice_cream"
## He runs off instead of giving up (the second golf thief).
var runs := false
## Cuffed at least once: caught, even if the cuffs ran out since.
var was_cuffed := false
## Seconds of cuffs left (OwnerEscort keeps them on while he's walked).
var _cuffed_left := 0.0
var _since_line := 0.0
var _line := 0
var _bubble: Label3D


func _ready() -> void:
	add_to_group("chase_suspect")
	collision_layer = 8
	collision_mask = 7
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	add_child(model_for(kind).instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position.y = 1.9
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	_say(lines()[0])


## Online (NpcSync): what a guest's copy needs before it's added.
func net_setup() -> Dictionary:
	return {"kind": kind, "runs": runs}


## The rally's heckler is "heckler_<look>" (proteccion-politico.md): their own neighbor's model, and the hecklers'
## lines.
static func model_for(who: String) -> PackedScene:
	if who.begins_with(HECKLER):
		return load("res://assets/models/npc_%s.glb" % who.trim_prefix(HECKLER))
	return MODELS[who]


## His complaints, as tr() keys.
func lines() -> Array[String]:
	var keys: Array[String] = []
	var who := "heckler" if kind.begins_with(HECKLER) else kind
	for i in 3:
		keys.append("CHASE_%s_LINE_%d" % [who.to_upper(), i + 1])
	return keys


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	var flee := _flee() if runs and not is_cuffed() else Vector3.ZERO
	velocity.x = flee.x
	velocity.z = flee.z
	if flee.length() > 0.1:
		look_at(global_position + flee, Vector3.UP, true)
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	_since_line += delta
	if _since_line >= COMPLAIN_EVERY:
		_line += 1
		_say(lines()[_line % lines().size()])


## Cuffed, E on him walks him to the patrol car (OwnerEscort); before that, nothing: cuff him first.
func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	return escort.prompt_key(cop) if escort and escort.handles_use() else ""


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)


## Where he runs: away from the nearest cop close by, along the fence when he reaches it, and around the lakes.
func _flee() -> Vector3:
	var nearest: Node3D = null
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if not nearest or cop.global_position.distance_to(global_position) < nearest.global_position.distance_to(global_position):
			nearest = cop
	if not nearest or nearest.global_position.distance_to(global_position) > RUN_FROM:
		return Vector3.ZERO
	var away := global_position - nearest.global_position
	away.y = 0.0
	var golf := get_tree().get_first_node_in_group("golf_club") as GolfClub
	if golf:
		var local := golf.to_local(global_position)
		var inner := GolfLayout.HALF - Vector2.ONE * FENCE_KEEP
		if absf(local.x) > inner.x and signf(away.x) == signf(local.x):
			away.x = 0.0
		if absf(local.z) > inner.y and signf(away.z) == signf(local.z):
			away.z = 0.0
		for lake: Array in GolfLayout.LAKES:
			var grown := [lake[0], float(lake[1]) + 3.0, float(lake[2]) + 3.0]
			if GolfLayout.in_ellipse(local, grown):
				var off: Vector3 = local - lake[0]
				away += golf.global_basis * Vector3(off.x, 0, off.z).normalized() * away.length()
		# Cornered with nowhere to go: along the fence, the way that leads away from the corner.
		if away.length() < 0.1:
			away = golf.global_basis * Vector3(-signf(local.x), 0, 0)
	return away.normalized() * RUN_SPEED


## The handcuffs (Handcuffs.cuffable): he stays cuffed this long.
func cuffed(seconds: float) -> void:
	was_cuffed = true
	_cuffed_left = maxf(_cuffed_left, seconds)
	_say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## OwnerEscort raises the owner's complaint when he's taken: this one has no meter.
func _raise(_points: float) -> void:
	pass


func _say(key: String, seconds := LINE_SECONDS) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == key:
			_bubble.hide())
