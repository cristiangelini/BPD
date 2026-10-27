class_name CounterPopcorn
extends ClueSpot

## The bowl of popcorn on the cinema's candy counter in the floor popcorn's story (allanamiento-cine.md, "Las palomitas
## del piso"): E eats one, the cop spits it out with a joke over their head every time, and the first time it's a clue.

signal eaten(cop: Cop)


func _ready() -> void:
	size = Vector3(0.36, 0.2, 0.36)
	prompt = "PROMPT_EAT_POPCORN"
	super._ready()
	var bowl := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.16
	cylinder.bottom_radius = 0.11
	cylinder.height = 0.1
	bowl.mesh = cylinder
	bowl.position.y = -0.05
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.8, 0.15, 0.12)
	bowl.material_override = red
	add_child(bowl)
	var corn := StandardMaterial3D.new()
	corn.albedo_color = Color(0.96, 0.9, 0.62)
	var fluff := StandardMaterial3D.new()
	fluff.albedo_color = Color(0.55, 0.55, 0.58)
	for i in 10:
		var bit := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.035
		sphere.height = 0.06
		bit.mesh = sphere
		var turn := i * 2.4
		bit.position = Vector3(cos(turn) * 0.09, 0.01 + (i % 3) * 0.02, sin(turn) * 0.09)
		bit.material_override = fluff if i % 4 == 0 else corn
		add_child(bit)


func use(cop: Cop) -> void:
	super.use(cop)
	eaten.emit(cop)
