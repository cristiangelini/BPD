class_name WeddingBride
extends WeddingPerson

## Rosa, the bride (escena-boda.md, "Rosa sospecha del novio"): she follows the nearest cop in the hall, about FOLLOW
## away in her long dress with the bouquet, and every LINE_EVERY she says something against Tito. E on her gets her
## "proof" that it was him, which proves nothing and goes nowhere. During the waltz she forgets the cops and dances
## with Tito (WeddingWaltz). Once Tito is accused she throws the bouquet in his face, and stops following anyone. Every
## number here is (propuesta).

const MODEL := preload("res://assets/models/npc_novia.glb")
const FOLLOW := 2.0
const SPEED := 2.5
## Seconds between her lines against Tito, while a cop is close.
const LINE_EVERY := 9.0
const LINE_REACH := 4.0
const LINES := 10
const PROOFS := 6

var hall: WeddingHall
## The bouquet's in Tito's face: she's done following.
var thrown := false
## Dancing the waltz (WeddingWaltz moves her).
var dancing := false
var _line_left := LINE_EVERY
var _proofs_said := 0


func _ready() -> void:
	model = MODEL
	prompt = "PROMPT_WEDDING_BRIDE"
	line_key = "WEDDING_BRIDE_LINE_"
	lines = LINES
	super._ready()
	add_to_group("wedding_bride")


## E on her: her proof that it was Tito, a different one each time.
func use(_cop: Cop) -> void:
	if thrown:
		say("BRIDE_DONE")
		return
	say("WEDDING_BRIDE_PROOF_%d" % (_proofs_said % PROOFS), 4.5)
	_proofs_said += 1


## Tito was accused: right ("¡LO SABÍA!") or wrong (the wedding's off); the bouquet flies either way.
func throw_bouquet(right: bool) -> void:
	if thrown:
		return
	thrown = true
	part("bouquet").visible = false
	say("BRIDE_KNEW_IT" if right else "BRIDE_WEDDING_OFF", 5.0)


## The nearest cop in the hall, or null.
func nearest_cop() -> Node3D:
	var best: Node3D = null
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Node3D
		if hall and not hall.at_scene(cop.global_position):
			continue
		if not best or cop.global_position.distance_to(global_position) < best.global_position.distance_to(
				global_position):
			best = cop
	return best


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if thrown or dancing:
		return
	var cop := nearest_cop()
	if not cop:
		return
	var to := cop.global_position - global_position
	to.y = 0.0
	var away := to.length()
	if away > 0.01:
		global_rotation.y = atan2(to.x, to.z)
	if away > FOLLOW:
		global_position += to / away * minf(SPEED * delta, away - FOLLOW)
	_line_left -= delta
	if _line_left <= 0.0 and away <= LINE_REACH:
		_line_left = LINE_EVERY
		talk()
