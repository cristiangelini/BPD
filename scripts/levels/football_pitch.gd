class_name FootballPitch
extends Node3D

## The neighborhood's football pitch (politico-futbol.md, step 1, decision 179): block (4, 4), its front to +Z on the
## street, where Deputy Lustre plays his charity match against Los Veteranos del Barrio. A 7-a-side pitch, 44 x 28 m,
## runs along x with a goal at each end: grass in stripes, lime lines, the center circle and the penalty areas. North of
## it, a small stand of 3 steps for the neighbors; south, toward the street, each team's bench, the stretcher, the
## table with the cup, the sausage stall and the banner. The cops start in the station and drive here; --place=football
## opens it from Play. Step 2: the ball on the center spot (FootballBall) and the goals and scoreboard
## (FootballScore). Step 3: the match (FootballMatch), with Deputy Lustre playing badly (FootballLustre), the veterans,
## their keeper and his two advisors (FootballPlayer); the cops play in yellow bibs. Step 4: the deputy's falls, the
## stretcher (FootballStretcher) and the Tank. Every number here is (propuesta).

const GOAL_MODEL := preload("res://assets/models/football_goal.glb")
const BENCH_MODEL := preload("res://assets/models/team_bench.glb")
const CUP_MODEL := preload("res://assets/models/football_cup.glb")
## The pitch (CityLayout "football_pitch") fills its block inside the sidewalks.
const HALF := 27.0
## The field: its middle in the lot's space and its half length (x) and half width (z).
const CENTER := Vector3(0, 0, -2)
const HALF_LENGTH := 22.0
const HALF_WIDTH := 14.0
const LINE := 0.12
const CIRCLE := 5.0
## The penalty area: how deep into the field and how wide.
const AREA := Vector2(6.0, 14.0)
## The goal: wide, high and deep (behind the line), with its posts this thick.
const GOAL := Vector3(6.0, 2.0, 1.5)
const POST := 0.12
## The net's bodies are thick, out from where the net shows, so a hard shot doesn't go through them in one frame.
const NET := 0.4
## The stand north of the field: 3 steps, each this deep and high.
const STAND_STEPS := 3
const STEP := Vector2(1.4, 0.5)
const STAND_LENGTH := 24.0
## Along the south side: the benches (x of each), the stretcher, the cup's table and the sausage stall.
const BENCHES: Array[float] = [-8.0, 8.0]
const BENCH_Z := 14.5
const STRETCHER_AT := Vector3(-12.5, 0, 15.0)
const CUP_TABLE_AT := Vector3(0, 0, 15.5)
const CUP_TABLE := Vector3(1.6, 0.8, 0.8)
const STALL_AT := Vector3(17, 0, 19)
const STALL := Vector3(2.4, 2.2, 1.6)

const GRASS := Color(0.32, 0.62, 0.28)
const GRASS_DARK := Color(0.27, 0.55, 0.24)
const LIME := Color(0.96, 0.96, 0.92)
const CONCRETE := Color(0.7, 0.69, 0.66)
const SEAT := Color(0.2, 0.45, 0.8)
const TABLE := Color(0.95, 0.95, 0.95)
const CLOTH := Color(0.85, 0.15, 0.2)
const STALL_RED := Color(0.85, 0.25, 0.2)
const STALL_STRIPE := Color(0.97, 0.94, 0.85)
const WOOD := Color(0.45, 0.32, 0.22)

## The case's seed (who plays where, later steps).
var case_seed := 0
## The two goals, west then east; each scores for the team attacking it.
var goals: Array[Node3D] = []
## The match's ball and its goals and scoreboard (step 2).
var ball: FootballBall
var score: FootballScore
## The match, the deputy and how he plays (step 3).
var match_clock: FootballMatch
var politician: Politician
var lustre: FootballLustre
## The stretcher the deputy goes to his bench on (step 4).
var stretcher: FootballStretcher
var _build: PlaceBuilder

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_field()
	for side: float in [-1.0, 1.0]:
		_build_goal(side)
	_build_stand()
	_build_sideline()
	ball = FootballBall.new()
	ball.name = "Ball"
	add_child(ball)
	ball.position = CENTER + Vector3.UP * (FootballBall.RADIUS + 0.1)
	score = FootballScore.new()
	score.name = "Score"
	score.setup(self, ball)
	add_child(score)
	politician = Politician.new()
	politician.name = "Politician"
	add_child(politician)
	politician.position = CENTER + FootballLustre.HOME + Vector3.UP * 0.05
	politician.rotation.y = -PI / 2
	politician.get_node("Model").add_child(FootballPlayer.bib(FootballPlayer.BIBS[FootballScore.Team.LUSTRE]))
	lustre = FootballLustre.new()
	lustre.name = "Lustre"
	lustre.setup(self, politician, case_seed)
	add_child(lustre)
	match_clock = FootballMatch.new()
	match_clock.name = "Match"
	match_clock.setup(self, lustre)
	add_child(match_clock)
	match_clock.started.connect(give_bibs)
	city.transform = CityLayout.anchor("football_pitch")
	car.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)


