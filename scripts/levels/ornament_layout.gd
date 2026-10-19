class_name OrnamentLayout
extends RefCounted

## Where the grandpa's ornaments stand (docs/diseno/allanamiento.md, "La casa del abuelo"): open shelf units against
## the walls, the dining table and the kitchen counter. Positions are fixed; which ornament goes where comes from the seed.

const KINDS := [
	preload("res://scenes/props/ornament_figurine.tscn"),
	preload("res://scenes/props/ornament_plate.tscn"),
	preload("res://scenes/props/ornament_vase.tscn"),
]
const HALF_HEIGHTS := [0.085, 0.011, 0.13]
const PLATE := 1

const SHELF_DEPTH := 0.35
const SHELF_BOARD := 0.03
const SHELF_LEVELS := [0.45, 0.95, 1.45]
const SHELF_HEIGHT := 1.6
const SPACING := 0.3

## Shelf units: floor center, the axis they run along and their width. Upstairs ones stand at y = 2.7.
const SHELVES := [
	{"at": Vector3(-9.0, 0, 3.25), "along": "x", "width": 2.0},  # living
	{"at": Vector3(-11.75, 0, 0.0), "along": "z", "width": 2.4},  # estudio
	{"at": Vector3(11.75, 0, 6.5), "along": "z", "width": 2.4},  # comedor
	{"at": Vector3(-1.25, 0, 3.5), "along": "z", "width": 2.0},  # entrada
	{"at": Vector3(1.75, 0, -1.5), "along": "z", "width": 2.0},  # cocina
	{"at": Vector3(-9.0, 2.7, 3.25), "along": "x", "width": 2.0},  # dormitorio chico
	{"at": Vector3(-9.0, 2.7, -2.75), "along": "x", "width": 2.0},  # cuarto de costura
	{"at": Vector3(4.0, 2.7, 3.25), "along": "x", "width": 2.0},  # dormitorio grande
	{"at": Vector3(6.75, 2.7, -2.75), "along": "x", "width": 2.0},  # cuarto de juegos
	{"at": Vector3(11.75, 2.7, -6.5), "along": "z", "width": 2.0},  # altillo
]
## Flat tops that get a row of ornaments: [first point, last point, count, only plates].
const TOPS := [
	[Vector3(6.2, 0.78, 6.25), Vector3(7.8, 0.78, 6.25), 6, true],  # comedor table
	[Vector3(6.2, 0.78, 6.75), Vector3(7.8, 0.78, 6.75), 6, true],
	[Vector3(6.0, 0.9, -2.6), Vector3(6.8, 0.9, -2.6), 3, false],  # kitchen counter
]


## Boards and side panels of a shelf unit, as [center, size] boxes.
static func shelf_boxes(unit: Dictionary) -> Array:
	var along_x: bool = unit.along == "x"
	var width: float = unit.width
	var at: Vector3 = unit.at
	var boxes := []
	for level: float in SHELF_LEVELS:
		var size := Vector3(width, SHELF_BOARD, SHELF_DEPTH) if along_x else Vector3(SHELF_DEPTH, SHELF_BOARD, width)
		boxes.append([at + Vector3(0, level - SHELF_BOARD / 2, 0), size])
	for side: float in [-1.0, 1.0]:
		var offset := Vector3(side * (width / 2 + 0.02), SHELF_HEIGHT / 2, 0) if along_x else Vector3(0, SHELF_HEIGHT / 2, side * (width / 2 + 0.02))
		var size := Vector3(0.04, SHELF_HEIGHT, SHELF_DEPTH) if along_x else Vector3(SHELF_DEPTH, SHELF_HEIGHT, 0.04)
		boxes.append([at + offset, size])
	return boxes


## Every ornament of the case: [{"kind": index in KINDS, "at": center position, "turn": rotation around y}], the same for the same seed.
static func places(case_seed: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed
	var result := []
	for unit: Dictionary in SHELVES:
		var along := Vector3.RIGHT if unit.along == "x" else Vector3.BACK
		var count := floori(unit.width / SPACING)
		for level: float in SHELF_LEVELS:
			for i in count:
				var offset: float = (i - (count - 1) / 2.0) * SPACING
				_add(result, rng, rng.randi_range(0, KINDS.size() - 1), unit.at + along * offset + Vector3.UP * level)
	for top: Array in TOPS:
		for i in top[2]:
			var kind := PLATE if top[3] else rng.randi_range(0, KINDS.size() - 1)
			_add(result, rng, kind, (top[0] as Vector3).lerp(top[1], i / maxf(top[2] - 1, 1)))
	return result


static func _add(result: Array, rng: RandomNumberGenerator, kind: int, surface: Vector3) -> void:
	result.append({"kind": kind, "at": surface + Vector3.UP * (HALF_HEIGHTS[kind] + 0.005), "turn": rng.randf() * TAU})
