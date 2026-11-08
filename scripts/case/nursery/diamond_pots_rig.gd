class_name DiamondPotsRig
extends NurseryRig

## The pots with diamonds (allanamiento-vivero.md, "Las macetas con diamantes"): Doña Hortensia buried a jewel
## thief's diamonds in one of her pots. While the sprinklers run, that pot sparkles wherever it is, and a cop this
## close to it then notices, the story's own clue (on the checklist the first time). And every time the sprinklers
## come on, a few of the yard's pots go "clinc". Every number here is (propuesta).

const NOTICE_RANGE := 4.0
const CHECK_EVERY := 0.5
## The sparkles around the pot while the sprinklers run, and how fast they twinkle.
const SPARKLES := 5
const TWINKLE_SPEED := 9.0
const SPARKLE := Color(0.85, 0.97, 1.0)
## How many of the yard's pots go "clinc" each time, and for how long.
const CLINCS := 4
const CLINC_SECONDS := 2.0

var noticed := false
var clincs := 0
var sparkles: Array[MeshInstance3D] = []
var _since := 0.0
var _time := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: Nursery) -> void:
	super.setup(place)
	_rng.seed = nursery.case_seed
	var paint := StandardMaterial3D.new()
	paint.albedo_color = SPARKLE
	paint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in SPARKLES:
		var sparkle := MeshInstance3D.new()
		var star := PrismMesh.new()
		star.size = Vector3(0.08, 0.12, 0.02)
		sparkle.mesh = star
		sparkle.material_override = paint
		sparkle.hide()
		nursery.add_child(sparkle)
		sparkles.append(sparkle)
	nursery.irrigation.started.connect(clinc)


func is_sparkling() -> bool:
	return nursery.irrigation.is_running()


func _physics_process(delta: float) -> void:
	_time += delta
	var on := is_sparkling()
	for i in sparkles.size():
		var sparkle := sparkles[i]
		sparkle.visible = on and sin(_time * TWINKLE_SPEED + i * 1.7) > 0.0
		if sparkle.visible:
			var angle := i * TAU / sparkles.size() + _time
			sparkle.global_position = nursery.main.global_position + Vector3(cos(angle) * 0.35, 0.35 + (i % 2) * 0.2,
				sin(angle) * 0.35)
	_since += delta
	if noticed or not on or _since < CHECK_EVERY or not multiplayer.is_server():
		return
	_since = 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(nursery.main.global_position) <= NOTICE_RANGE:
			notice()
			break


## A cop sees the pot sparkle under the water: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	nursery.raid.add_clue(tr("CLUE_DIAMOND_SHINE"))
	nursery.raid.float_label(tr("NURSERY_SPARKLE"), nursery.main.global_position + Vector3.UP * 0.9, SPARKLE)


## The sprinklers came on: a few of the yard's pots go "clinc".
func clinc() -> void:
	var yard: Array[Node3D] = []
	for plant in nursery.flowers:
		if Nursery.in_yard(plant.position):
			yard.append(plant)
	for i in mini(CLINCS, yard.size()):
		var plant: Node3D = yard.pop_at(_rng.randi_range(0, yard.size() - 1))
		clincs += 1
		var label := Label3D.new()
		label.text = "NURSERY_CLINC"
		label.font_size = 40
		label.pixel_size = 0.008
		label.outline_size = 10
		label.modulate = SPARKLE
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position = plant.position + Vector3.UP * 0.9
		nursery.add_child(label)
		get_tree().create_timer(CLINC_SECONDS).timeout.connect(label.queue_free)


## Online the host sees the cops come close, and the guests' rig shows it when it says.
func net_state() -> Array:
	return [noticed]


func apply_net_state(state: Array) -> void:
	if state[0] and not noticed:
		notice()
