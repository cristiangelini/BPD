class_name ComisarioTaxiRig
extends GarageRig

## The comisario's car (allanamiento-taller.md, "El auto del comisario"): the comisario left his own car at Don Tuerca's
## for a service, and Don Tuerca uses it as a taxi at night. The taxi sign they put on its roof is hidden with the
## taximeter and the trips notebook; one of the two cars on the floor (drawn with the seed) is the comisario's, with its
## "best comisario of the year" sticker, and its dashboard says 1500 km more than when he left it: the first time a cop
## reads it is the story's own clue. The other car's dashboard says something normal. Every number here is (propuesta).

## The sticker on the rear door, in the car's space, facing -x like the dashboard.
const STICKER_AT := Vector3(-Garage.CAR_SIZE.x / 2 - 0.07, 0.62, -0.55)
const STICKER_COLOR := Color(0.15, 0.25, 0.6)

## The comisario's car (an index of Garage.CARS), the dashboards by car index and how often his was read.
var comisario_car := -1
var dashboards := {}
var readings := 0


func setup(place: Garage) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["comisario taxi", place.case_seed])
	comisario_car = [0, 2][rng.randi_range(0, 1)]
	for index: int in [0, 2]:
		var dashboard := GarageDashboard.new()
		dashboard.name = "Dashboard%d" % index
		dashboard.reading = "HINT_COMISARIO_KM" if index == comisario_car else "HINT_ODOMETER"
		dashboard.position = MagicOdometerRig.DASHBOARD_AT
		place.cars[index].add_child(dashboard)
		dashboard.read.connect(func(_cop: Cop) -> void: _on_read(index))
		dashboards[index] = dashboard
	var sticker := Label3D.new()
	sticker.name = "Sticker"
	sticker.text = tr("GARAGE_COMISARIO_STICKER")
	sticker.position = STICKER_AT
	sticker.rotation.y = -PI / 2
	sticker.pixel_size = 0.0025
	sticker.modulate = STICKER_COLOR
	sticker.outline_modulate = Color.WHITE
	sticker.outline_size = 12
	sticker.width = 260.0
	sticker.autowrap_mode = TextServer.AUTOWRAP_WORD
	place.cars[comisario_car].add_child(sticker)


func _on_read(index: int) -> void:
	if index != comisario_car:
		return
	readings += 1
	if readings == 1:
		garage.raid.add_clue(tr("CLUE_COMISARIO_KM"))
