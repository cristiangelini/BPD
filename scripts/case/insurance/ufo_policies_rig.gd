class_name UfoPoliciesRig
extends InsuranceRig

## The UFO insurance (seguros.md, "El seguro contra ovnis"): the office sells policies against alien abduction to
## retirees by phone. The box of signed policies is the main evidence (5 kg), hidden with the fake UFO photos and the
## toy saucer they're taken with. The story's own clue: the sales script on one of the desks ("And what if they abduct
## you, ma'am?"). And the phones on every desk ring: E answers, and a retiree asks if their policy covers cows. Every
## number here is (propuesta).

const SCRIPT_SCENE := preload("res://scenes/props/sales_script.tscn")
const PHONE_SCENE := preload("res://scenes/props/desk_phone.tscn")
const CALLS := ["PHONE_CALL_1", "PHONE_CALL_2", "PHONE_CALL_3", "PHONE_CALL_4", "PHONE_CALL_5"]
## Every RING_EVERY seconds a silent phone starts ringing, up to MAX_RINGING at once.
const RING_EVERY := 8.0
const MAX_RINGING := 3
## Where the phone and the script lie on a cubicle's desk, from its middle (the script in front of the monitor, away
## from the paper pile).
const PHONE_ON_DESK := Vector3(0.0, 0.0, -0.1)
const SCRIPT_ON_DESK := Vector3(-0.45, 0.012, 0.15)

var sales_script: ClueNote
var phones: Array[DeskPhone] = []
var _rng := RandomNumberGenerator.new()
var _until_ring := RING_EVERY


## The middle of the desk's top in each cubicle, row by row.
static func desk_tops() -> Array[Vector3]:
	var tops: Array[Vector3] = []
	for row in InsuranceOffice.CUBICLE_ROWS.size():
		for x: float in InsuranceOffice.CUBICLE_COLUMNS:
			tops.append(Vector3(x, InsuranceOffice.FLOOR_TOP + InsuranceOffice.CUBICLE_DESK_SIZE.y,
				InsuranceOffice.CUBICLE_ROWS[row] - InsuranceOffice.CUBICLE_SIZE.y / 2 + 0.35))
	return tops


func setup(place: InsuranceOffice) -> void:
	super.setup(place)
	_rng.seed = place.case_seed * 17 + 3
	var tops := desk_tops()
	var calls: Array[String] = []
	for key: String in CALLS:
		calls.append(tr(key))
	for i in tops.size():
		var phone: DeskPhone = PHONE_SCENE.instantiate()
		phone.position = tops[i] + PHONE_ON_DESK
		phone.calls = calls.duplicate()
		phone.answers = i
		place.add_child(phone)
		phones.append(phone)
	sales_script = SCRIPT_SCENE.instantiate()
	sales_script.text = tr("CLUE_SALES_SCRIPT")
	sales_script.position = tops[_rng.randi() % tops.size()] + SCRIPT_ON_DESK
	sales_script.rotation.y = _rng.randf_range(-0.2, 0.2)
	place.add_child(sales_script)
	sales_script.read.connect(place.raid.add_clue)
	phones[_rng.randi() % phones.size()].ring()


func ringing() -> int:
	return phones.filter(func(phone: DeskPhone) -> bool: return phone.is_ringing()).size()


func _physics_process(delta: float) -> void:
	_until_ring -= delta
	if _until_ring > 0.0:
		return
	_until_ring = RING_EVERY
	if ringing() >= MAX_RINGING:
		return
	var silent := phones.filter(func(phone: DeskPhone) -> bool: return not phone.is_ringing())
	if not silent.is_empty():
		(silent[_rng.randi() % silent.size()] as DeskPhone).ring()
