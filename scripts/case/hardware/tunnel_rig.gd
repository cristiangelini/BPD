class_name TunnelRig
extends HardwareRig

## The tunnel behind the screws (ferreteria.md, "El túnel detrás de los tornillos"): Tobías is digging toward somewhere
## worth robbing, from behind his screw wall. The wall slides aside if two cops push it at once (ScrewShelf); behind it,
## where the cabinet stood, a hole goes down into a short tunnel with the digging drill at its mouth, the main evidence
## (20 kg). Until then the drill waits frozen and out of the world, since the cabinet stands on it. The story's own
## clue: loose dirt at the foot of the wall. Tobías complains a lot if he sees the wall pushed. Every number here is
## (propuesta).

const DRILL_SCENE := preload("res://scenes/props/digging_drill.tscn")
const DIRT_SCENE := preload("res://scenes/props/dirt_pile.tscn")
## The hole in the floor where the cabinet stood, toward the street end, and the drill lying in it along z.
const HOLE_AT := Vector3(HardwareStore.SCREW_WALL_AT.x, HardwareStore.FLOOR_TOP, 5.8)
const HOLE_SIZE := Vector2(0.4, 1.1)
const DRILL_AT := Vector3(HardwareStore.SCREW_WALL_AT.x + 0.02, HardwareStore.FLOOR_TOP + 0.13, 5.8)
## The dirt on the floor in front of the wall.
const DIRT_AT := Vector3(HardwareStore.SCREW_WALL_AT.x + 0.55, HardwareStore.FLOOR_TOP + 0.04, 5.6)
const DARK := Color(0.08, 0.06, 0.05)
const EARTH := Color(0.42, 0.29, 0.17)

var drill: Evidence
var dirt: ClueNote


func setup(place: HardwareStore) -> void:
	super.setup(place)
	place.screw_shelf.slides = true
	place.screw_shelf.slid.connect(_on_slid)
	var parts := PlaceBuilder.new(place)
	parts.mesh_box(HOLE_AT + Vector3(0, 0.004, 0), Vector3(HOLE_SIZE.x, 0.008, HOLE_SIZE.y), DARK)
	parts.mesh_box(HOLE_AT + Vector3(0, 0.006, -HOLE_SIZE.y / 2 - 0.08), Vector3(HOLE_SIZE.x, 0.012, 0.16), EARTH)
	# The tunnel's mouth going into the wall behind the hole.
	parts.mesh_box(Vector3(-HardwareStore.HALF_X + 0.11, HardwareStore.FLOOR_TOP + 0.35, HOLE_AT.z),
		Vector3(0.02, 0.7, 0.6), DARK)
	drill = DRILL_SCENE.instantiate()
	drill.position = DRILL_AT
	drill.rotation.y = PI / 2
	drill.freeze = true
	drill.visible = false
	drill.collision_layer = 0
	drill.collision_mask = 0
	place.add_child(drill)
	place.main = drill
	dirt = DIRT_SCENE.instantiate()
	dirt.text = tr("CLUE_TUNNEL_DIRT")
	dirt.position = DIRT_AT
	place.add_child(dirt)
	dirt.read.connect(place.raid.add_clue)


func _on_slid(cop: Cop) -> void:
	store.tobias.saw(store.screw_shelf.global_position + Vector3.UP, HardwareMan.SAW_SHELF)
	drill.collision_layer = 4
	drill.collision_mask = 15
	drill.visible = true
	# Online a guest's copy stays frozen (PropSync stopped its physics) and follows the host's.
	drill.freeze = not drill.is_physics_processing()
	if cop:
		cop.show_hint("HINT_SCREW_TUNNEL_FOUND")