## The goal line's middle at `side` (-1 west, 1 east), in the lot's space.
static func goal_at(side: float) -> Vector3:
	return CENTER + Vector3(side * HALF_LENGTH, 0, 0)


## A yellow bib on every cop that has none: they play on the deputy's team.
func give_bibs() -> void:
	for cop: Node in get_tree().get_nodes_in_group("cops"):
		if cop.has_node("Bib"):
			continue
		var vest := FootballPlayer.bib(FootballPlayer.BIBS[FootballScore.Team.LUSTRE])
		cop.add_child(vest)
		# This PC's own cop doesn't see their own bib from inside their head.
		if (cop as Cop).input_enabled:
			cop.call("_hide_from_own_camera", vest)


## Whether a world position is on the field, inside its lines.
func on_field(at: Vector3) -> bool:
	var local := to_local(at) - CENTER
	return absf(local.x) <= HALF_LENGTH and absf(local.z) <= HALF_WIDTH


## The grass in stripes across the field and the lime lines.
func _build_field() -> void:
	var stripes := 8
	var length := (HALF_LENGTH + 2.0) * 2
	for i in stripes:
		var x := -length / 2 + length * (i + 0.5) / stripes
		# Just over the city's grass (its top at 0.035).
		_build.mesh_box(CENTER + Vector3(x, 0.045, 0), Vector3(length / stripes, 0.02, (HALF_WIDTH + 2.0) * 2),
			GRASS if i % 2 == 0 else GRASS_DARK)
	var top := 0.07
	for side: float in [-1.0, 1.0]:
		_line(Vector3(0, top, side * HALF_WIDTH), Vector3(HALF_LENGTH * 2 + LINE, 0.01, LINE))
		_line(Vector3(side * HALF_LENGTH, top, 0), Vector3(LINE, 0.01, HALF_WIDTH * 2))
		var area_x := side * (HALF_LENGTH - AREA.x)
		_line(Vector3(area_x, top, 0), Vector3(LINE, 0.01, AREA.y))
		for edge: float in [-1.0, 1.0]:
			_line(Vector3(side * (HALF_LENGTH - AREA.x / 2), top, edge * AREA.y / 2), Vector3(AREA.x, 0.01, LINE))
		_line(Vector3(side * (HALF_LENGTH - 4.5), top, 0), Vector3(0.3, 0.01, 0.3))
	_line(Vector3(0, top, 0), Vector3(LINE, 0.01, HALF_WIDTH * 2))
	var ring := TorusMesh.new()
	ring.inner_radius = CIRCLE - LINE / 2
	ring.outer_radius = CIRCLE + LINE / 2
	ring.rings = 48
	ring.ring_segments = 4
	var circle := MeshInstance3D.new()
	circle.name = "CenterCircle"
	circle.mesh = ring
	circle.material_override = _build.material(LIME)
	circle.position = CENTER + Vector3(0, top, 0)
	circle.scale = Vector3(1, 0.05, 1)
	$Built.add_child(circle)
	_line(Vector3(0, top, 0), Vector3(0.35, 0.01, 0.35))


func _line(at: Vector3, size: Vector3) -> void:
	_build.mesh_box(CENTER + at, size, LIME)


## A goal at `side` (-1 west, 1 east): the model, and bodies for its posts, crossbar and net so a ball stops in it.
func _build_goal(side: float) -> void:
	var at := goal_at(side)
	var goal: Node3D = GOAL_MODEL.instantiate()
	goal.name = "Goal%d" % goals.size()
	goal.position = at
	# The model's net is at -Z: it points away from the field.
	goal.rotation.y = -side * PI / 2
	$Built.add_child(goal)
	goals.append(goal)
	var out := side * GOAL.z
	for edge: float in [-1.0, 1.0]:
		_body(at + Vector3(0, GOAL.y / 2, edge * GOAL.x / 2), Vector3(POST, GOAL.y, POST))
		_body(at + Vector3(out / 2, GOAL.y / 2, edge * (GOAL.x + NET) / 2), Vector3(GOAL.z, GOAL.y, NET))
	_body(at + Vector3(0, GOAL.y, 0), Vector3(POST, POST, GOAL.x + POST))
	_body(at + Vector3(out + side * NET / 2, GOAL.y / 2, 0), Vector3(NET, GOAL.y, GOAL.x + NET * 2))
	_body(at + Vector3(out / 2, GOAL.y + NET / 2, 0), Vector3(GOAL.z, NET, GOAL.x + NET * 2))


