class_name IceCreamRig
extends Node

## What only one of the ice cream shop's stories adds (allanamiento-heladeria.md, "Las historias"), like
## RadioStationRig for the radio. The shop adds the story's rig as a child once its hidden items are placed and calls
## setup; the rig can then run its own mechanic.

var shop: IceCreamShop


func setup(place: IceCreamShop) -> void:
	shop = place


## Online, what the guests' rig takes from the host's (IceCreamShop.net_state); most stories need nothing.
func net_state() -> Variant:
	return null


func apply_net_state(_value: Variant) -> void:
	pass


## A small sign standing at `at`, facing `turn` around Y, with `title` on it and a clue a cop reads with E (`text`, on
## the checklist the first time).
func sign_spot(at: Vector3, turn: float, title: String, text: String, size := Vector3(0.5, 0.3, 0.06),
		font := 24) -> ClueSpot:
	var spot := ClueSpot.new()
	spot.size = size
	spot.text = text
	spot.position = at
	spot.rotation.y = turn
	spot.read.connect(shop.raid.add_clue)
	shop.add_child(spot)
	var face := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, size.y, 0.02)
	face.mesh = box
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color(0.98, 0.96, 0.9)
	face.material_override = paint
	spot.add_child(face)
	var label := Label3D.new()
	label.text = title
	label.font_size = font
	label.pixel_size = 0.0025
	label.modulate = Color(0.75, 0.15, 0.3)
	label.outline_size = 0
	label.width = size.x / 0.0025 * 0.9
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.position = Vector3(0, 0, 0.015)
	spot.add_child(label)
	return spot


## Someone (`model`) who comes in through the front door now and then, standing just inside it facing the counter.
func visitor(model: PackedScene) -> IceVisitor:
	var who := IceVisitor.new(model)
	who.position = Vector3(IceCreamShop.ENTRANCE_X, IceCreamShop.FLOOR_TOP, IceCreamShop.FRONT_WALL_Z - 0.8)
	who.rotation.y = PI
	shop.add_child(who)
	return who
