class_name PlazaRally
extends Node3D

## The politician's rally at the plaza (proteccion-politico.md, step 1, decision 103): the whole city with the
## station, the cops in the guard room and the patrol car at the door. On the plaza's north half, facing the fountain,
## a stage with a ramp, a lectern with its microphone, a banner and balloons: deputy Lustre waits there for his guard
## and gives his speech (PoliticianSpeech). --place=plaza opens it from Play. Every number here is (propuesta).

## The stage, from the plaza's middle: its middle, its size and the ramp up its front at the east end.
const STAGE_FROM_PLAZA := Vector3(0, 0, -14)
const STAGE_SIZE := Vector3(10, 1.0, 5)
const RAMP_X := 4.0
const RAMP_RUN := 2.8
const RAMP_WIDTH := 1.6
## The lectern near the stage's front, and the politician behind it facing the plaza (+Z).
const LECTERN_FROM_STAGE := Vector3(0, 0, 1.2)
const LECTERN_SIZE := Vector3(0.7, 0.85, 0.45)
const SPEAKER_BEHIND := 0.6
const BANNER_SIZE := Vector2(9, 1.6)
## The banner's middle over the boards, above the politician's bubble.
const BANNER_HEIGHT := 3.0
const BALLOON_COLORS: Array[Color] = [Color(0.9, 0.2, 0.25), Color(0.25, 0.45, 0.9), Color(0.95, 0.85, 0.2)]

const BOARDS := Color(0.55, 0.36, 0.2)
const SKIRT := Color(0.2, 0.3, 0.6)
const WOOD := Color(0.42, 0.26, 0.14)
const CLOTH := Color(0.95, 0.93, 0.88)
const METAL := Color(0.2, 0.2, 0.22)

## Same seed, same speech (and, later, the same hecklers). 0 draws one.
@export var case_seed := 0
var politician: Politician
var speech: PoliticianSpeech
## The stage's middle on its top, in world space.
var stage_top: Vector3
var _build: PlaceBuilder


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	_build = PlaceBuilder.new($Built)
	var stage := city.transform * (CityLayout.block_center(CityLayout.PLAZA) + STAGE_FROM_PLAZA)
	stage_top = stage + Vector3.UP * STAGE_SIZE.y
	_build_stage(stage)
	politician = Politician.new()
	politician.name = "Politician"
	add_child(politician)
	politician.global_position = stage_top + LECTERN_FROM_STAGE - Vector3(0, 0, SPEAKER_BEHIND)
	politician.rotation.y = PI
	speech = PoliticianSpeech.new()
	speech.name = "Speech"
	speech.setup(politician, case_seed)
	add_child(speech)


## Boards on a blue skirt, the ramp up the front, the lectern and its microphone, the banner on two poles at the back
## and a bunch of balloons at each front corner.
func _build_stage(stage: Vector3) -> void:
	var half := STAGE_SIZE / 2
	_build.box(stage + Vector3(0, STAGE_SIZE.y - 0.05, 0), Vector3(STAGE_SIZE.x, 0.1, STAGE_SIZE.z), BOARDS)
	_build.box(stage + Vector3(0, (STAGE_SIZE.y - 0.1) / 2, 0), Vector3(STAGE_SIZE.x - 0.1, STAGE_SIZE.y - 0.1,
		STAGE_SIZE.z - 0.1), SKIRT)
	var foot := stage + Vector3(RAMP_X, 0, half.z + RAMP_RUN)
	var ramp := _build.body(foot + Vector3(0, STAGE_SIZE.y / 2, -RAMP_RUN / 2))
	ramp.rotation.x = atan2(STAGE_SIZE.y, RAMP_RUN)
	var slope := Vector3(RAMP_WIDTH, 0.08, Vector2(RAMP_RUN, STAGE_SIZE.y).length())
	_build.shape(ramp, slope)
	_build.mesh(_box_mesh(slope), ramp.position, BOARDS, ramp.rotation)
	var top := stage + Vector3.UP * STAGE_SIZE.y
	var lectern := top + LECTERN_FROM_STAGE
	_build.box(lectern + Vector3(0, LECTERN_SIZE.y / 2, 0), LECTERN_SIZE, WOOD)
	_build.mesh_box(lectern + Vector3(0, LECTERN_SIZE.y * 0.6, LECTERN_SIZE.z / 2 + 0.01),
		Vector3(LECTERN_SIZE.x * 0.6, 0.3, 0.02), CLOTH)
	var mic := CylinderMesh.new()
	mic.top_radius = 0.012
	mic.bottom_radius = 0.012
	mic.height = 0.35
	_build.mesh(mic, lectern + Vector3(0, LECTERN_SIZE.y + 0.15, -0.05), METAL, Vector3(-0.5, 0, 0))
	var head := SphereMesh.new()
	head.radius = 0.04
	head.height = 0.08
	_build.mesh(head, lectern + Vector3(0, LECTERN_SIZE.y + 0.31, -0.14), METAL)
	var back := top + Vector3(0, 0, -half.z + 0.2)
	for x: float in [-BANNER_SIZE.x / 2, BANNER_SIZE.x / 2]:
		_build.box(back + Vector3(x, (BANNER_HEIGHT + 1.0) / 2, 0), Vector3(0.1, BANNER_HEIGHT + 1.0, 0.1), METAL)
	_build.mesh_box(back + Vector3(0, BANNER_HEIGHT, 0.06), Vector3(BANNER_SIZE.x, BANNER_SIZE.y, 0.04), CLOTH)
	var banner := Label3D.new()
	banner.text = "RALLY_BANNER"
	banner.font_size = 60
	banner.pixel_size = 0.01
	banner.outline_size = 0
	banner.modulate = SKIRT
	banner.position = back + Vector3(0, BANNER_HEIGHT, 0.1)
	$Built.add_child(banner)
	for side: float in [-1.0, 1.0]:
		var corner := top + Vector3(side * (half.x - 0.3), 0, half.z - 0.3)
		for i in BALLOON_COLORS.size():
			var balloon := SphereMesh.new()
			balloon.radius = 0.25
			balloon.height = 0.6
			var at := corner + Vector3((i - 1) * 0.35, 1.8 + 0.25 * (i % 2), 0)
			_build.mesh(balloon, at, BALLOON_COLORS[i])
			var string_top := at - Vector3(0, 0.3, 0)
			_build.mesh_box(Vector3(at.x, (string_top.y + corner.y) / 2, at.z), Vector3(0.01, string_top.y - corner.y, 0.01),
				CLOTH)


static func _box_mesh(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh
