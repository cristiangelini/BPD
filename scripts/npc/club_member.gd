class_name ClubMember
extends StaticBody3D

## A grandparent at the club's bingo tables (infiltracion.md, step 2b), or Doña Chela at the bingo stand; at the chapel
## (infiltracion-coro.md, step 3b) a chorister on the platform, or Maestro Ernesto, the director; at the theater
## (infiltracion-mimos.md, step 2b) a mime on the stage, or Maestra Pausa; at the costume party
## (infiltracion-fiesta.md, step 2b) a guest dressed as a cop, the Sargento Trucho hidden among them, or the señora
## Serpentina, the hostess; at the gym (infiltracion-gimnasio.md, step 2b) a member of the gang, or el Toro; at the
## thieves' school (infiltracion-escuela.md, step 2) a student, the Profesora Ganzúa or the Director; at the restaurant
## (infiltracion-restaurante.md, step 2) a cook, a waiter or the Chef Flambé; at the chess club (infiltracion-ajedrez.md,
## step 2) a member or the Gran Maestro Alfil; at the biker bar (infiltracion-motos.md, step 2) a biker or El Cromado.
## E on one tells a bit
## of gossip, a different line each time. Each one has a suspicion meter that ClubSuspicion fills from what they
## see (step 4), with a "?" or a "!" over their head. They don't move yet, so online every PC has the same ones; their
## meters come from the host through ClubSuspicion.

## A cop cuffed them (the handcuffs, on every PC).
signal cuffed_now(member: ClubMember)
## A cop talked to them (E), on that cop's PC.
signal talked(cop: Cop)

const MODELS := {
	"abuelo": preload("res://assets/models/npc_abuelo.glb"),
	"abuela": preload("res://assets/models/npc_abuela.glb"),
	"chela": preload("res://assets/models/npc_chela.glb"),
	"corista": preload("res://assets/models/npc_corista.glb"),
	"corista_b": preload("res://assets/models/npc_corista_b.glb"),
	"ernesto": preload("res://assets/models/npc_ernesto.glb"),
	"mimo": preload("res://assets/models/npc_mimo.glb"),
	"mimo_b": preload("res://assets/models/npc_mimo_b.glb"),
	"pausa": preload("res://assets/models/npc_pausa.glb"),
	"invitado": preload("res://assets/models/npc_invitado.glb"),
	"invitado_b": preload("res://assets/models/npc_invitado_b.glb"),
	"serpentina": preload("res://assets/models/npc_serpentina.glb"),
	"socio": preload("res://assets/models/npc_socio.glb"),
	"socio_b": preload("res://assets/models/npc_socio_b.glb"),
	"toro": preload("res://assets/models/npc_toro.glb"),
	"alumno": preload("res://assets/models/npc_alumno.glb"),
	"alumna": preload("res://assets/models/npc_alumna.glb"),
	"ganzua": preload("res://assets/models/npc_ganzua.glb"),
	"director": preload("res://assets/models/npc_director.glb"),
	"cocinero": preload("res://assets/models/npc_cocinero.glb"),
	"cocinera": preload("res://assets/models/npc_cocinera.glb"),
	"mozo": preload("res://assets/models/npc_mozo.glb"),
	"flambe": preload("res://assets/models/npc_flambe.glb"),
	"ajedrecista": preload("res://assets/models/npc_ajedrecista.glb"),
	"ajedrecista_b": preload("res://assets/models/npc_ajedrecista_b.glb"),
	"alfil": preload("res://assets/models/npc_alfil.glb"),
	"motoquero": preload("res://assets/models/npc_motoquero.glb"),
	"motoquera": preload("res://assets/models/npc_motoquera.glb"),
	"cromado": preload("res://assets/models/npc_cromado.glb"),
}
const SCALES := {"abuelo": 0.82, "abuela": 0.8, "chela": 0.85, "corista": 0.85, "corista_b": 0.85, "ernesto": 1.0,
	"mimo": 0.85, "mimo_b": 0.85, "pausa": 0.95, "invitado": 0.9, "invitado_b": 0.9, "serpentina": 0.9,
	"socio": 1.1, "socio_b": 1.1, "toro": 1.2,
	"alumno": 0.9, "alumna": 0.85, "ganzua": 0.9, "director": 1.0,
	"cocinero": 1.0, "cocinera": 0.9, "mozo": 0.9, "flambe": 1.1,
	"ajedrecista": 0.9, "ajedrecista_b": 0.85, "alfil": 1.05,
	"motoquero": 1.15, "motoquera": 0.95, "cromado": 1.3}
