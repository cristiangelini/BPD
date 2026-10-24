class_name RallyThrowable
extends Grabbable

## An egg or a tomato a heckler throws at deputy Lustre (proteccion-politico.md, step 2, decision 103). It flies on a
## high arc that can be seen coming (launch) and bursts on the first thing it hits: on the politician it's a stain on
## his suit (Politician.stain); on a cop who got in the way, a stain on the cop instead (step 3); anywhere else it
## leaves a splat that dries away. It's a Grabbable, so a cop can catch one in the air (step 3: Grabber.try_grab helps
## with what flies near the hands) and throw it again. Online only the host's burst (PropSync copies it from its
## script, net_setup); PoliticianCase tells the guests where, for the splats and the cops' stains. Every number here
## is (propuesta). The prison riot's inmates throw food the same way (carcel-motin.md, step 2b): on a cop it counts
## toward slipping, and what has hit_by_food (an inmate, a tray) takes it its own way.

signal caught(throwable: RallyThrowable, cop: Cop)

signal burst(throwable: RallyThrowable, on: Node)

## The prison riot's food flies the same way (carcel-motin.md, step 2b): mash, jelly, chicken and yogurt.
const MODELS := {"egg": preload("res://assets/models/rally_egg.glb"),
	"tomato": preload("res://assets/models/rally_tomato.glb"), "mash": preload("res://assets/models/prison_mash.glb"),
	"jelly": preload("res://assets/models/prison_jelly.glb"), "chicken": preload("res://assets/models/prison_chicken.glb"),
	"yogurt": preload("res://assets/models/prison_yogurt.glb")}
const SPLATS := {"egg": preload("res://assets/models/splat_egg.glb"),
	"tomato": preload("res://assets/models/splat_tomato.glb"), "mash": preload("res://assets/models/splat_mash.glb"),
	"jelly": preload("res://assets/models/splat_jelly.glb"), "chicken": preload("res://assets/models/prison_chicken.glb"),
	"yogurt": preload("res://assets/models/splat_yogurt.glb")}
const KG := {"egg": 0.06, "tomato": 0.1, "mash": 0.15, "jelly": 0.05, "chicken": 0.12, "yogurt": 0.13}
const RALLY_KINDS: Array[String] = ["egg", "tomato"]
## Twice their real size, so they can be seen coming from across the plaza.
const LOOK_SCALE := 2.0
const RADIUS := 0.035 * LOOK_SCALE
## Gone if it never hits anything, and how long a splat stays.
const LIFETIME := 8.0
const SPLAT_TIME := 20.0

@export var kind := "tomato"
var flying := false
var _life := LIFETIME


func _ready() -> void:
	add_to_group("rally_throwables")
	add_to_group("catchables")
	collision_layer = 4
	collision_mask = 1 | 2 | 8
	mass = KG[kind]
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = RADIUS
	shape.shape = sphere
	add_child(shape)
	var model: Node3D = MODELS[kind].instantiate()
	model.scale = Vector3.ONE * LOOK_SCALE
	add_child(model)
	body_entered.connect(_on_body_entered)


## Off it goes from `from`, landing on `to` after `seconds`: the velocity of that arc under gravity.
func launch(from: Vector3, to: Vector3, seconds: float) -> void:
	global_position = from
	var gravity := Vector3.DOWN * GameScale.GRAVITY * gravity_scale
	linear_velocity = (to - from) / seconds - gravity * seconds / 2
	angular_velocity = Vector3(randf_range(-8, 8), randf_range(-8, 8), randf_range(-8, 8))
	flying = true


func _on_body_entered(body: Node) -> void:
	if is_queued_for_deletion() or is_held():
		return
	burst_on(body)


## It bursts on `body`: a stain if it's the politician, a splat where it is otherwise.
func burst_on(body: Node) -> void:
	if is_queued_for_deletion():
		return
	if body is Politician:
		(body as Politician).stain(kind, global_position)
	elif body is Cop:
		_stain_cop(body as Cop)
	elif body.has_method("hit_by_food"):
		body.hit_by_food(self)
	else:
		_splat()
	burst.emit(self, body)
	queue_free()


## Online (PropSync): what a guest's copy needs before it's added.
func net_setup() -> Dictionary:
	return {"kind": kind}


## A cop took it for the politician: a stain on their uniform for a while, and it counts for the award.
## In the prison, food on a cop counts toward slipping instead (step 3).
func _stain_cop(cop: Cop) -> void:
	var stat := "rally_blocks" if kind in RALLY_KINDS else "food_hits"
	cop.stats[stat] = cop.stats.get(stat, 0) + 1
	stain_cop(cop, kind, global_position)


## The stain on `cop` where a `kind` burst at `at` (world space), for SPLAT_TIME, and the hint for their player.
static func stain_cop(cop: Cop, kind: String, at: Vector3) -> void:
	cop.show_hint("HINT_RALLY_BLOCKED" if kind in RALLY_KINDS else "HINT_FOOD_HIT")
	stain_on(cop, kind, at)


## A stain of `kind` on `body` (a cop, an inmate) where it burst at `at` (world space), for SPLAT_TIME.
static func stain_on(body: Node3D, kind: String, at: Vector3) -> void:
	var mark: Node3D = SPLATS[kind].instantiate()
	mark.name = "RallyStain"
	mark.add_to_group("food_stains")
	body.add_child(mark)
	var out := body.to_local(at)
	out.y = 0.0
	out = out.normalized() if out.length() > 0.01 else Vector3.FORWARD
	mark.position = Vector3(0, clampf(body.to_local(at).y, 0.4, 1.4), 0) + out * 0.4
	mark.basis = Basis(Quaternion(Vector3.UP, out)).scaled(Vector3.ONE * Politician.STAIN_SCALE)
	body.get_tree().create_timer(SPLAT_TIME).timeout.connect(mark.queue_free)


## Grabbed out of the air: it stops flying (and bursting) until it's thrown again.
func hold(holder_id: int, point: Vector3) -> void:
	var first := not is_held()
	super(holder_id, point)
	if first and flying:
		flying = false
		_life = LIFETIME
		var grabber := instance_from_id(holder_id) as Grabber
		var cop := grabber.get_parent() as Cop if grabber else null
		if cop:
			cop.stats["rally_catches"] = cop.stats.get("rally_catches", 0) + 1
			cop.show_hint("HINT_RALLY_CAUGHT")
		caught.emit(self, cop)


func _splat() -> void:
	splat_at(get_parent(), kind, global_position)


## A flat splat of `kind` under `parent`, lying where it burst at `at` (world space), facing up, that goes after
## SPLAT_TIME.
static func splat_at(parent: Node, kind: String, at: Vector3) -> void:
	var splat: Node3D = SPLATS[kind].instantiate()
	splat.name = "Splat"
	parent.add_child(splat)
	splat.global_position = at - Vector3(0, RADIUS * 0.8, 0)
	splat.rotation.y = randf() * TAU
	parent.get_tree().create_timer(SPLAT_TIME).timeout.connect(splat.queue_free)


func _physics_process(delta: float) -> void:
	super(delta)
	if is_held():
		_life = LIFETIME
	_life -= delta
	if _life <= 0.0:
		queue_free()
