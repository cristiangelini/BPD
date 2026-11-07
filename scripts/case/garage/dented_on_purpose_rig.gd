class_name DentedOnPurposeRig
extends GarageRig

## The dents on purpose (allanamiento-taller.md, "Las abolladuras a propósito"): at night Don Tuerca dents his clients'
## cars where they park, so they come back to his garage. The dent hammer is hidden with the list of the clients' plates
## and the neighborhood map with crosses; one of the two cars on the floor (drawn with the seed) is new and has perfectly
## round dents on its right side, all the same, and E on them is the story's own clue. Every number here is (propuesta).

## The dents along the car's right side, in the car's space: their height, where along the car and how big.
const DENT_Y := 0.6
const DENT_ZS: Array[float] = [-1.6, -0.8, 0.0, 0.8, 1.6]
const DENT_RADIUS := 0.12
const DENT := Color(0.16, 0.16, 0.18)

## The dented car (an index of Garage.CARS) and the spot on its side that E looks at.
var dented := -1
var spot: ClueSpot


func setup(place: Garage) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["dented on purpose", place.case_seed])
	dented = [0, 2][rng.randi_range(0, 1)]
	var car := place.cars[dented]
	var mesh := CylinderMesh.new()
	mesh.top_radius = DENT_RADIUS
	mesh.bottom_radius = DENT_RADIUS
	mesh.height = 0.02
	var material := StandardMaterial3D.new()
	material.albedo_color = DENT
	mesh.material = material
	for i in DENT_ZS.size():
		var dent := MeshInstance3D.new()
		dent.name = "Dent%d" % i
		dent.mesh = mesh
		dent.position = Vector3(Garage.CAR_SIZE.x / 2, DENT_Y, DENT_ZS[i])
		dent.rotation.z = PI / 2
		car.add_child(dent)
	spot = ClueSpot.new()
	spot.name = "Dents"
	spot.size = Vector3(0.06, 0.4, DENT_ZS[-1] - DENT_ZS[0] + DENT_RADIUS * 2)
	spot.prompt = "PROMPT_LOOK_DENTS"
	spot.text = "HINT_DENTS"
	spot.position = Vector3(Garage.CAR_SIZE.x / 2 + 0.05, DENT_Y, 0)
	car.add_child(spot)
	spot.read.connect(func(_text: String) -> void: garage.raid.add_clue(tr("CLUE_DENTS")))
