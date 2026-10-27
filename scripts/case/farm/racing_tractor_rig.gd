class_name RacingTractorRig
extends FarmRaidRig

## The racing tractor (allanamiento-granja.md, "El tractor de carreras"): Don Florencio races his tractor in illegal
## night races with an engine hidden in the barn. The tractor wears a "Turbo" sticker and smells of jet fuel: E on it
## starts it (the story's own clue, on the checklist the first time), and it shoots off RUN meters in a straight line
## until it hits whatever is in the way. It has fuel for one run. Every number here is (propuesta).

signal launched(distance: float)

const RUN := 20.0
const SPEED := 12.0

## How far it went when it started (0: it hasn't).
var ran := 0.0
var sticker: Label3D


func setup(place: FarmRaid) -> void:
	super.setup(place)
	place.tractor.startable = true
	place.tractor.started.connect(_on_started)
	sticker = Label3D.new()
	sticker.text = "TURBO"
	sticker.modulate = Color(1.0, 0.45, 0.1)
	sticker.outline_modulate = Color(0.1, 0.1, 0.1)
	sticker.font_size = 64
	sticker.pixel_size = 0.004
	sticker.position = Vector3(0.82, 1.0, 0.3)
	sticker.rotation.y = PI / 2
	place.tractor_model.add_child(sticker)


func _on_started(cop: Cop) -> void:
	if ran > 0.0:
		farm.raid.float_label(tr("FARM_TRACTOR_EMPTY"), cop.global_position + Vector3.UP * 2.0, Color.WHITE)
		return
	farm.raid.add_clue(tr("CLUE_TRACTOR_TURBO"))
	launch()


## Shoots the tractor forward (the farm's +Z, toward the yard) until RUN meters or the first thing in the way.
func launch() -> float:
	if ran > 0.0 or not multiplayer.is_server():
		return 0.0
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 1.2, 2.6)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = box
	query.transform = farm.tractor.global_transform
	query.motion = farm.global_basis.z.normalized() * RUN
	query.exclude = [farm.tractor.get_rid()]
	var safe := farm.tractor.get_world_3d().direct_space_state.cast_motion(query)[0]
	ran = maxf(RUN * safe, 0.01)
	farm.raid.float_label(tr("FARM_TRACTOR_VROOM"), farm.tractor.global_position + Vector3.UP * 1.5,
		Color(1.0, 0.45, 0.1))
	_drive(ran)
	if safe < 1.0:
		get_tree().create_timer(ran / SPEED).timeout.connect(func() -> void:
			farm.raid.float_label(tr("FARM_TRACTOR_BANG"), farm.tractor.global_position + Vector3.UP * 1.5, Color.WHITE))
	launched.emit(ran)
	return ran


func _drive(distance: float) -> void:
	var tween := create_tween().set_parallel()
	for node: Node3D in [farm.tractor, farm.tractor_model]:
		tween.tween_property(node, "position", node.position + Vector3(0, 0, distance), distance / SPEED)


func net_state() -> Variant:
	return ran


func apply_net_state(state: Variant) -> void:
	if ran == 0.0 and float(state) > 0.0:
		ran = float(state)
		_drive(ran)
