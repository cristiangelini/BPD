class_name TalentPlan
extends Node

## The prison's talent show (carcel-talentos.md, step 2): in the west half of the canteen, the stage against the back
## wall, the jury table with its 4 chairs in front of it and 3 benches with the 12 inmates sat watching; the host up
## on the stage. The seed draws the show: always the magician, the choir and the smoke dance (the ones hiding an
## escape, step 5) and 2 of the 5 acts without a trick, in its own order. Every number here is (propuesta).

const ACTS: Array[String] = ["magician", "choir", "smoke", "juggler", "ventriloquist", "plates", "spoons", "poet"]
## The acts that hide an escape (step 5); the others are only suspicious.
const TRICKS: Array[String] = ["magician", "choir", "smoke"]
const SHOW := 5
## Level space (x, z): the middle of the stage's front edge, the jury table and the benches.
const STAGE_AT := Vector2(-7.0, -4.5)
const JURY_AT := Vector2(-7.0, -3.4)
const JURY_SIZE := Vector3(3.6, 0.75, 0.7)
const CHAIR_XS: Array[float] = [-8.35, -7.45, -6.55, -5.65]
const CHAIR_BEHIND := 0.6
const BENCH_ZS: Array[float] = [-1.6, -0.2, 1.2]
const BENCH_SIZE := Vector3(5.2, 0.4, 0.35)
const SEAT_XS: Array[float] = [-8.8, -7.6, -6.4, -5.2]
const INMATES := 12
const WOOD := Color(0.45, 0.3, 0.18)
const CLOTH := Color(0.2, 0.35, 0.25)

var prison: PrisonLevel
var stage: TalentStage
var chairs: Array[JuryChair] = []
var inmates: Array[TalentInmate] = []
var host: TalentInmate
## The 5 acts of the show, in order.
var acts: Array[String] = []
## A guest's copy (step 7): the host's plan decides.
var follower := false
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["prison talent", case_seed])
	acts.assign(TRICKS)
	var others := ACTS.filter(func(act: String) -> bool: return not TRICKS.has(act))
	_shuffle(others)
	acts.append_array(others.slice(0, SHOW - TRICKS.size()))
	_shuffle(acts)
	stage = TalentStage.new()
	stage.name = "TalentStage"
	stage.position = _at(STAGE_AT)
	prison.add_child(stage)
	stage.set_curtain(false, true)
	var jury := StaticBody3D.new()
	jury.name = "JuryTable"
	jury.position = _at(JURY_AT)
	prison.add_child(jury)
	var top := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = JURY_SIZE
	top.shape = box
	top.position.y = JURY_SIZE.y / 2
	jury.add_child(top)
	jury.add_child(CopTool.piece(CopTool.box(JURY_SIZE), CLOTH, Vector3(0, JURY_SIZE.y / 2, 0)))
	for x in CHAIR_XS:
		var chair := JuryChair.new()
		chair.name = "JuryChair%d" % chairs.size()
		chair.position = _at(Vector2(x, JURY_AT.y + CHAIR_BEHIND))
		prison.add_child(chair)
		chairs.append(chair)
	for z in BENCH_ZS:
		var bench := StaticBody3D.new()
		bench.name = "Bench%d" % BENCH_ZS.find(z)
		bench.position = _at(Vector2(STAGE_AT.x, z))
		prison.add_child(bench)
		var seat := CollisionShape3D.new()
		var seat_box := BoxShape3D.new()
		seat_box.size = BENCH_SIZE
		seat.shape = seat_box
		seat.position.y = BENCH_SIZE.y / 2
		bench.add_child(seat)
		bench.add_child(CopTool.piece(CopTool.box(BENCH_SIZE), WOOD, Vector3(0, BENCH_SIZE.y / 2, 0)))
	for i in INMATES:
		var inmate := TalentInmate.new()
		inmate.name = "Inmate%d" % i
		inmate.seated = true
		add_child(inmate)
		# Just behind the bench's middle, so the body doesn't stand on it.
		var row := i / SEAT_XS.size()
		inmate.global_position = prison.global_transform * Vector3(SEAT_XS[i % SEAT_XS.size()],
			PrisonLevel.FLOOR_TOP, BENCH_ZS[row] + BENCH_SIZE.z / 2 + 0.05)
		inmate.face(stage.global_position)
		inmates.append(inmate)
	host = TalentInmate.new()
	host.name = "Host"
	host.role = TalentInmate.Role.HOST
	add_child(host)
	host.global_position = stage.spot(-1.8, 0.5)
	host.face(host.global_position + prison.global_basis.z)


## How many cops are sat at the jury table.
func jury_seated() -> int:
	return chairs.filter(func(chair: JuryChair) -> bool: return chair.sitter != null).size()


func _at(at: Vector2) -> Vector3:
	return Vector3(at.x, PrisonLevel.FLOOR_TOP, at.y)


func _shuffle(list: Array) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = list[i]
		list[i] = list[j]
		list[j] = swap
