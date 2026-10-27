class_name TenantsRig
extends ApartmentsRig

## The tenant of twenty (edificio.md, "El inquilino de los veinte"): Mr. Bellini rents 30C, which isn't his, to twenty
## people at once. Behind its door (locked like always) it is full of the tricked tenants' mattresses and bags, and the
## box with the twenty contracts sits on a mattress at the back. The story's clue: 30C's mailbox in the lobby with
## twenty different names on it (on the checklist once). Every number here is (propuesta).

const BOX_SCENE := preload("res://scenes/props/contracts_box.tscn")
const MATTRESS := preload("res://assets/models/mattress.glb")
const BAG := preload("res://assets/models/duffel_bag.glb")
const MATTRESS_SIZE := Vector3(0.9, 0.2, 1.9)
const BAG_SIZE := Vector3(0.6, 0.3, 0.3)
const BOX_HALF_HEIGHT := 0.16
## 30C runs from the building's west wall to the shaft, behind the core: mattresses side by side along its back wall,
## with a strip free by the door to walk in.
const ROOM_WEST := -ApartmentTower.HALF_X + 0.6
const ROOM_EAST := -ApartmentTower.SHAFT_HALF - 0.5
const MATTRESS_Z := -ApartmentTower.HALF_Z + 1.05
## Bags on some of the mattresses and a second mattress on others, by their index.
const BAGS := [0, 2, 3, 6, 8]
const PILED := [4, 7]
## On the second mattress from the west wall.
const BOX_ON := 1
## 30C's mailbox in the lobby: on the mailboxes' open side, toward the top.
const MAILBOX_AT := ApartmentTower.MAILBOXES_AT + Vector3(-ApartmentTower.MAILBOXES_SIZE.x / 2 - 0.03, 1.2, -0.8)

var box: Evidence
var mattresses: Array[StaticBody3D] = []
var mailbox: ClueSpot


func setup(place: ApartmentTower) -> void:
	super.setup(place)
	var count := floori((ROOM_EAST - ROOM_WEST) / MATTRESS_SIZE.x)
	for i in count:
		# Laid down in a hurry: a little off line, and two of them piled.
		var at := Vector3(ROOM_WEST + (i + 0.5) * MATTRESS_SIZE.x, ApartmentTower.TOP_Y, MATTRESS_Z + 0.1 * (i % 3 - 1))
		mattresses.append(_lump(MATTRESS, MATTRESS_SIZE, at, 0.0 if i == BOX_ON else 0.04 * (i % 2 * 2 - 1)))
		if PILED.has(i):
			at.y += MATTRESS_SIZE.y
			mattresses.append(_lump(MATTRESS, MATTRESS_SIZE, at + Vector3(0.05, 0, -0.1), 0.12))
		if BAGS.has(i):
			_lump(BAG, BAG_SIZE, at + Vector3(0, MATTRESS_SIZE.y, 0.5), 0.3 * (i % 3 - 1))
	var bulb := OmniLight3D.new()
	bulb.position = Vector3((ROOM_WEST + ROOM_EAST) / 2, ApartmentTower.TOP_Y + 2.6, -ApartmentTower.HALF_Z + 2.0)
	bulb.light_color = Color(1.0, 0.85, 0.6)
	bulb.omni_range = 7.0
	tower.add_child(bulb)
	box = BOX_SCENE.instantiate()
	box.position = Vector3(ROOM_WEST + (BOX_ON + 0.5) * MATTRESS_SIZE.x, ApartmentTower.TOP_Y + MATTRESS_SIZE.y,
		MATTRESS_Z - 0.3 + 0.1 * (BOX_ON % 3 - 1)) + Vector3.UP * (BOX_HALF_HEIGHT + 0.01)
	place.add_child(box)
	place.main = box
	mailbox = ClueSpot.new()
	mailbox.size = Vector3(0.06, 0.25, 0.4)
	mailbox.prompt = "PROMPT_MAILBOX_30C"
	mailbox.text = "CLUE_TWENTY_NAMES"
	mailbox.position = MAILBOX_AT
	var card := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.01, 0.22, 0.36)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.96, 0.95, 0.9)
	mesh.material = material
	card.mesh = mesh
	mailbox.add_child(card)
	var label := Label3D.new()
	label.text = "30C"
	label.font_size = 32
	label.pixel_size = 0.004
	label.modulate = Color(0.1, 0.1, 0.12)
	label.outline_size = 0
	label.rotation.y = -PI / 2
	label.position = Vector3(-0.01, 0.07, 0)
	mailbox.add_child(label)
	place.add_child(mailbox)
	mailbox.read.connect(func(text: String) -> void: tower.raid.add_clue(tr(text)))


## Something big that stays where it is: a model with a box to bump into.
func _lump(model: PackedScene, size: Vector3, floor_at: Vector3, turn: float) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = floor_at
	body.rotation.y = turn
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	shape.position.y = size.y / 2
	body.add_child(shape)
	body.add_child(model.instantiate())
	tower.add_child(body)
	return body
