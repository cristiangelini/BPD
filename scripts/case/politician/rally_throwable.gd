class_name RallyThrowable
extends Grabbable

## An egg or a tomato a heckler throws at deputy Lustre (proteccion-politico.md, step 2, decision 103). It flies on a
## high arc that can be seen coming (launch) and bursts on the first thing it hits: on the politician it's a stain on
## his suit (Politician.stain); on a cop who got in the way, a stain on the cop instead (step 3); anywhere else it
## leaves a splat that dries away. It's a Grabbable, so a cop can catch one in the air (step 3: Grabber.try_grab helps
## with what flies near the hands) and throw it again. Every number here is (propuesta).

signal caught(throwable: RallyThrowable, cop: Cop)

signal burst(throwable: RallyThrowable, on: Node)

const MODELS := {"egg": preload("res://assets/models/rally_egg.glb"),
	"tomato": preload("res://assets/models/rally_tomato.glb")}
const SPLATS := {"egg": preload("res://assets/models/splat_egg.glb"),
	"tomato": preload("res://assets/models/splat_tomato.glb")}
const KG := {"egg": 0.06, "tomato": 0.1}
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
	else:
		_splat()
	burst.emit(self, body)
	queue_free()


## A cop took it for the politician: a stain on their uniform for a while, and it counts for the award.
func _stain_cop(cop: Cop) -> void:
	cop.stats["rally_blocks"] = cop.stats.get("rally_blocks", 0) + 1
	cop.show_hint("HINT_RALLY_BLOCKED")
	var mark: Node3D = SPLATS[kind].instantiate()
	mark.name = "RallyStain"
	cop.add_child(mark)
	var out := cop.to_local(global_position)
	out.y = 0.0
	out = out.normalized() if out.length() > 0.01 else Vector3.FORWARD
	mark.position = Vector3(0, clampf(cop.to_local(global_position).y, 0.4, 1.4), 0) + out * 0.4
	mark.basis = Basis(Quaternion(Vector3.UP, out)).scaled(Vector3.ONE * Politician.STAIN_SCALE)
	get_tree().create_timer(SPLAT_TIME).timeout.connect(mark.queue_free)


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


## A flat splat lying where it burst, facing up, that goes after SPLAT_TIME.
func _splat() -> void:
	var splat: Node3D = SPLATS[kind].instantiate()
	splat.name = "Splat"
	get_parent().add_child(splat)
	splat.global_position = global_position - Vector3(0, RADIUS * 0.8, 0)
	splat.rotation.y = randf() * TAU
	get_tree().create_timer(SPLAT_TIME).timeout.connect(splat.queue_free)


func _physics_process(delta: float) -> void:
	super(delta)
	if is_held():
		_life = LIFETIME
	_life -= delta
	if _life <= 0.0:
		queue_free()
