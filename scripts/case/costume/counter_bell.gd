class_name CounterBell
extends StaticBody3D

## The counter bell itself (SizeBell): a gold dome on a dark base that E rings.

signal rang(cop: Cop)


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.24, 0.16, 0.24)
	shape.shape = box
	shape.position.y = 0.08
	add_child(shape)
	var base := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.11
	disc.bottom_radius = 0.12
	disc.height = 0.03
	base.mesh = disc
	base.position.y = 0.015
	base.material_override = _material(Color(0.15, 0.12, 0.1))
	add_child(base)
	var dome := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = SizeBell.RADIUS
	sphere.height = SizeBell.RADIUS
	sphere.is_hemisphere = true
	dome.mesh = sphere
	dome.position.y = 0.03
	dome.material_override = _material(SizeBell.GOLD, 0.8)
	add_child(dome)
	var knob := MeshInstance3D.new()
	var bead := SphereMesh.new()
	bead.radius = 0.02
	bead.height = 0.04
	knob.mesh = bead
	knob.position.y = 0.03 + SizeBell.RADIUS + 0.01
	knob.material_override = dome.material_override
	add_child(knob)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_COSTUME_BELL"


func use(cop: Cop) -> void:
	rang.emit(cop)


func _material(color: Color, metal := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metal
	material.roughness = 0.3 if metal > 0.0 else 0.8
	return material
