class_name CoffeeSafeRig
extends InsuranceRig

## The coffee machine safe (seguros.md, "La máquina de café es una caja fuerte"): the premiums the office never paid out
## are kept inside the kitchen's huge coffee machine, which is the main evidence (30 kg, between two). The post-it with
## the combination and the secret account book are hidden. The story's own clue: E on the machine gives coins instead
## of coffee. And every cup on the desks holds coins. Every number here is (propuesta).

const SAFE_SCENE := preload("res://scenes/props/coffee_safe.tscn")
const CUP := Color(0.96, 0.96, 0.94)
const COIN := Color(0.85, 0.72, 0.3)

var safe: CoffeeSafe
var cups: Array[Node3D] = []


func setup(place: InsuranceOffice) -> void:
	super.setup(place)
	safe = SAFE_SCENE.instantiate()
	safe.transform = place.coffee.transform
	safe.text = tr("CLUE_COFFEE_COINS")
	place.coffee.free()
	place.coffee = null
	place.add_child(safe)
	safe.read.connect(place.raid.add_clue)
	place.main = safe
	var cup_mesh := CylinderMesh.new()
	cup_mesh.top_radius = 0.04
	cup_mesh.bottom_radius = 0.035
	cup_mesh.height = 0.09
	var cup_look := StandardMaterial3D.new()
	cup_look.albedo_color = CUP
	cup_mesh.material = cup_look
	var coin_mesh := CylinderMesh.new()
	coin_mesh.top_radius = 0.035
	coin_mesh.bottom_radius = 0.035
	coin_mesh.height = 0.012
	var coin_look := StandardMaterial3D.new()
	coin_look.albedo_color = COIN
	coin_look.metallic = 0.6
	coin_mesh.material = coin_look
	for row in InsuranceOffice.CUBICLE_ROWS.size():
		for x: float in InsuranceOffice.CUBICLE_COLUMNS:
			var desk := Vector3(x, InsuranceOffice.FLOOR_TOP + InsuranceOffice.CUBICLE_DESK_SIZE.y,
				InsuranceOffice.CUBICLE_ROWS[row] - InsuranceOffice.CUBICLE_SIZE.y / 2 + 0.35)
			var cup := MeshInstance3D.new()
			cup.mesh = cup_mesh
			cup.position = desk + Vector3(0.05, 0.045, 0.15)
			var coins := MeshInstance3D.new()
			coins.mesh = coin_mesh
			coins.position = Vector3(0, 0.04, 0)
			cup.add_child(coins)
			place.add_child(cup)
			cups.append(cup)
