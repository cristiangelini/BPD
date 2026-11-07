class_name LaughingGasRig
extends DentistRaidRig

## The laughing gas (allanamiento-dentista.md, "El gas de la risa"): Dr. Molina smuggles laughing gas for parties. The
## bundle of tanks is hidden (it takes two cops); the consulting rooms' tanks are so full they leak on their own, one of
## them every LEAK_EVERY seconds (drawn with the seed); and the fish tank's bubbles giggle, the story's own clue (on the
## checklist the first time a cop comes close). Every number here is (propuesta).

const LEAK_EVERY := 45.0
const GIGGLE_EVERY := 4.0
const GIGGLE_TIME := 1.5
const GIGGLE_RANGE := 2.5
const GIGGLE_COLOR := Color(1.0, 0.6, 0.85)

var since_leak := 0.0
## Leaks this story started (not the ones the cops caused).
var leaks := 0
var heard_giggles := false
var giggle: Label3D
var _rng := RandomNumberGenerator.new()
var _since_giggle := 0.0


func setup(place: DentistRaid) -> void:
	super.setup(place)
	_rng.seed = hash(["laughing gas", place.case_seed])
	giggle = Label3D.new()
	giggle.text = "TANK_GIGGLE"
	giggle.font_size = 48
	giggle.pixel_size = 0.005
	giggle.outline_size = 10
	giggle.modulate = GIGGLE_COLOR
	giggle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	giggle.position = DentistRaid.TANK_AT + Vector3.UP * 1.5
	giggle.visible = false
	place.add_child(giggle)


func _physics_process(delta: float) -> void:
	# The host decides which tank leaks; the guests' tanks leak with it (net_state).
	if multiplayer.is_server():
		since_leak += delta
		if since_leak >= LEAK_EVERY:
			since_leak = 0.0
			leak_one()
	if office.tank_broken:
		giggle.visible = false
		return
	_since_giggle = fmod(_since_giggle + delta, GIGGLE_EVERY)
	giggle.visible = _since_giggle < GIGGLE_TIME
	giggle.position.y = DentistRaid.TANK_AT.y + 1.5 + _since_giggle * 0.2
	if heard_giggles:
		return
	var tank := office.to_global(DentistRaid.TANK_AT + Vector3.UP * 0.9)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(tank) < GIGGLE_RANGE:
			heard_giggles = true
			office.raid.add_clue(tr("CLUE_TANK_GIGGLES"))
			return


## One of the consulting rooms' tanks leaks, drawn with the seed.
func leak_one() -> void:
	var tank := office.gas_tanks[_rng.randi_range(0, office.gas_tanks.size() - 1)]
	if is_instance_valid(tank):
		tank.leak()
		leaks += 1


func net_state() -> Variant:
	return office.gas_tanks.map(func(tank: LaughingGasTank) -> bool: return tank.is_leaking())


func apply_net_state(state: Variant) -> void:
	for i in mini(state.size(), office.gas_tanks.size()):
		if state[i] and not office.gas_tanks[i].is_leaking():
			office.gas_tanks[i].leak()
