class_name MagicOdometerRig
extends GarageRig

## The magic odometer (allanamiento-taller.md, "El cuentakilómetros mágico"): Don Tuerca winds old cars' odometers back
## and sells them as new. The drill that does it is hidden with the notebook of the real kilometers and the "0 km, one
## owner" sign. Each car on the floor has its dashboard by the driver's window: one of them (drawn with the seed) says
## 12 km with bald tires, the story's own clue (on the checklist the first time); the other one says something normal.
## Every number here is (propuesta).

## Where the dashboard sits on the car, in the car's space: by the driver's window, on its left side.
const DASHBOARD_AT := Vector3(-Garage.CAR_SIZE.x / 2 - 0.05, 1.25, 0.3)

## The car that says 12 km (an index of Garage.CARS), its dashboards by car index, and how often the 12 km was read.
var wound_back := -1
var dashboards := {}
var readings := 0


func setup(place: Garage) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["magic odometer", place.case_seed])
	wound_back = [0, 2][rng.randi_range(0, 1)]
	for index: int in [0, 2]:
		var dashboard := GarageDashboard.new()
		dashboard.name = "Dashboard%d" % index
		dashboard.reading = "HINT_ODOMETER_LOW" if index == wound_back else "HINT_ODOMETER"
		dashboard.position = DASHBOARD_AT
		place.cars[index].add_child(dashboard)
		dashboard.read.connect(func(_cop: Cop) -> void: _on_read(index))
		dashboards[index] = dashboard


func _on_read(index: int) -> void:
	if index != wound_back:
		return
	readings += 1
	if readings == 1:
		garage.raid.add_clue(tr("CLUE_ODOMETER"))
