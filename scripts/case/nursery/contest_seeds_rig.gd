class_name ContestSeedsRig
extends NurseryRig

## The contest seeds (allanamiento-vivero.md, "Las semillas del concurso"): Doña Hortensia took the champion tomato's
## seeds from the giant vegetable contest. In the greenhouse grows a tomato plant with ball-sized tomatoes, and a cop
## this close to it notices, the story's own clue (on the checklist the first time). And after every watering a giant
## pumpkin grows at the west end of the yard and rolls across it (at most PUMPKINS at a time). Every number here is
## (propuesta).

const TOMATO_MODEL := preload("res://assets/models/giant_tomato_plant.glb")
const NOTICE_RANGE := 2.0
const CHECK_EVERY := 0.5
## The tomato plant on the greenhouse floor, past the east end of the south tables, a little bigger than its model.
const TOMATO_AT := Vector3(13.5, Nursery.FLOOR_TOP, -2.4)
## Where the pumpkins grow and how they roll off.
const PUMPKIN_AT := Vector3(-18.0, Nursery.FLOOR_TOP + 0.5, 5.6)
const PUMPKIN_KG := GiantPumpkin.KG
const PUMPKIN_RADIUS := GiantPumpkin.RADIUS
const ROLL_SPEED := 3.0
const PUMPKINS := 3

var tomato: Node3D
var noticed := false
var pumpkins: Array[Grabbable] = []
var grown := 0
var _was_running := false
var _since := 0.0


func setup(place: Nursery) -> void:
	super.setup(place)
	tomato = TOMATO_MODEL.instantiate()
	tomato.name = "GiantTomato"
	tomato.position = TOMATO_AT
	tomato.scale = Vector3.ONE * 1.4
	nursery.add_child(tomato)


func _physics_process(delta: float) -> void:
	var running := nursery.irrigation.is_running()
	# Online the host grows them, and the guests get copies (GiantPumpkin).
	if _was_running and not running and multiplayer.is_server():
		grow_pumpkin()
	_was_running = running
	_since += delta
	if noticed or _since < CHECK_EVERY or not multiplayer.is_server():
		return
	_since = 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var off := cop.global_position - tomato.global_position
		off.y = 0.0
		if off.length() <= NOTICE_RANGE:
			notice()
			break


## A cop sees the ball-sized tomatoes: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	nursery.raid.add_clue(tr("CLUE_GIANT_TOMATOES"))
	nursery.raid.float_label(tr("NURSERY_TOMATOES"), tomato.global_position + Vector3.UP * 1.2, Color(1, 0.35, 0.25))


## A giant pumpkin grows at the west end of the yard and rolls off across it.
func grow_pumpkin() -> void:
	grown += 1
	if pumpkins.size() >= PUMPKINS:
		pumpkins.pop_front().queue_free()
	var pumpkin := GiantPumpkin.new()
	pumpkin.name = "Pumpkin%d" % grown
	nursery.add_child(pumpkin)
	pumpkin.position = PUMPKIN_AT
	pumpkin.linear_velocity = Vector3(ROLL_SPEED, 0, 0)
	pumpkin.angular_velocity = Vector3(0, 0, -ROLL_SPEED / PUMPKIN_RADIUS)
	pumpkins.append(pumpkin)


## Online the host sees the cops come close, and the guests' rig shows it when it says.
func net_state() -> Array:
	return [noticed]


func apply_net_state(state: Array) -> void:
	if state[0] and not noticed:
		notice()
