class_name CarrierPigeonsRig
extends ApartmentsRig

## The messenger pigeons (edificio.md, "Las palomas mensajeras"): Mr. Bellini's loft of trained pigeons stands on 30B's
## balcony. Every ARRIVE_EVERY a pigeon flies in from over the street to its landing board, and the first ones bring
## the pearl necklace on a leg until a cop takes it (E on the pigeon while it waits). A cop running near the loft
## scares it off, necklace and all, until the next one. The pigeons only come while the loft is on the balcony. The
## story's clue: feathers and birdseed from the elevator to 30B (on the checklist once). Every number here is
## (propuesta).

const LOFT_SCENE := preload("res://scenes/props/pigeon_loft.tscn")
const NECKLACE_SCENE := preload("res://scenes/props/pearl_necklace.tscn")
const LOFT_HALF_HEIGHT := 0.4
## On the balcony, west of the door, facing the street.
const LOFT_AT := Vector3(-1.5, ApartmentTower.TOP_Y + 0.02, ApartmentTower.HALF_Z + 0.8)
const ARRIVE_EVERY := 30.0
## Where a pigeon comes from: this far out over the street and up from the board.
const FAR := Vector3(0.0, 6.0, 25.0)
## The landing board, in the loft's space.
const BOARD := Vector3(0.0, -0.19, 0.4)
## A cop faster than this within SCARE_RADIUS is noise.
const NOISE_SPEED := GameScale.WALK_SPEED + 0.5
const SCARE_RADIUS := 4.0
## Feathers and birdseed: in the elevator's car (its space) and along the hallway to 30B's door.
const IN_CAR := Vector3(-0.4, 0.0, 0.3)
const TRAIL: Array[Vector3] = [
	Vector3(0.6, ApartmentTower.TOP_Y, -3.0), Vector3(1.6, ApartmentTower.TOP_Y, -2.2),
	Vector3(2.3, ApartmentTower.TOP_Y, -0.8),
]
const SEED := Color(0.85, 0.7, 0.4)
const FEATHER := Color(0.92, 0.92, 0.95)

var loft: Evidence
var necklace: Evidence
var pigeon: MessengerPigeon
var trail: Array[ClueSpot] = []
var arrivals := 0
var _next := ARRIVE_EVERY
var _necklace_layer := 0


func setup(place: ApartmentTower) -> void:
	super.setup(place)
	loft = LOFT_SCENE.instantiate()
	loft.position = LOFT_AT + Vector3.UP * (LOFT_HALF_HEIGHT + 0.01)
	place.add_child(loft)
	place.main = loft
	# The necklace counts from the start, but it's on a pigeon's leg until a cop takes it.
	necklace = NECKLACE_SCENE.instantiate()
	place.add_child(necklace)
	place.extras.append(necklace)
	_necklace_layer = necklace.collision_layer
	necklace.collision_layer = 0
	necklace.freeze = true
	necklace.visible = false
	necklace.position = LOFT_AT
	pigeon = MessengerPigeon.new()
	place.add_child(pigeon)
	pigeon.gave.connect(_drop_necklace)
	pigeon.landed.connect(func() -> void: arrivals += 1)
	var spots: Array[Vector3] = [IN_CAR]
	spots.append_array(TRAIL)
	for i in spots.size():
		var spot := ClueSpot.new()
		spot.size = Vector3(0.5, 0.03, 0.5)
		spot.prompt = "PROMPT_FEATHERS"
		spot.text = "CLUE_FEATHERS"
		spot.position = spots[i] + Vector3.UP * 0.02
		_scatter(spot, i)
		if i == 0:
			place.elevator.add_child(spot)
		else:
			place.add_child(spot)
		spot.read.connect(func(text: String) -> void: tower.raid.add_clue(tr(text)))
		trail.append(spot)


## The loft is still out on the balcony (where the pigeons know to come).
func loft_on_balcony() -> bool:
	var at := tower.to_local(loft.global_position)
	return ApartmentTower.on_top_floor(at) and at.z > ApartmentTower.HALF_Z


## A pigeon flies in now, with the necklace if no cop has taken it yet.
func send_pigeon() -> void:
	if pigeon.state != MessengerPigeon.State.AWAY or not loft_on_balcony():
		return
	pigeon.arrive(loft.to_global(BOARD) + FAR, loft, BOARD, not necklace.visible)


## Whether a cop is running near the pigeon on the board.
func hears_noise() -> bool:
	for cop: Cop in tower.get_tree().get_nodes_in_group("cops"):
		var flat := Vector2(cop.velocity.x, cop.velocity.z)
		if flat.length() > NOISE_SPEED and cop.global_position.distance_to(pigeon.global_position) < SCARE_RADIUS:
			return true
	return false


func _physics_process(delta: float) -> void:
	_next -= delta
	if _next <= 0.0:
		_next = ARRIVE_EVERY
		send_pigeon()
	if pigeon.state == MessengerPigeon.State.LANDED and hears_noise():
		pigeon.leave()


## The pigeon lets the necklace go on the board.
func _drop_necklace() -> void:
	necklace.global_position = pigeon.global_position + Vector3.UP * 0.05
	necklace.collision_layer = _necklace_layer
	necklace.visible = true
	necklace.freeze = false


## A few feathers and a sprinkle of birdseed on the floor.
func _scatter(spot: Node3D, salt: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = salt * 31 + 7
	var seed_material := StandardMaterial3D.new()
	seed_material.albedo_color = SEED
	var feather_material := StandardMaterial3D.new()
	feather_material.albedo_color = FEATHER
	for i in 6:
		var bit := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		var feather := i < 2
		mesh.size = Vector3(0.2, 0.004, 0.05) if feather else Vector3(0.06, 0.004, 0.06)
		mesh.material = feather_material if feather else seed_material
		bit.mesh = mesh
		bit.position = Vector3(rng.randf_range(-0.2, 0.2), 0.0, rng.randf_range(-0.2, 0.2))
		bit.rotation.y = rng.randf() * TAU
		spot.add_child(bit)
