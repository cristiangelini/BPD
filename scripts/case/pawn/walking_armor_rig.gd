class_name WalkingArmorRig
extends PawnRig

## The walking armor (allanamiento-empenos.md, "La armadura que camina"): someone robs houses dressed as a knight, and
## the armor costume with the loot inside (15 kg, the main evidence) is hidden in the shop with an oily rag and the map
## of the robbed houses. The shop's armor is somewhere else every time you look (every STEP_EVERY seconds it takes a
## step of STEP), there are oil streaks on the floor from it to the stock room, and looking at it closely is the
## story's clue. Every number here is (propuesta).

const STEP_EVERY := 20.0
const STEP := 1.0
## Its steps along the west wall, one after the other, over and over.
const STEPS: Array[float] = [-1.0, -1.0, 1.0, 1.0]
## The oil streaks: from the armor along the west wall, then along the stock room's wall to its door.
const STREAKS_FROM := Vector3(-9.0, PawnShop.FLOOR_TOP, 4.6)
const STREAKS_TURN := Vector3(-9.0, PawnShop.FLOOR_TOP, -3.9)
const STREAKS_TO := Vector3(PawnShop.STOCK_DOOR_X, PawnShop.FLOOR_TOP, -3.9)
const STREAK_EVERY := 0.7
const OIL := Color(0.16, 0.13, 0.08)

var look: ClueSpot
var steps := 0
var _step_left := STEP_EVERY


func setup(place: PawnShop) -> void:
	super.setup(place)
	look = ClueSpot.new()
	look.size = Vector3(0.9, 1.9, 0.9)
	look.prompt = "PROMPT_PAWN_ARMOR"
	look.text = tr("CLUE_WALKING_ARMOR")
	look.position = Vector3(0, 0.95, 0)
	look.read.connect(place.raid.add_clue)
	place.armor_parts[1].add_child(look)
	_streaks(STREAKS_FROM, STREAKS_TURN)
	_streaks(STREAKS_TURN, STREAKS_TO)


## One step more along STEPS.
func step() -> void:
	shop.move_armor(Vector3(0, 0, STEPS[steps % STEPS.size()] * STEP))
	steps += 1


## Dark dashes on the floor from `from` to `to` (shop space).
func _streaks(from: Vector3, to: Vector3) -> void:
	var count := int(from.distance_to(to) / STREAK_EVERY)
	var along := (to - from).normalized()
	var material := StandardMaterial3D.new()
	material.albedo_color = OIL
	material.roughness = 0.2
	for i in count:
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.08, 0.005, 0.35)
		mesh.mesh = box
		mesh.material_override = material
		mesh.position = from + along * (i + 0.5) * STREAK_EVERY + Vector3.UP * 0.004
		mesh.rotation.y = atan2(along.x, along.z)
		shop.add_child(mesh)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	_step_left -= delta
	if _step_left <= 0.0:
		_step_left = STEP_EVERY
		step()


func net_state() -> Variant:
	return steps


func apply_net_state(state: Variant) -> void:
	while state is int and steps < state:
		step()
