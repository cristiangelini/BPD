class_name RisingChairRig
extends DentistRaidRig

## The rising chair (allanamiento-dentista.md, "El sillón que sube"): the loot of a robbery waits in the false ceiling
## above chair 2. E on the chair's pedal lifts it LIFT meters (and down again); a cop standing on the lifted chair
## reaches the ceiling's hatch, and E on it drops the bag. Chair 2's backrest has shoe prints on it, the story's own clue
## (on the checklist the first time a cop comes close). Every number here is (propuesta).

const BAG_SCENE := preload("res://scenes/props/loot_bag.tscn")
## As high as a cop on the seat fits under the ceiling.
const LIFT := 0.4
const LIFT_SPEED := 0.4
const CHAIR := 1
const SHAPE_AT := Vector3(0, 0.45, -0.3)
const SHAPE_SIZE := Vector3(0.7, 0.9, 1.3)
## The hatch in the ceiling over the chair, in the office's space.
const HATCH_AT := DentistRaid.CHAIRS[CHAIR] + Vector3(0, DentistRaid.WALL_TOP - DentistRaid.FLOOR_TOP - 0.015, -0.3)
const HATCH_SIZE := Vector3(0.8, 0.02, 0.8)
const MARKS_RANGE := 1.5
const MARK := Color(0.25, 0.22, 0.2)

var lift: AnimatableBody3D
var pedal: PushButton
var hatch_button: PushButton
var raised := false
var opened := false
var saw_marks := false
var _hatch: MeshInstance3D


func setup(place: DentistRaid) -> void:
	super.setup(place)
	_lift_chair()
	_place_hatch()
	var bag: Evidence = BAG_SCENE.instantiate()
	# Above the ceiling until the hatch opens (where it doesn't bump a cop's head).
	bag.position = HATCH_AT + Vector3.UP * 0.4
	bag.freeze = true
	bag.visible = false
	place.add_child(bag)
	place.main = bag


## Whether the chair is all the way up.
func is_up() -> bool:
	return raised and lift.position.y >= DentistRaid.CHAIRS[CHAIR].y + LIFT - 0.01


## The pedal: up if it's down, down if it's up.
func toggle() -> void:
	raised = not raised


## E on the hatch: only a cop standing on the lifted chair reaches it, and the bag drops.
func use_hatch(cop: Cop) -> void:
	if opened:
		return
	if not is_up() or office.chair_under(office.to_local(cop.global_position)) != CHAIR:
		cop.show_hint("HINT_HATCH_TOO_HIGH")
		return
	open_hatch()


func open_hatch() -> void:
	opened = true
	_hatch.visible = false
	office.main.visible = true
	office.main.position = HATCH_AT + Vector3.DOWN * 0.35
	# Every PC opens it; the host's bag falls and PropSync moves the guests' copies.
	if multiplayer.is_server():
		office.main.freeze = false


func _physics_process(delta: float) -> void:
	var target := DentistRaid.CHAIRS[CHAIR].y + (LIFT if raised else 0.0)
	var before := lift.position.y
	lift.position.y = move_toward(lift.position.y, target, LIFT_SPEED * delta)
	# Whoever stands on it goes up with it (each PC lifts its own cop).
	var rise := lift.position.y - before
	if rise > 0.0:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if FamousDenturesRig.is_mine(cop) and office.chair_under(office.to_local(cop.global_position)) == CHAIR:
				cop.global_position.y += rise
	if saw_marks:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if office.to_local(cop.global_position).distance_to(DentistRaid.CHAIRS[CHAIR]) < MARKS_RANGE:
			saw_marks = true
			office.raid.add_clue(tr("CLUE_CHAIR_MARKS"))
			return


## Chair 2 on a body that moves (and carries whoever stands on it), with its pedal and the shoe prints on the backrest.
func _lift_chair() -> void:
	office.chair_bodies[CHAIR].queue_free()
	lift = AnimatableBody3D.new()
	lift.name = "RisingChair"
	lift.position = DentistRaid.CHAIRS[CHAIR]
	office.add_child(lift)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SHAPE_SIZE
	shape.shape = box
	shape.position = SHAPE_AT
	lift.add_child(shape)
	var look := office.chair_looks[CHAIR]
	look.reparent(lift, false)
	look.position = Vector3.ZERO
	pedal = PushButton.new()
	pedal.prompt = "PROMPT_CHAIR_PEDAL"
	pedal.position = Vector3(0.3, 0.1, 0.25)
	lift.add_child(pedal)
	_hide_button(pedal)
	pedal.pressed.connect(func(_cop: Cop) -> void: toggle())
	var material := StandardMaterial3D.new()
	material.albedo_color = MARK
	for x: float in [-0.1, 0.1]:
		var mark := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.08, 0.005, 0.18)
		mark.mesh = mesh
		mark.material_override = material
		mark.position = Vector3(x, 1.0, -0.62)
		mark.rotation.x = -1.2
		lift.add_child(mark)


func _place_hatch() -> void:
	_hatch = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = HATCH_SIZE
	_hatch.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = DentistRaid.TILE.darkened(0.15)
	_hatch.material_override = material
	_hatch.position = HATCH_AT
	office.add_child(_hatch)
	hatch_button = PushButton.new()
	hatch_button.prompt = "PROMPT_CEILING_HATCH"
	hatch_button.position = HATCH_AT + Vector3.DOWN * 0.1
	hatch_button.rotation.x = PI / 2
	office.add_child(hatch_button)
	_hide_button(hatch_button)
	hatch_button.pressed.connect(use_hatch)


func _hide_button(button: PushButton) -> void:
	for part in button.get_children():
		if part is MeshInstance3D:
			part.hide()


func net_state() -> Variant:
	return [raised, opened]


func apply_net_state(state: Variant) -> void:
	raised = state[0]
	if state[1] and not opened:
		open_hatch()