## What each look says when talked to (the key with the line's number, and how many lines), the prompt, and what it
## shouts when cuffed. The bosses (BOSSES) have their own lines.
const TALK := {
	"abuelo": ["CLUB_GOSSIP_%d", 12, "PROMPT_TALK_GRANDPARENT", "NPC_POLICE_ABUSE"],
	"abuela": ["CLUB_GOSSIP_%d", 12, "PROMPT_TALK_GRANDPARENT", "NPC_POLICE_ABUSE"],
	"chela": ["CHELA_%d", 4, "PROMPT_TALK_CHELA", "CHELA_CUFFED"],
	"corista": ["CHOIR_GOSSIP_%d", 10, "PROMPT_TALK_CHORISTER", "NPC_POLICE_ABUSE"],
	"corista_b": ["CHOIR_GOSSIP_%d", 10, "PROMPT_TALK_CHORISTER", "NPC_POLICE_ABUSE"],
	"ernesto": ["ERNESTO_%d", 4, "PROMPT_TALK_ERNESTO", "ERNESTO_CUFFED"],
	# The mimes only mime (infiltracion-mimos.md): their gossip is a gesture, and cuffed they mime the outrage.
	"mimo": ["MIME_GOSSIP_%d", 10, "PROMPT_TALK_MIME", "MIME_CUFFED"],
	"mimo_b": ["MIME_GOSSIP_%d", 10, "PROMPT_TALK_MIME", "MIME_CUFFED"],
	"pausa": ["PAUSA_%d", 4, "PROMPT_TALK_PAUSA", "PAUSA_CUFFED"],
	# The party's guests all talk alike, the boss too: nothing gives him away but his costume.
	"invitado": ["PARTY_GOSSIP_%d", 10, "PROMPT_TALK_GUEST", "PARTY_CUFFED"],
	"invitado_b": ["PARTY_GOSSIP_%d", 10, "PROMPT_TALK_GUEST", "PARTY_CUFFED"],
	"serpentina": ["SERPENTINA_%d", 4, "PROMPT_TALK_SERPENTINA", "SERPENTINA_CUFFED"],
	"socio": ["GYM_GOSSIP_%d", 10, "PROMPT_TALK_GYM", "GYM_CUFFED"],
	"socio_b": ["GYM_GOSSIP_%d", 10, "PROMPT_TALK_GYM", "GYM_CUFFED"],
	"toro": ["TORO_%d", 4, "PROMPT_TALK_TORO", "TORO_CUFFED"],
	"alumno": ["SCHOOL_GOSSIP_%d", 10, "PROMPT_TALK_STUDENT", "SCHOOL_CUFFED"],
	"alumna": ["SCHOOL_GOSSIP_%d", 10, "PROMPT_TALK_STUDENT", "SCHOOL_CUFFED"],
	"ganzua": ["GANZUA_%d", 4, "PROMPT_TALK_GANZUA", "GANZUA_CUFFED"],
	"director": ["DIRECTOR_%d", 4, "PROMPT_TALK_DIRECTOR", "DIRECTOR_CUFFED"],
	"cocinero": ["RESTAURANT_GOSSIP_%d", 10, "PROMPT_TALK_COOK", "RESTAURANT_CUFFED"],
	"cocinera": ["RESTAURANT_GOSSIP_%d", 10, "PROMPT_TALK_COOK", "RESTAURANT_CUFFED"],
	"mozo": ["RESTAURANT_GOSSIP_%d", 10, "PROMPT_TALK_WAITER", "RESTAURANT_CUFFED"],
	"flambe": ["FLAMBE_%d", 4, "PROMPT_TALK_FLAMBE", "FLAMBE_CUFFED"],
	"ajedrecista": ["CHESS_GOSSIP_%d", 10, "PROMPT_TALK_CHESS", "CHESS_CUFFED"],
	"ajedrecista_b": ["CHESS_GOSSIP_%d", 10, "PROMPT_TALK_CHESS", "CHESS_CUFFED"],
	"alfil": ["ALFIL_%d", 4, "PROMPT_TALK_ALFIL", "ALFIL_CUFFED"],
	"motoquero": ["BIKER_GOSSIP_%d", 10, "PROMPT_TALK_BIKER", "BIKER_CUFFED"],
	"motoquera": ["BIKER_GOSSIP_%d", 10, "PROMPT_TALK_BIKER", "BIKER_CUFFED"],
	"cromado": ["CROMADO_%d", 4, "PROMPT_TALK_CROMADO", "CROMADO_CUFFED"],
}
const BOSSES: Array[String] = ["chela", "ernesto", "pausa", "toro", "director", "flambe", "alfil", "cromado"]
const GOSSIP_LINES := 12
const SAY_TIME := 4.0
## What a grandparent sees: a wide cone in front of them (they turn their heads) and not far, at their eyes' height.
const SIGHT_ANGLE := deg_to_rad(140.0)
const SIGHT_RANGE := 9.0
const EYE_HEIGHT := 1.15
## Over these, a "?" and then a "!" over their head.
const DOUBT := 50.0
const ALARM := 80.0