func _body(at: Vector3, size: Vector3) -> void:
	_build.shape(_build.body(at), size)


## The stand north of the field: concrete steps, a blue seat strip on each.
func _build_stand() -> void:
	var front := CENTER.z - HALF_WIDTH - 3.0
	for i in STAND_STEPS:
		var height := STEP.y * (i + 1)
		var z := front - STEP.x * (i + 0.5)
		_build.box(Vector3(CENTER.x, height / 2, z), Vector3(STAND_LENGTH, height, STEP.x), CONCRETE)
		_build.mesh_box(Vector3(CENTER.x, height + 0.03, z + STEP.x / 2 - 0.3), Vector3(STAND_LENGTH, 0.06, 0.5), SEAT)


## South of the field: the benches, the stretcher, the cup on its table, the sausage stall, the banner and the sign.
func _build_sideline() -> void:
	for x in BENCHES:
		var bench: Node3D = BENCH_MODEL.instantiate()
		bench.position = Vector3(x, 0, BENCH_Z)
		# The model faces +Z; the benches face the field.
		bench.rotation.y = PI
		$Built.add_child(bench)
		_body(Vector3(x, 0.45, BENCH_Z), Vector3(4.0, 0.9, 0.5))
	stretcher = FootballStretcher.new()
	stretcher.name = "Stretcher"
	stretcher.position = STRETCHER_AT + Vector3.UP * 0.05
	stretcher.rotation.y = PI / 2
	add_child(stretcher)
	_build.box(CUP_TABLE_AT + Vector3(0, CUP_TABLE.y / 2, 0), CUP_TABLE, TABLE)
	_build.mesh_box(CUP_TABLE_AT + Vector3(0, CUP_TABLE.y - 0.15, -CUP_TABLE.z / 2 - 0.01),
		Vector3(CUP_TABLE.x, 0.3, 0.02), CLOTH)
	var cup: Node3D = CUP_MODEL.instantiate()
	cup.name = "Cup"
	cup.position = CUP_TABLE_AT + Vector3(0, CUP_TABLE.y, 0)
	$Built.add_child(cup)
	_build.box(STALL_AT + Vector3(0, 0.5, 0), Vector3(STALL.x, 1.0, STALL.z), STALL_RED)
	for x: float in [-1.0, 1.0]:
		_build.box(STALL_AT + Vector3(x * (STALL.x / 2 - 0.05), STALL.y / 2, STALL.z / 2 - 0.05),
			Vector3(0.08, STALL.y, 0.08), WOOD)
	for i in 4:
		_build.mesh_box(STALL_AT + Vector3(-STALL.x / 2 + STALL.x * (i + 0.5) / 4, STALL.y, 0),
			Vector3(STALL.x / 4, 0.08, STALL.z + 0.4), STALL_RED if i % 2 == 0 else STALL_STRIPE)
	_label("FOOTBALL_STALL", STALL_AT + Vector3(0, 1.4, STALL.z / 2 + 0.05), 0.0, 40)
	# The banner reads from both sides, the cloth wide enough to hide the other side's letters.
	for x: float in [-1.0, 1.0]:
		_build.box(Vector3(x * 6.0, 1.6, HALF - 4.0), Vector3(0.12, 3.2, 0.12), WOOD)
	_build.mesh_box(Vector3(0, 2.7, HALF - 4.0), Vector3(12.0, 0.9, 0.06), CLOTH)
	_label("FOOTBALL_BANNER", Vector3(0, 2.7, HALF - 3.95), 0.0, 44)
	_label("FOOTBALL_BANNER", Vector3(0, 2.7, HALF - 4.05), PI, 44)
	for x: float in [-1.0, 1.0]:
		_build.box(Vector3(-14 + x * 1.6, 1.2, HALF - 1.5), Vector3(0.12, 2.4, 0.12), WOOD)
	_build.mesh_box(Vector3(-14, 2.1, HALF - 1.5), Vector3(3.6, 0.7, 0.08), STALL_STRIPE)
	_label("PLACE_FOOTBALL_PITCH", Vector3(-14, 2.1, HALF - 1.45), 0.0, 56)


func _label(key: String, at: Vector3, turn: float, size: int) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = 0.01
	label.outline_size = 12
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)
