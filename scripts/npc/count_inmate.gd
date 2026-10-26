class_name CountInmate
extends YardInmate

## One of the people out in the yard at the prison's count (carcel-recuento.md, step 3): an inmate with his `number`
## (or the cook or the plumber, `number` 0). E on him (ActionSync runs it on every PC; CountPlan, on the host,
## decides) chalks a yellow cross on his back (`marked`). Step 4: a `cheater`, chalked, every RUB_EVERY seconds walks to
## the nearest wall and rubs his back on it for RUB_TIME seconds ("¡Pica!"): the cross is gone (`rubbed_off`). Every
## number here is (propuesta).

signal chalked(inmate: CountInmate, cop: Cop)
signal rubbed_off(inmate: CountInmate)

## The cross on the back: two bars this long, this high up.
const CROSS_SIZE := Vector3(0.36, 0.06, 0.02)
const CROSS_HEIGHT := 0.75
const CROSS_OUT := 0.42
const CHALK := Color(1.0, 0.92, 0.25)
const RUB_EVERY := 40.0
const RUB_TIME := 2.5
## He stands this far from the wall to rub on it, and sways this much doing it.
const WALL_GAP := 0.6
const RUB_SWAY := 0.2
const RUB_SPEED := 14.0

## 0 for the cook and the plumber, who aren't on the list.
var number := 0
var marked := false
var cheater := false
var rub_left := RUB_EVERY
var rubbing := 0.0
var _to_wall := false
var _wall := Vector2.ZERO
var _wall_side := Vector2.ZERO
var _cross: Node3D


func _ready() -> void:
	super()
	_cross = Node3D.new()
	_cross.name = "Cross"
	_cross.position = Vector3(0, CROSS_HEIGHT, -CROSS_OUT)
	for turn in [PI / 4, -PI / 4]:
		var bar := CopTool.piece(CopTool.box(CROSS_SIZE), CHALK, Vector3.ZERO, Vector3(0, 0, turn))
		# Chalk shows even in the shade.
		(bar.mesh.material as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_cross.add_child(bar)
	_cross.hide()
	add_child(_cross)


func is_worker() -> bool:
	return number == 0


func prompt_key(_cop: Cop) -> String:
	return "" if marked else "PROMPT_COUNT_CHALK"


func use(cop: Cop) -> void:
	if not marked:
		chalked.emit(self, cop)


## The cross on (or wiped off).
func set_marked(on: bool) -> void:
	marked = on
	_cross.visible = on


func _physics_process(delta: float) -> void:
	super(delta)
	if follower or not cheater or not busy:
		return
	if rubbing > 0.0:
		rubbing -= delta
		_model.rotation.z = sin(rubbing * RUB_SPEED) * RUB_SWAY
		if rubbing <= 0.0:
			_rubbed()
	elif marked and not _to_wall:
		rub_left -= delta
		if rub_left <= 0.0:
			rub_now()


## Off to the nearest wall to rub the cross off his back.
func rub_now() -> void:
	var local := prison.global_transform.affine_inverse() * global_position
	var at := Vector2(local.x, local.z)
	var x := PrisonLevel.HALF_X - PrisonLevel.FENCE_THICK - WALL_GAP
	# Where to stand, and which way the wall is from there.
	var walls := [[Vector2(-x, at.y), Vector2.LEFT], [Vector2(x, at.y), Vector2.RIGHT],
		[Vector2(at.x, PrisonLevel.BUILDING_FRONT + WALL_GAP), Vector2.UP]]
	var best: Array = walls[0]
	for wall: Array in walls:
		if (wall[0] as Vector2).distance_to(at) < (best[0] as Vector2).distance_to(at):
			best = wall
	_wall = best[0]
	_wall_side = best[1]
	_to_wall = true
	walk([_wall])


func _arrive() -> void:
	if not _to_wall:
		super()
		return
	_to_wall = false
	route.clear()
	_next = 0
	# His back to the wall.
	var away := _wall - _wall_side
	_face(prison.global_transform * Vector3(away.x, PrisonLevel.FLOOR_TOP, away.y))
	rubbing = RUB_TIME
	say("COUNT_ITCHY", RUB_TIME)


func _rubbed() -> void:
	_model.rotation.z = 0.0
	rub_left = RUB_EVERY
	rubbed_off.emit(self)
	_wander()
