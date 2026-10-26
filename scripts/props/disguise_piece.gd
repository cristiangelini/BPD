class_name DisguisePiece
extends Grabbable

## A piece of disguise from the station's lockers (docs/diseno/infiltracion.md, step 1, decision 100): a wig, a
## mustache or glasses for the grandparents' club, and the choir robe (infiltracion-coro.md, step 2), which goes on
## brought to the chest instead of the face, and the cleaning crew's cap, face mask and vest (fuga-limpieza.md, step 3). The fire drill's orange prisoner's vest
## (fuga-simulacro.md) is worn the same way, but it's the opposite of a disguise: taken off it lies on the floor where
## the guard can see it (a clue), and the waiting room's coat and hat make a cop pass for one of the public. The fast trial's lawyer jacket (fuga-juicio.md) makes its wearer the
## cops' lawyer. Held, the mouse wheel brings it right up to the face; brought to its place on the cop's head it
## stays on, crooked by as much as it was off. Online the host sees it reach the head and tells everyone.
## Every number here is (propuesta).

## Where each kind sits on a cop, in the cop's own space (forward is -Z), and its model.
const SLOTS := {
	"wig": Vector3(0, 1.42, 0.0),
	"glasses": Vector3(0, 1.33, -0.21),
	"mustache": Vector3(0, 1.22, -0.2),
	"robe": Vector3(0, 0.95, -0.3),
	"cleaner_cap": Vector3(0, 1.42, 0.0),
	"face_mask": Vector3(0, 1.22, -0.2),
	"cleaner_vest": Vector3(0, 0.95, -0.3),
	"prison_vest": Vector3(0, 0.95, -0.3),
	"coat": Vector3(0, 0.95, -0.3),
	"hat": Vector3(0, 1.5, 0.0),
	"lawyer_jacket": Vector3(0, 0.95, -0.3),
}
const MODELS := {
	"wig": preload("res://assets/models/disguise_wig.glb"),
	"glasses": preload("res://assets/models/disguise_glasses.glb"),
	"mustache": preload("res://assets/models/disguise_mustache.glb"),
	"robe": preload("res://assets/models/disguise_robe.glb"),
	"cleaner_cap": preload("res://assets/models/disguise_cleaner_cap.glb"),
	"face_mask": preload("res://assets/models/disguise_face_mask.glb"),
	"cleaner_vest": preload("res://assets/models/disguise_cleaner_vest.glb"),
	"prison_vest": preload("res://assets/models/prison_vest.glb"),
	"coat": preload("res://assets/models/disguise_coat.glb"),
	"hat": preload("res://assets/models/disguise_hat.glb"),
	"lawyer_jacket": preload("res://assets/models/disguise_lawyer_jacket.glb"),
}
## Who the cops pass for, and with what: which pieces count and how many of them. (propuesta)
const LOOKS := {
	"grandparent": {"pieces": ["wig", "glasses", "mustache"], "needed": 2},
	"chorister": {"pieces": ["robe"], "needed": 1},
	"cleaner": {"pieces": ["cleaner_cap", "face_mask", "cleaner_vest"], "needed": 2},
	"public": {"pieces": ["coat", "hat"], "needed": 1},
	"lawyer": {"pieces": ["lawyer_jacket"], "needed": 1},
}
## Held this close to its place, it goes on (m).
const WEAR_REACH := 0.22
## How close to the eyes it can be held (the rest of the things stop at GameScale.HOLD_MIN).
const HOLD_CLOSE := 0.15
## The most crooked it can end up (radians), when it went on at the edge of WEAR_REACH.
const MAX_TILT := deg_to_rad(35.0)
## More crooked than this, it says so and falls off sooner.
const CROOKED := deg_to_rad(12.0)

@export var kind := "wig"
## On a hook of the coat rack (the host sets it): it stays up there until a cop grabs it.
var hanging := false


func _ready() -> void:
	if kind == "prison_vest":
		add_to_group("guard_clues")


## Hangs it on the coat rack at `hook` (the host): still, until someone grabs it.
func hang(hook: Transform3D) -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = hook
	hanging = true
	freeze = true


static func scene_of(piece_kind: String) -> PackedScene:
	return load("res://scenes/props/disguise_%s.tscn" % piece_kind)


## Where `piece_kind` goes on `cop`, in the world.
static func slot_on(cop: Cop, piece_kind: String) -> Vector3:
	return cop.global_transform * SLOTS[piece_kind]


## How crooked it would end up from where it is now (signed: left or right).
func tilt_on(cop: Cop) -> float:
	var off: Vector3 = cop.global_transform.affine_inverse() * global_position - SLOTS[kind]
	var side := -1.0 if off.x < 0.0 else 1.0
	return side * minf(off.length() / WEAR_REACH, 1.0) * MAX_TILT


## It doesn't bump into the cops holding it, so it can get to their face.
func hold(holder_id: int, point: Vector3) -> void:
	var grabber := instance_from_id(holder_id) as Node
	if not holders.has(holder_id) and grabber and grabber.get_parent() is Cop:
		add_collision_exception_with(grabber.get_parent())
	if hanging:
		hanging = false
		freeze = false
	super.hold(holder_id, point)


func let_go(holder_id: int) -> void:
	var grabber := instance_from_id(holder_id) as Node
	if grabber and grabber.get_parent() is Cop and is_instance_valid(grabber.get_parent()):
		remove_collision_exception_with(grabber.get_parent())
	super.let_go(holder_id)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if holders.size() != 1 or not multiplayer.is_server() or is_queued_for_deletion():
		return
	var cops := handling_cops(0.0)
	var cop: Cop = cops[0] if not cops.is_empty() else null
	if not cop or cop.disguise.has(kind) or global_position.distance_to(slot_on(cop, kind)) > WEAR_REACH:
		return
	var tilt := tilt_on(cop)
	cop.put_on_disguise(kind, tilt)
	cop.get_node("Grabber").release()
	if cop.sync and cop.sync.net.actions:
		cop.sync.net.actions.tell_guests(cop, "put_on_disguise", cop, [kind, tilt])
	if cop.sync and not cop.sync.is_multiplayer_authority():
		cop.sync.tell_held()
	cop.show_hint("HINT_DISGUISE_CROOKED" if absf(tilt) > CROOKED else "HINT_DISGUISE_ON", true)
	queue_free()
