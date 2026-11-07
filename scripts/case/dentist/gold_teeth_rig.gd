class_name GoldTeethRig
extends DentistRaidRig

## The gold teeth (allanamiento-dentista.md, "Los dientes de oro"): Dr. Molina melts his patients' gold crowns into tiny
## ingots. E on the lab's X-ray light box changes the film; one of the PLATES (drawn with the seed, never the first one
## up) shows an ingot inside a molar, the story's own clue (on the checklist the first time). Every number here is
## (propuesta).

const PLATES := 4
const FILM := Vector3(0.24, 0.3, 0.004)
## Where the film hangs on the light box, in the box's space.
const FILM_AT := Vector3(-0.08, 0.225, 0.066)
const DARK := Color(0.12, 0.18, 0.25)
const BONE := Color(0.85, 0.9, 0.95)
const INGOT := Color(1.0, 0.85, 0.3)

## The film on the box now, and the one with the ingot.
var plate := 0
var ingot_plate := -1
var seen_ingot := false
var button: PushButton
var _film: Node3D


func setup(place: DentistRaid) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["gold teeth", place.case_seed])
	ingot_plate = rng.randi_range(1, PLATES - 1)
	button = PushButton.new()
	button.prompt = "PROMPT_XRAY_NEXT"
	button.position = Vector3(0, 0.225, 0.09)
	place.xray.add_child(button)
	for part in button.get_children():
		if part is MeshInstance3D:
			part.hide()
	button.pressed.connect(func(_cop: Cop) -> void: next_plate())
	_draw()


## The next film on the light box; the ingot's goes on the checklist the first time it's seen.
func next_plate() -> void:
	plate = (plate + 1) % PLATES
	_draw()
	if plate == ingot_plate and not seen_ingot:
		seen_ingot = true
		office.raid.add_clue(tr("CLUE_XRAY_INGOT"))
		office.raid.float_label(tr("XRAY_INGOT"), office.xray.global_position + Vector3.UP * 0.7, INGOT)


## A dark film with a row of molars, each film a little different; the ingot's has a gold bar inside one of them.
func _draw() -> void:
	if _film:
		_film.queue_free()
	_film = Node3D.new()
	_film.position = FILM_AT
	office.xray.add_child(_film)
	_box(Vector3.ZERO, FILM, DARK)
	var teeth := 2 + plate % 2
	for i in teeth:
		var x := (i - (teeth - 1) / 2.0) * 0.07
		_box(Vector3(x, -0.02 + (plate % 3) * 0.015, 0.003), Vector3(0.05, 0.08, 0.002), BONE)
	if plate == ingot_plate:
		_box(Vector3(-(teeth - 1) / 2.0 * 0.07, -0.02 + (plate % 3) * 0.015, 0.005), Vector3(0.025, 0.012, 0.002), INGOT)


func _box(at: Vector3, size: Vector3, color: Color) -> void:
	var look := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	look.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = color != DARK
	material.emission = color
	look.material_override = material
	look.position = at
	_film.add_child(look)
