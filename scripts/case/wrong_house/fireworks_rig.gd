class_name WhFireworksRig
extends WrongHouseRig

## The fireworks (casa-equivocada.md, "Los fuegos artificiales"): El Chispa keeps a box of rockets for the
## neighborhood party. The box (RocketBox) is the main evidence; the fuses and the party plan are the extras. The
## story's own clue: soot and burns on the curtain of his front window. A hit over 2 m/s lights the box: for SHOW
## seconds rockets fly around the house it's in and break one of its ornaments right away and then every BREAK_EVERY seconds (fines, at
## double in doña Chola's). Every number here is (propuesta).

const SHOW := 10.0
const BREAK_EVERY := 0.5
const ROCKETS := 8
const ROCKET_SPEED := 4.0
## The window with the burnt curtain (house space).
const BURNS_AT := Vector3(3.5, 1.5, WrongHouse.FRONT_Z + 0.13)
const ROCKET_COLORS: Array[Color] = [Color(1.0, 0.85, 0.2), Color(0.3, 0.5, 1.0), Color(0.3, 1.0, 0.4), Color(1.0, 0.3, 0.3)]

var box: RocketBox
var burns: ClueSpot
## The house the show is going off in (-1: outside, or not lit).
var show_house := -1
var show_left := 0.0
var rockets: Array[MeshInstance3D] = []
var _break_left := 0.0
var _to_break := 0
## Where the show began (place space).
var _center := Vector3.ZERO
var _speeds: Array[Vector3] = []
var _rng := RandomNumberGenerator.new()


func setup(wrong_house: WrongHouse) -> void:
	super.setup(wrong_house)
	_rng.seed = hash(["wrong house fireworks", place.case_seed])
	box = place.main
	box.lit.connect(light)
	burns = clue_spot(WrongHouse.at(place.guilty, BURNS_AT), Vector3(1.2, 1.0, 0.1), "PROMPT_LOOK_BURNS",
		"CLUE_WH_BURNS")
	patch(burns, Vector3(0, 0.25, 0.02), Vector3(0.9, 0.35, 0.005), Color(0.12, 0.1, 0.09))
	patch(burns, Vector3(0.2, -0.1, 0.02), Vector3(0.3, 0.3, 0.005), Color(0.2, 0.16, 0.12))


## The box went off: rockets in the house it's in, for SHOW seconds.
func light() -> void:
	show_left = SHOW
	# The first one goes at once, then one every BREAK_EVERY.
	_break_left = 0.0
	_to_break = int(SHOW / BREAK_EVERY)
	show_house = -1
	_center = box.position
	var spot := Vector2(box.global_position.x, box.global_position.z)
	for house in 2:
		if WrongHouse.house_rect(house).has_point(spot):
			show_house = house
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_WH_ROCKETS")
	for i in ROCKETS:
		var color := ROCKET_COLORS[i % ROCKET_COLORS.size()]
		var rocket := patch(place, _center + Vector3.UP * 0.4, Vector3(0.14, 0.14, 0.14), color)
		(rocket.material_override as StandardMaterial3D).emission_enabled = true
		(rocket.material_override as StandardMaterial3D).emission = color
		var glow := OmniLight3D.new()
		glow.light_color = color
		glow.omni_range = 2.0
		glow.light_energy = 2.0
		rocket.add_child(glow)
		rockets.append(rocket)
		_speeds.append(Vector3(_rng.randf_range(-1, 1), _rng.randf_range(0.2, 1), _rng.randf_range(-1, 1)).normalized()
			* ROCKET_SPEED)


func _physics_process(delta: float) -> void:
	if show_left <= 0.0:
		return
	show_left -= delta
	_fly(delta)
	if show_house >= 0:
		_break_left -= delta
		while _break_left <= 0.0 and _to_break > 0:
			_break_left += BREAK_EVERY
			_to_break -= 1
			_break_one()
	if show_left <= 0.0:
		for rocket in rockets:
			rocket.queue_free()
		rockets.clear()
		_speeds.clear()


## Every rocket zips around, bouncing inside a 6 × 2.4 × 6 m box over where the show began.
func _fly(delta: float) -> void:
	for i in rockets.size():
		var speed := _speeds[i]
		var rocket := rockets[i]
		rocket.position += speed * delta
		for axis in 3:
			var reach := 1.2 if axis == 1 else 3.0
			if absf(rocket.position[axis] - _center[axis] - (1.2 if axis == 1 else 0.0)) > reach:
				speed[axis] = -speed[axis]
		_speeds[i] = speed


## Breaks one ornament still whole in that house.
func _break_one() -> void:
	var whole: Array = place.ornaments[show_house].filter(func(o: Variant) -> bool:
		return is_instance_valid(o) and not (o as Ornament).is_broken)
	if whole.is_empty():
		return
	(whole[_rng.randi_range(0, whole.size() - 1)] as Ornament).hit(Ornament.BREAK_SPEED + 1.0)
