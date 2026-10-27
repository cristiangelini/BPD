class_name StolenAquariumRig
extends ApartmentsRig

## The stolen aquarium (edificio.md, "El acuario robado"): the city aquarium's giant tank with the contest goldfish
## stands in 30B's locked study. It is 2 m long, so it doesn't fit in the elevator: it goes down on the scaffold, among
## four. The story's clue: puddles of water from the elevator to 30B's door, on the checklist once a cop looks at
## one. A hard hit makes the goldfish jump out (once). Every number here is (propuesta).

signal fish_jumped(fish: RigidBody3D)

const TANK_SCENE := preload("res://scenes/props/stolen_aquarium.tscn")
const TANK_HALF_HEIGHT := 0.5
## In the study, along the window, clear of the desk, on the parquet.
const TANK_AT := Vector3(9.0, ApartmentTower.TOP_Y + 0.02, 1.8)
## The puddles' trail from the elevator to 30B's door and into the living room.
const PUDDLES: Array[Vector3] = [
	Vector3(0.3, ApartmentTower.TOP_Y, -3.0), Vector3(1.1, ApartmentTower.TOP_Y, -2.5),
	Vector3(1.8, ApartmentTower.TOP_Y, -2.0), Vector3(2.2, ApartmentTower.TOP_Y, -0.6),
	Vector3(3.4, ApartmentTower.TOP_Y, 0.4),
]
const WATER := Color(0.35, 0.6, 0.9, 0.7)
const FISH := Color(0.95, 0.6, 0.15)

var tank: Evidence
var puddles: Array[ClueSpot] = []
var fish: RigidBody3D


func setup(place: ApartmentTower) -> void:
	super.setup(place)
	tank = TANK_SCENE.instantiate()
	tank.position = TANK_AT + Vector3.UP * (TANK_HALF_HEIGHT + 0.01)
	place.add_child(tank)
	place.main = tank
	tank.damaged.connect(func(_loss: float) -> void: jump())
	var material := StandardMaterial3D.new()
	material.albedo_color = WATER
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for at: Vector3 in PUDDLES:
		var puddle := ClueSpot.new()
		puddle.size = Vector3(0.7, 0.03, 0.5)
		puddle.prompt = "PROMPT_PUDDLE"
		puddle.text = "CLUE_PUDDLES"
		puddle.position = at + Vector3.UP * 0.02
		var look := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.35
		mesh.bottom_radius = 0.35
		mesh.height = 0.01
		mesh.material = material
		look.mesh = mesh
		look.scale = Vector3(1.0, 1.0, 0.7)
		puddle.add_child(look)
		place.add_child(puddle)
		# Every puddle tells the same: the checklist keeps it once.
		puddle.read.connect(func(text: String) -> void: tower.raid.add_clue(tr(text)))
		puddles.append(puddle)


## A hard hit: the goldfish out, flapping (only the first time).
func jump() -> void:
	if fish:
		return
	fish = RigidBody3D.new()
	fish.mass = 0.3
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.06
	capsule.height = 0.25
	shape.shape = capsule
	shape.rotation.z = PI / 2
	fish.add_child(shape)
	var look := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.06
	mesh.height = 0.25
	var material := StandardMaterial3D.new()
	material.albedo_color = FISH
	mesh.material = material
	look.mesh = mesh
	look.rotation.z = PI / 2
	fish.add_child(look)
	tower.add_child(fish)
	fish.global_position = tank.global_position + Vector3.UP * 0.7
	fish.linear_velocity = Vector3(1.0, 3.5, 0.6)
	fish.angular_velocity = Vector3(0, 0, 8.0)
	fish_jumped.emit(fish)