@export var look := "abuela"
## The costume bits worn over the model (the party's guests, PartyTraits), and whether this guest is the boss in
## disguise (the Sargento Trucho looks like any other guest). Set before it's added.
var accessories: Array[PackedScene] = []
var secret_boss := false
## Which gossip line comes next (a different start for each, from the seed).
var next_line := 0
## 0 to 100: at 100 they shout that the cops are cops (ClubSuspicion).
var suspicion := 0.0
## The cone they see in: narrower while the mimes hold a statue (MimeRehearsal).
var sight_angle := SIGHT_ANGLE
## Busy talking business with a neighbor (the recording, ClubEvidence): they notice nothing.
var distracted := false
var _bubble: Label3D
var _bubble_left := 0.0
var _mark: Label3D
var _cuffed_left := 0.0


func _ready() -> void:
	add_to_group("club_members")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODELS[look].instantiate()
	model.scale = Vector3.ONE * SCALES[look]
	# The models face +Z; the member faces -Z like everyone else.
	model.rotation.y = PI
	add_child(model)
	for accessory: PackedScene in accessories:
		model.add_child(accessory.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	_mark = Label3D.new()
	_mark.name = "Mark"
	_mark.position = Vector3(0, 1.6, 0)
	_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_mark.pixel_size = 0.006
	_mark.font_size = 64
	_mark.outline_size = 12
	_mark.hide()
	add_child(_mark)


func is_chela() -> bool:
	return look == "chela"


## The one to cuff: Doña Chela at the club, Maestro Ernesto at the chapel, Maestra Pausa at the theater, the Sargento
## Trucho at the party, el Toro at the gym, the Director at the thieves' school, the Chef Flambé at the restaurant, the
## Gran Maestro Alfil at the chess club, El Cromado at the biker bar.
func is_boss() -> bool:
	return BOSSES.has(look) or secret_boss


func set_suspicion(value: float) -> void:
	suspicion = value
	_mark.visible = suspicion >= DOUBT
	_mark.text = "!" if suspicion >= ALARM else "?"
	_mark.modulate = Color(1, 0.25, 0.2) if suspicion >= ALARM else Color(1, 0.85, 0.3)


## Whether they see `cop`'s chest: in their cone, near enough and with no wall in between.
func sees_cop(cop: Cop) -> bool:
	if distracted:
		return false
	var eye := global_position + Vector3.UP * EYE_HEIGHT
	var at := cop.global_position + Vector3.UP
	var flat := Vector3(at.x - eye.x, 0, at.z - eye.z)
	if flat.length() > SIGHT_RANGE or flat.length() < 0.01:
		return false
	if (-global_basis.z).angle_to(flat.normalized()) > sight_angle / 2:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	return hit.is_empty() or hit.collider == cop


## The handcuffs: stays put, complains, and the case hears it (InfiltrationCase).
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	say(TALK[look][3])
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func prompt_key(_cop: Cop) -> String:
	return TALK[look][2]


func use(cop: Cop) -> void:
	say(TALK[look][0] % (next_line % TALK[look][1]))
	next_line += 1
	talked.emit(cop)


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
