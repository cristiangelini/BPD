class_name MeterCoinsRig
extends CarWashRig

## The parking meter coins (allanamiento-lavadero.md, "Las monedas de los parquímetros"): Don Chorro empties the city's
## parking meters and passes the coins off as car wash tokens. The token machine is so full it spits a token on its own
## every SPIT_EVERY seconds, with a "clinc"; a cop this close to it when it does notices, the story's own clue (on the
## checklist the first time). The vacuums go "clinc, clinc" as if they were sucking coins, to a cop nearby. Every
## number here is (propuesta).

const NOTICE_RANGE := 4.0
const SPIT_EVERY := 20.0
## At most this many tokens lie on the floor; the oldest goes when another comes.
const MAX_TOKENS := 8
const CLINK_RANGE := 5.0
const CLINK_EVERY := 6.0
const GOLD := Color(0.95, 0.78, 0.29)

var noticed := false
var spits := 0
var clinks := 0
var tokens: Array[MeshInstance3D] = []
var _since_spit := 0.0
var _since_clink := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: CarWash) -> void:
	super.setup(place)
	_rng.seed = car_wash.case_seed


func _physics_process(delta: float) -> void:
	_since_spit += delta
	if _since_spit >= SPIT_EVERY:
		_since_spit = 0.0
		spit()
	_since_clink += delta
	if _since_clink >= CLINK_EVERY:
		for at in CarWash.VACUUMS:
			if _cop_within(car_wash.to_global(at), CLINK_RANGE):
				_since_clink = 0.0
				clink(at)
				break


func _cop_within(at: Vector3, distance: float) -> bool:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(at) <= distance:
			return true
	return false


## The token machine spits a token on its own: it rolls out to the floor in front; a cop nearby notices.
func spit() -> void:
	spits += 1
	var token := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.035
	disc.bottom_radius = 0.035
	disc.height = 0.008
	token.mesh = disc
	var paint := StandardMaterial3D.new()
	paint.albedo_color = GOLD
	paint.metallic = 0.7
	token.material_override = paint
	token.position = CarWash.TOKEN_AT + Vector3(0, 0.75, 0.3)
	car_wash.add_child(token)
	var land := CarWash.TOKEN_AT + Vector3(_rng.randf_range(-0.6, 0.6), 0.005, _rng.randf_range(0.6, 1.4))
	token.create_tween().tween_property(token, "position", land, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(
		Tween.EASE_OUT)
	tokens.append(token)
	if tokens.size() > MAX_TOKENS:
		tokens.pop_front().queue_free()
	var at := car_wash.to_global(CarWash.TOKEN_AT + Vector3.UP * 1.9)
	car_wash.raid.float_label(tr("CARWASH_CLINK"), at, GOLD)
	if not noticed and _cop_within(car_wash.to_global(CarWash.TOKEN_AT), NOTICE_RANGE):
		noticed = true
		car_wash.raid.add_clue(tr("CLUE_TOKEN_SPIT"))


## A vacuum goes "clinc, clinc".
func clink(at: Vector3) -> void:
	clinks += 1
	car_wash.raid.float_label(tr("CARWASH_VACUUM_CLINK"), car_wash.to_global(at + Vector3.UP * 2.2), GOLD)
