class_name PinataBillsRig
extends BirthdayRaidRig

## The piñata full of bills (allanamiento-cumple.md, "La piñata de billetes"): Chispita prints fake money and spends it
## a few bills at a time, wrapped round the candies of every piñata he hangs. The printing plate is hidden. When the
## piñata breaks, fake bills of the "Banco Feliz" rain with the candies, the story's own clue (on the checklist), and
## the kids pick them up with the candies. Every number here is (propuesta).

const BILLS := 10
const BILL_SIZE := Vector3(0.2, 0.01, 0.1)
const FAKE_BILL := Color(0.55, 0.85, 0.55)
## A little over the floor, so its tiles don't hide them.
const LIFT := 0.02

## The bills lying under the broken piñata.
var bills: Array[MeshInstance3D] = []


func setup(place: BirthdayRaid) -> void:
	super.setup(place)
	place.pinata.broken.connect(_rain)


func _rain(_cop: Cop) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["pinata bills", party.case_seed])
	var material := StandardMaterial3D.new()
	material.albedo_color = FAKE_BILL
	var under := Vector3(BirthdayRaid.PINATA_AT.x, BirthdayRaid.FLOOR_TOP + LIFT, BirthdayRaid.PINATA_AT.z)
	for i in BILLS:
		var bill := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = BILL_SIZE
		mesh.material = material
		bill.mesh = mesh
		var angle := rng.randf_range(0.0, TAU)
		bill.position = under + Vector3(cos(angle), 0, sin(angle)) * rng.randf_range(0.2, 1.4)
		bill.rotation.y = rng.randf_range(0.0, PI)
		party.add_child(bill)
		bills.append(bill)
	party.raid.float_label(tr("BIRTHDAY_PINATA_BILLS"), party.to_global(under + Vector3.UP), FAKE_BILL)
	party.raid.add_clue(tr("CLUE_PINATA_BILLS"))
