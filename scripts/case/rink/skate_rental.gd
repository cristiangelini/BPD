class_name SkateRental
extends StaticBody3D

## The skates on the rental's counter (docs/diseno/allanamiento-pista.md, step 2): E puts a pair on, and again gives
## them back. A row of skates on a mat, its front to +z.

const SIZE := Vector3(1.2, 0.2, 0.5)
const COLORS: Array[Color] = [Color(0.95, 0.95, 0.95), Color(0.15, 0.15, 0.18), Color(0.9, 0.4, 0.6)]

var ice: RinkIce


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var build := PlaceBuilder.new(self)
	build.mesh_box(Vector3(0, 0.01, 0), Vector3(SIZE.x, 0.02, SIZE.z), Color(0.2, 0.2, 0.24))
	for i in 4:
		var x := -0.45 + i * 0.3
		build.mesh_box(Vector3(x, 0.1, -0.02), Vector3(0.12, 0.16, 0.26), COLORS[i % COLORS.size()])
		build.mesh_box(Vector3(x, 0.015, -0.02), Vector3(0.02, 0.03, 0.3), Color(0.8, 0.82, 0.86))


func prompt_key(cop: Cop) -> String:
	return "PROMPT_RINK_SKATES_OFF" if ice and ice.has_skates(cop) else "PROMPT_RINK_SKATES_ON"


func use(cop: Cop) -> void:
	if ice:
		ice.toggle_skates(cop)
