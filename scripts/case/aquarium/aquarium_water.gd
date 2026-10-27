class_name AquariumWater
extends Node3D

## The wet floor of the aquarium (escena-acuario.md, "Bigotes"): Bigotes leaves a puddle every DRIP_STEP meters he
## waddles, and so does a wet cop (one who searched a small tank, for WET_SECONDS). Puddles dry in DRY_SECONDS. A cop
## who runs over one slips like on the bank's marbles (BankMarbles): falls forward for SLIP_TIME and lets go of what
## they hold, which is then on the floor for Bigotes. Walking or crouched, nothing happens. Every number here is
## (propuesta).

signal slipped(cop: Cop)

const RADIUS := 0.35
const DRIP_STEP := 1.2
const DRY_SECONDS := 45.0
const WET_SECONDS := 20.0
const MAX_PUDDLES := 40
const SLIP_TIME := 2.0
const RUN_OVER := GameScale.WALK_SPEED + 0.5
const SLIP_PUSH := 3.0
const SLIP_AGAIN := 3.0
const WATER := Color(0.55, 0.75, 0.95, 0.55)

var sea_lion: SeaLion
## The puddles, each a MeshInstance3D with its "left" seconds as meta, oldest first.
var puddles: Array[MeshInstance3D] = []
## Cop -> seconds they stay wet.
var wet_left := {}
## Who drips (Bigotes and wet cops) -> where they left their last puddle.
var _last_drop := {}
## Cop -> seconds until they can slip again.
var _again := {}
var _mesh: CylinderMesh
var _paint: StandardMaterial3D


func _ready() -> void:
	_mesh = CylinderMesh.new()
	_mesh.top_radius = RADIUS
	_mesh.bottom_radius = RADIUS
	_mesh.height = 0.004
	_mesh.radial_segments = 12
	_paint = StandardMaterial3D.new()
	_paint.albedo_color = WATER
	_paint.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_paint.metallic = 0.5
	_paint.roughness = 0.05


## A cop who put their arms in a tank: they drip for WET_SECONDS.
func soak(cop: Cop) -> void:
	if cop:
		wet_left[cop] = WET_SECONDS


func is_wet(cop: Cop) -> bool:
	return wet_left.has(cop)


## A puddle at `world` (on the floor under it).
func drop(world: Vector3) -> MeshInstance3D:
	var puddle := MeshInstance3D.new()
	puddle.mesh = _mesh
	puddle.material_override = _paint
	puddle.set_meta("left", DRY_SECONDS)
	add_child(puddle)
	puddle.global_position = Vector3(world.x, global_position.y + 0.004, world.z)
	puddles.append(puddle)
	if puddles.size() > MAX_PUDDLES:
		puddles.pop_front().queue_free()
	return puddle


## Whether `body` stands on a puddle.
func on_puddle(body: Node3D) -> bool:
	for puddle in puddles:
		var d := Vector2(body.global_position.x - puddle.global_position.x, body.global_position.z - puddle.global_position.z)
		if d.length() < RADIUS and absf(body.global_position.y - puddle.global_position.y) < 1.0:
			return true
	return false


func _physics_process(delta: float) -> void:
	for puddle in puddles.duplicate():
		puddle.set_meta("left", puddle.get_meta("left") - delta)
		if puddle.get_meta("left") <= 0.0:
			puddles.erase(puddle)
			puddle.queue_free()
	for cop: Variant in wet_left.keys():
		wet_left[cop] -= delta
		if not is_instance_valid(cop) or wet_left[cop] <= 0.0:
			wet_left.erase(cop)
			_last_drop.erase(cop)
	for seen: Variant in _again.keys():
		_again[seen] -= delta
		if not is_instance_valid(seen) or _again[seen] <= 0.0:
			_again.erase(seen)
	if sea_lion and sea_lion.waddling:
		_drip(sea_lion)
	for cop: Variant in wet_left.keys():
		_drip(cop)
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop or cop.vehicle or _again.has(cop) or cop.is_crouching:
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if flat.length() > RUN_OVER and on_puddle(cop):
			slip(cop, flat.normalized())


## A puddle under `body` each DRIP_STEP meters it moves.
func _drip(body: Node3D) -> void:
	var at := body.global_position
	if not _last_drop.has(body) or Vector2(at.x - _last_drop[body].x, at.z - _last_drop[body].z).length() >= DRIP_STEP:
		_last_drop[body] = at
		drop(at)


## `cop` slips heading `ahead`: pushed forward and down for SLIP_TIME, and what they held falls.
func slip(cop: Cop, ahead: Vector3) -> void:
	_again[cop] = SLIP_AGAIN
	var grabber := cop.get_node_or_null("Grabber") as Grabber
	if grabber:
		grabber.release()
	cop.knock_back(ahead * SLIP_PUSH, SLIP_TIME)
	cop.show_hint("HINT_AQUARIUM_SLIP")
	slipped.emit(cop)
