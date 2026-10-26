class_name TrialStand
extends StaticBody3D

## The witness stand of the fast trial (docs/diseno/fuga-juicio.md, step 2): a low box with a rail. E on it, the witness
## the judge called takes the stand (TrialJudge.take_stand); on its rail, the three answer signs (TrialSign).

const SIZE := Vector3(1.2, 0.9, 0.7)
const WOOD := Color(0.45, 0.3, 0.18)

## The judge whose witnesses stand here (the level sets her).
var judge: TrialJudge


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = SIZE
	mesh.mesh = cube
	var wood := StandardMaterial3D.new()
	wood.albedo_color = WOOD
	mesh.material_override = wood
	mesh.position.y = SIZE.y / 2
	add_child(mesh)


func prompt_key(cop: Cop) -> String:
	return "PROMPT_TAKE_STAND" if judge and judge.state == "calling" and judge.is_witness(cop) else ""


## Every PC does it; the host decides (the warp reaches the others with the cop).
func use(cop: Cop) -> void:
	if multiplayer.is_server() and prompt_key(cop) != "":
		judge.take_stand(cop)
