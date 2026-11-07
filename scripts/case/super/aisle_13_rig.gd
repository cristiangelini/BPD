extends SupermarketRig

## Aisle 13 (allanamiento-super.md, "El pasillo 13"): Don Ofertón sells "Crece Pelo al Instante" in an aisle that isn't
## on the plan. At the back of aisle 4 a short gondola stands against the storeroom's wall, over a doorway; cops running
## into it for long enough (two at a time, half the time) slide it aside, and the first time is the clue. Behind it is
## aisle 13, narrow, with its sign, a shelf of bottles and the box of tonic, the main evidence. The sample bottles and the
## fake mustache are hidden. Every number here is (propuesta).

const GONDOLA_MODEL := preload("res://assets/models/gondola.glb")
const BOTTLE_MODEL := preload("res://assets/models/super_tonic_bottle.glb")
const BOX_SCENE := preload("res://scenes/props/super_tonic_box.tscn")
## The gondola over the doorway (Supermarket.AISLE_13_DOOR_Z, in the storeroom's west wall), how much it slides and in
## how long, and how many seconds of a running cop push it needs.
const GONDOLA_AT := Vector3(Supermarket.STORE_X - 0.4, Supermarket.FLOOR_TOP, Supermarket.AISLE_13_DOOR_Z)
const GONDOLA_SIZE := Vector3(0.6, 2.16, 3.0)
const SLIDE := 2.2
const SLIDE_TIME := 1.0
const PUSH_NEEDED := 1.5
## Aisle 13 itself: from the storeroom's west wall to AISLE_EAST_X, and from AISLE_NORTH_Z to the storeroom's front.
const AISLE_EAST_X := 9.3
const AISLE_NORTH_Z := -9.0
const SHELF_AT := Vector3(9.05, Supermarket.FLOOR_TOP, -7.0)
const SHELF_SIZE := Vector3(0.4, 1.2, 3.0)
const BOX_AT := Vector3(8.65, Supermarket.FLOOR_TOP, -8.3)

var gondola: AnimatableBody3D
var opened := false
var pushed := 0.0
var _push_zone: Area3D


func setup(place: Supermarket) -> void:
	super.setup(place)
	_build_aisle()
	gondola = AnimatableBody3D.new()
	gondola.name = "Aisle13Gondola"
	gondola.sync_to_physics = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = GONDOLA_SIZE
	shape.shape = box
	shape.position.y = GONDOLA_SIZE.y / 2
	gondola.add_child(shape)
	var look: Node3D = GONDOLA_MODEL.instantiate()
	look.scale = Vector3(0.5, 1.2, 1.0)
	gondola.add_child(look)
	store.add_child(gondola)
	gondola.position = GONDOLA_AT
	_push_zone = Area3D.new()
	_push_zone.collision_layer = 0
	_push_zone.collision_mask = 2
	var zone := CollisionShape3D.new()
	var zone_box := BoxShape3D.new()
	zone_box.size = Vector3(0.8, 1.6, GONDOLA_SIZE.z)
	zone.shape = zone_box
	_push_zone.add_child(zone)
	gondola.add_child(_push_zone)
	_push_zone.position = Vector3(-GONDOLA_SIZE.x / 2 - 0.4, 0.8, 0)
	store.main = BOX_SCENE.instantiate()
	store.add_child(store.main)
	store.main.position = BOX_AT + Vector3.UP * 0.165


## The narrow aisle behind the doorway: its two walls, its sign and its shelf of tonic bottles.
func _build_aisle() -> void:
	var wall := Supermarket.OUTSIDE.lightened(0.1)
	store._build.wall_at("z", AISLE_EAST_X, AISLE_NORTH_Z, Supermarket.STORE_Z, 0.0, Supermarket.WALL_TOP, [], wall)
	store._build.wall_at("x", AISLE_NORTH_Z, Supermarket.STORE_X, AISLE_EAST_X, 0.0, Supermarket.WALL_TOP, [], wall)
	store._solid(SHELF_AT + Vector3(0, SHELF_SIZE.y / 2, 0), SHELF_SIZE)
	store._build.mesh_box(SHELF_AT + Vector3(0, SHELF_SIZE.y / 2, 0), SHELF_SIZE, Supermarket.WOOD)
	for i in 8:
		var bottle: Node3D = BOTTLE_MODEL.instantiate()
		bottle.position = SHELF_AT + Vector3(0, SHELF_SIZE.y, -1.2 + i * 0.34)
		store.get_node("Built").add_child(bottle)
	store._label("SUPER_AISLE_13", Vector3(8.65, 2.6, Supermarket.STORE_Z - 0.1), 32, PI, 0.003)


## Running into it, facing it, pushes it; two cops push twice as fast. Online the host decides (its copies of the guests'
## cops run too) and the guests open it from its state.
func _physics_process(delta: float) -> void:
	if opened or not multiplayer.is_server():
		return
	for body in _push_zone.get_overlapping_bodies():
		var cop := body as Cop
		if cop and cop.is_running and -cop.global_basis.z.dot(gondola.global_basis.x) > 0.5:
			pushed += delta
	if pushed >= PUSH_NEEDED:
		open()


func open() -> void:
	if opened:
		return
	opened = true
	var tween := gondola.create_tween()
	tween.tween_property(gondola, "position:z", GONDOLA_AT.z - SLIDE, SLIDE_TIME)
	store.raid.float_label(tr("SUPER_AISLE13_CREAK"), gondola.global_position + Vector3.UP * 2.4, Color(1, 0.85, 0.3))
	store.raid.add_clue(tr("SUPER_AISLE13_CLUE"))


func net_state() -> Variant:
	return opened


func apply_net_state(state: Variant) -> void:
	if state and not opened:
		open()
