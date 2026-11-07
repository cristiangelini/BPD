class_name StreetRaceRig
extends GarageRig

## The street race (allanamiento-taller.md, "La carrera clandestina"): at night Don Tuerca's garage is the start of a
## street race, and the clients' cars come back with their tires worn out. The race trophy is hidden with the nitro tank
## and the race map; the floor in front of the cars has a circle of rubber marks (two tires' worth, round and round), and
## the first cop who walks into it adds the story's own clue to the checklist. Every number here is (propuesta).

signal marks_seen(cop: Cop)

## The circle's middle on the floor, between the shutter and the cars, its radius and how many marks it has.
const CENTER := Vector3(3.0, Garage.FLOOR_TOP, 6.0)
const RADIUS := 1.8
const MARKS := 28
const TRACK := 0.22
const MARK_SIZE := Vector3(0.16, 0.004, 0.38)
const RUBBER := Color(0.08, 0.08, 0.09)

var seen := false


func setup(place: Garage) -> void:
	super.setup(place)
	var marks := Node3D.new()
	marks.name = "RubberMarks"
	marks.position = CENTER
	place.add_child(marks)
	var mesh := BoxMesh.new()
	mesh.size = MARK_SIZE
	var material := StandardMaterial3D.new()
	material.albedo_color = RUBBER
	material.roughness = 1.0
	mesh.material = material
	for i in MARKS:
		var angle := TAU * i / MARKS
		for radius: float in [RADIUS - TRACK, RADIUS + TRACK]:
			var mark := MeshInstance3D.new()
			mark.mesh = mesh
			mark.position = Vector3(cos(angle), 0, sin(angle)) * radius + Vector3.UP * (MARK_SIZE.y / 2 + 0.002)
			mark.rotation.y = -angle
			mark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			marks.add_child(mark)
	var area := Area3D.new()
	area.name = "MarksArea"
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = RADIUS + TRACK
	cylinder.height = 2.0
	shape.shape = cylinder
	shape.position.y = 1.0
	area.add_child(shape)
	marks.add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop:
			see(body))


## `cop` walked into the circle: the first time anyone does, a hint and the clue.
func see(cop: Cop) -> void:
	if seen:
		return
	seen = true
	cop.show_hint("HINT_RUBBER_MARKS")
	garage.raid.add_clue(tr("CLUE_RUBBER_MARKS"))
	marks_seen.emit(cop)
