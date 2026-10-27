class_name PirateCopiesRig
extends CinemaRig

## The pirate copies (allanamiento-cine.md, "Las copias piratas"): doña Bobina films the premieres from the back row and
## sells the copies. The box with 200 copies is hidden with the camcorder and the printed covers; in the last row one
## more neighbor (a free seat drawn with the seed) has a camcorder in the popcorn bucket, its red light blinking in the
## dark, and a cop who gets close to it finds the story's own clue (on the checklist the first time). Every number here
## is (propuesta).

signal spotted(cop: Cop)

## The light, on the lap of whoever tapes, and how often it blinks.
const LIGHT_AT := Vector3(0.22, 0.75, 0.25)
const BLINK := 0.5
const NEAR := 2.0
const RED := Color(1.0, 0.12, 0.1)

## The neighbor who tapes the film, and the cops who already spotted the light.
var taper: CinemaSpectator
var spotted_by := {}
var _light: Node3D
var _blink := 0.0


func setup(place: Cinema) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["pirate copies", place.case_seed])
	var free: Array[int] = []
	for row: int in [Cinema.ROWS - 1, Cinema.ROWS - 2]:
		for i in Cinema.SEATS_PER_ROW:
			var seat := row * Cinema.SEATS_PER_ROW + i
			if place.seat_free(seat):
				free.append(seat)
		if not free.is_empty():
			break
	taper = place.seat_spectator(free[rng.randi_range(0, free.size() - 1)], Cinema.SPECTATORS)
	taper.line_override = "CINEMA_TAPER_LINE"
	_light = Node3D.new()
	_light.name = "RedLight"
	_light.position = LIGHT_AT
	taper.add_child(_light)
	var dot := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.025
	sphere.height = 0.05
	dot.mesh = sphere
	var lit := StandardMaterial3D.new()
	lit.albedo_color = RED
	lit.emission_enabled = true
	lit.emission = RED
	lit.emission_energy_multiplier = 4.0
	dot.material_override = lit
	_light.add_child(dot)
	var glow := OmniLight3D.new()
	glow.light_color = RED
	glow.light_energy = 0.6
	glow.omni_range = 0.8
	_light.add_child(glow)
	var area := Area3D.new()
	area.name = "NearLight"
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = NEAR
	shape.shape = ball
	area.add_child(shape)
	_light.add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop:
			spot(body))


## `cop` got close to the blinking light: what they see and, the first time anyone does, the clue.
func spot(cop: Cop) -> void:
	if spotted_by.has(cop):
		return
	spotted_by[cop] = true
	cop.show_hint("HINT_RED_LIGHT")
	if spotted_by.size() == 1:
		cinema.raid.add_clue(tr("CLUE_RED_LIGHT"))
	spotted.emit(cop)


func _process(delta: float) -> void:
	_blink += delta
	if _blink >= BLINK:
		_blink = 0.0
		_light.visible = not _light.visible
