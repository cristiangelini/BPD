class_name StreetNailsRig
extends HardwareRig

## The nails on the street (ferreteria.md, "Clavos en la calle"): Tobías scatters nails on the street so cars get flat
## tires at his cousin's tire shop, who pays him a commission. The bucket of nails is the main evidence. A patch of
## nails covers the street in front of the store, right where the patrol car parks: driven over, a tire goes flat and
## the car runs at half speed (PatrolCar.FLAT_SHARE) until the giant magnet, one of the extras, comes near it and pulls
## the nail out. The magnet also picks up the nails it passes over. The story's own clue: loose nails on the sidewalk
## across the street. Every number here is (propuesta).

const NAILS_SCENE := preload("res://scenes/props/loose_nails.tscn")
const NAILS_MODEL := preload("res://assets/models/loose_nails.glb")
## The patch: clusters of nails on a grid over the near lane in front of the store (the front is at z = HALF_Z, then
## the sidewalk, then the street).
const PATCH_FROM := Vector2(-4.0, 11.5)
const PATCH_TO := Vector2(4.0, 14.5)
const CLUSTER_STEP := 1.0
## A car whose middle passes this close to a cluster gets a flat; the magnet picks up clusters this close.
const HIT_RADIUS := 1.2
const MAGNET_REACH := 1.0
## The magnet this close to a flat car pulls the nail out of the tire.
const FIX_REACH := 2.5
const MOVING := 0.5
## The nails on the sidewalk across the street, the story's clue.
const CLUE_AT := Vector3(1.5, 0.03, 23.5)

## The nail clusters still on the street.
var clusters: Array[Node3D] = []
var magnet: Evidence
var clue_nails: ClueNote


func setup(place: HardwareStore) -> void:
	super.setup(place)
	magnet = place.extras[1]
	var x := PATCH_FROM.x
	while x <= PATCH_TO.x + 0.01:
		var z := PATCH_FROM.y
		while z <= PATCH_TO.y + 0.01:
			var cluster: Node3D = NAILS_MODEL.instantiate()
			cluster.position = Vector3(x, 0.025, z)
			cluster.rotation.y = (x * 3.0 + z * 7.0)
			place.add_child(cluster)
			clusters.append(cluster)
			z += CLUSTER_STEP
		x += CLUSTER_STEP
	clue_nails = NAILS_SCENE.instantiate()
	clue_nails.text = tr("CLUE_STREET_NAILS")
	clue_nails.position = CLUE_AT
	place.add_child(clue_nails)
	clue_nails.read.connect(place.raid.add_clue)


func _physics_process(_delta: float) -> void:
	var car := store.car
	if not car.flat and car.linear_velocity.length() > MOVING and _near_cluster(car.global_position, HIT_RADIUS):
		puncture()
	if not is_instance_valid(magnet):
		return
	for cluster in clusters.duplicate():
		if _flat_distance(cluster.global_position, magnet.global_position) < MAGNET_REACH:
			clusters.erase(cluster)
			cluster.queue_free()
	if car.flat and _flat_distance(car.global_position, magnet.global_position) < FIX_REACH:
		car.flat = false
		_tell_riders("HINT_TIRE_FIXED")


## The patrol car's tire goes flat.
func puncture() -> void:
	store.car.flat = true
	_tell_riders("HINT_FLAT_TIRE")


func _near_cluster(at: Vector3, radius: float) -> bool:
	return clusters.any(func(cluster: Node3D) -> bool: return _flat_distance(cluster.global_position, at) < radius)


func _tell_riders(key: String) -> void:
	for cop: Cop in store.car.seated:
		if cop:
			cop.show_hint(key)


static func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
