class_name HairGrowthRig
extends GroomerRig

## The hair-growth shampoo (peluqueria.md, "El champú crecepelo"): Ramiro brews a shampoo that grows hair on anything
## and sells it in secret. The jug is the main evidence (hidden in a big spot), the formula and a sample jar are
## extras. One of the caged dogs tried it: its fur reaches the floor (the story's own clue). The bathtub drips it: a
## cop who steps in the puddle grows a huge mustache for MUSTACHE seconds that covers the bottom of the view.
## Every number here is (propuesta).

const LONG_HAIR_MODEL := preload("res://assets/models/dog_long_hair.glb")
const MUSTACHE_MODEL := preload("res://assets/models/cop_mustache.glb")
## The caged dog that tried it (a cage with bars and a look-only dog).
const LONG_HAIR_CAGE := Vector2i(0, 1)
## A cop this close to its cage sees it.
const SEES := 2.0
## The puddle in front of the bathtub.
const PUDDLE_AT := Vector3(6.8, Groomer.FLOOR_TOP, 4.15)
const PUDDLE_RADIUS := 0.55
const MUSTACHE := 30.0
## On the cop's head, just under the eyes, so it hides the bottom of the view.
const UNDER_NOSE := Vector3(0, -0.24, -0.34)

var puddle: Area3D
## Seconds of mustache left, by cop.
var mustaches: Dictionary = {}
var _long_hair: Node3D


func setup(place: Groomer) -> void:
	super.setup(place)
	var look: Node3D = place.caged_looks[LONG_HAIR_CAGE]
	look.hide()
	_long_hair = LONG_HAIR_MODEL.instantiate()
	_long_hair.transform = look.transform
	look.get_parent().add_child(_long_hair)
	_make_puddle()


func _make_puddle() -> void:
	puddle = Area3D.new()
	puddle.collision_layer = 0
	puddle.collision_mask = 2
	puddle.position = PUDDLE_AT
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = PUDDLE_RADIUS
	cylinder.height = 0.4
	shape.shape = cylinder
	shape.position.y = 0.2
	puddle.add_child(shape)
	var mesh := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = PUDDLE_RADIUS
	disc.bottom_radius = PUDDLE_RADIUS
	disc.height = 0.01
	var green := StandardMaterial3D.new()
	green.albedo_color = Color(0.45, 0.85, 0.55, 0.6)
	green.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	disc.material = green
	mesh.mesh = disc
	mesh.position.y = 0.006
	puddle.add_child(mesh)
	puddle.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop:
			grow(body as Cop))
	groomer.add_child(puddle)


## The shampoo hits a cop: a huge mustache for MUSTACHE seconds (stepping in again restarts it).
func grow(cop: Cop) -> void:
	if not mustaches.has(cop):
		var mustache: Node3D = MUSTACHE_MODEL.instantiate()
		mustache.name = "Mustache"
		mustache.position = UNDER_NOSE
		mustache.rotation.y = PI
		cop.get_node("Head").add_child(mustache)
		cop.show_hint("HINT_MUSTACHE")
	mustaches[cop] = MUSTACHE


func _physics_process(delta: float) -> void:
	for cop: Cop in mustaches.keys():
		mustaches[cop] -= delta
		if mustaches[cop] <= 0.0:
			mustaches.erase(cop)
			var mustache := cop.get_node_or_null("Head/Mustache")
			if mustache:
				mustache.queue_free()
	var cage := _long_hair.global_position
	for cop in get_tree().get_nodes_in_group("cops"):
		var at := (cop as Node3D).global_position
		if Vector2(at.x - cage.x, at.z - cage.z).length() < SEES:
			groomer.raid.add_clue(tr("CLUE_HAIR_GROWTH_DOG"))
			break
