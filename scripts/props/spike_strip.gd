class_name SpikeStrip
extends Grabbable

## The patrol car's spike strip (control-carrera.md, "Cómo es", step 4): rolled up, it's carried like the flashlight.
## Dropped or thrown on the street, once it lies still it unrolls across the lane, LENGTH m long (the checkpoint's X).
## A car rolling over it gets its tires punctured (QueueCar.puncture), once. E on its rope rolls it back up in
## ROLL_SECONDS, to let a city car by. Every number here is (propuesta).

const ROLL := preload("res://assets/models/spike_roll.glb")
const STRIP := preload("res://assets/models/spike_strip.glb")
const KG := 4.0
const ROLL_SIZE := Vector3(0.5, 0.45, 0.4)
const LENGTH := 4.5
const STRIP_SIZE := Vector3(LENGTH + 0.4, 0.12, 0.4)
## It unrolls once it lies this still, this low.
const STILL := 0.3
const LOW := 0.4
const ROLL_SECONDS := 1.0
## A car's wheels are over it with its center this far across (past its end) and along.
const CATCH := Vector2(LENGTH / 2 + 0.9, QueueCar.LENGTH / 2)

## Unrolled across the lane, catching cars.
var deployed := false
## Seconds left rolling it up, 0 when it isn't.
var rolling_left := 0.0
## A cop carried it since it was last rolled up (or ever): only then does it unroll where it lands.
var carried := false
## The checkpoint it lines up with: across its lane.
var checkpoint: TrafficCheckpoint
var _shape: CollisionShape3D
var _model: Node3D


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	_shape = CollisionShape3D.new()
	_shape.shape = BoxShape3D.new()
	add_child(_shape)
	_set_look(false)


func _ready() -> void:
	add_to_group("spike_strips")


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SPIKES_PULL" if deployed and rolling_left <= 0.0 else "PROMPT_GRAB"


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_SPIKES_DROP"


## E on its rope rolls it back up (deployed only).
func use(_cop: Cop) -> void:
	if deployed and rolling_left <= 0.0:
		rolling_left = ROLL_SECONDS


## Unrolls where it lies, across `checkpoint`'s lane (or its own X without one), flat on the ground.
func deploy() -> void:
	deployed = true
	carried = false
	freeze = true
	var across := checkpoint.global_basis.x if checkpoint else global_basis.x
	across.y = 0
	across = across.normalized()
	global_transform = Transform3D(Basis(across, Vector3.UP, across.cross(Vector3.UP)),
		Vector3(global_position.x, checkpoint.global_position.y if checkpoint else 0.0, global_position.z))
	_set_look(true)


func roll_up() -> void:
	deployed = false
	carried = false
	rolling_left = 0.0
	_set_look(false)
	freeze = false


func _physics_process(delta: float) -> void:
	super(delta)
	if rolling_left > 0.0:
		rolling_left -= delta
		if rolling_left <= 0.0:
			roll_up()
		return
	if deployed:
		_catch_cars()
		return
	if is_held():
		carried = true
		return
	var ground := checkpoint.global_position.y if checkpoint else 0.0
	if carried and linear_velocity.length() < STILL and global_position.y - ground < LOW:
		deploy()


func _catch_cars() -> void:
	for car: QueueCar in get_tree().get_nodes_in_group("queue_cars"):
		if not car.can_puncture():
			continue
		var at := to_local(car.global_position)
		if absf(at.x) < CATCH.x and absf(at.z) < CATCH.y:
			car.puncture()


func _set_look(unrolled: bool) -> void:
	if _model:
		_model.queue_free()
	_model = (STRIP if unrolled else ROLL).instantiate()
	add_child(_model)
	var size := STRIP_SIZE if unrolled else ROLL_SIZE
	(_shape.shape as BoxShape3D).size = size
	_shape.position = Vector3(0, size.y / 2, 0)
