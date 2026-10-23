class_name RallyThrowable
extends Grabbable

## An egg or a tomato a heckler throws at deputy Lustre (proteccion-politico.md, step 2, decision 103). It flies on a
## high arc that can be seen coming (launch) and bursts on the first thing it hits: on the politician it's a stain on
## his suit (Politician.stain); anywhere else it leaves a splat that dries away. It's a Grabbable, so a cop can catch
## one in the air (step 3). Every number here is (propuesta).

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
	else:
		_splat()
	burst.emit(self, body)
	queue_free()


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
	_life -= delta
	if _life <= 0.0 and not is_held():
		queue_free()
