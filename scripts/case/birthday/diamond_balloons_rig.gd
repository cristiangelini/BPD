class_name DiamondBalloonsRig
extends BirthdayRaidRig

## The diamond balloons (allanamiento-cumple.md, "Los globos de diamantes"): Chispita smuggles stones inside balloons
## that leave every party tied to a kid's wrist. The bunch full of diamonds is hidden. One balloon across the top of the
## entrance's arch (drawn with the seed) hangs down on its string instead of floating, the story's own clue: popping it drops a real diamond, on the
## checklist the first time. Half of the other arch balloons (drawn with the seed) drop glass pebbles when they pop, a
## false lead. Every number here is (propuesta).

const DROOP := 0.5
const PEBBLES := 5
const PEBBLE_LIFE := 10.0
const GLASS := Color(0.75, 0.95, 1.0, 0.7)
const DIAMOND := Color(0.85, 0.97, 1.0)

## The arch balloon with the diamond in it, and the ones with glass pebbles.
var heavy := -1
var pebbles: Array[int] = []
var diamonds := 0


func setup(place: BirthdayRaid) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["diamond balloons", place.case_seed])
	heavy = rng.randi_range(BirthdayRaid.SIDE_BALLOONS * 2, place.balloons.size() - 1)
	for i in place.balloons.size():
		if i != heavy and rng.randf() < 0.5:
			pebbles.append(i)
	# The heavy one hangs under its place on a string, a little darker.
	var look := place.balloons[heavy].get_child(1) as MeshInstance3D
	look.position.y -= DROOP
	(look.material_override as StandardMaterial3D).albedo_color = \
		(look.material_override as StandardMaterial3D).albedo_color.darkened(0.25)
	var string := MeshInstance3D.new()
	var thread := CylinderMesh.new()
	thread.top_radius = 0.004
	thread.bottom_radius = 0.004
	thread.height = DROOP
	string.mesh = thread
	string.position.y = -DROOP / 2 + BirthdayRaid.BALLOON_RADIUS / 2
	place.balloons[heavy].add_child(string)
	place.balloon_popped.connect(popped)


## Arch balloon `index` just popped.
func popped(index: int) -> void:
	var at := party.balloons[index].global_position
	if index == heavy:
		diamonds += 1
		_spill(at + Vector3.DOWN * DROOP, 1, DIAMOND, 0.07, -1.0)
		party.balloons[index].get_child(2).visible = false
		party.raid.float_label("✦ clinc ✦", at + Vector3.UP * 0.5, DIAMOND)
		party.raid.add_clue(tr("CLUE_DIAMOND_BALLOON"))
	elif pebbles.has(index):
		_spill(at, PEBBLES, GLASS, 0.025, PEBBLE_LIFE)
		party.raid.float_label(tr("BIRTHDAY_GLASS_PEBBLES"), at + Vector3.UP * 0.5, GLASS)


## Little stones falling from where the balloon was; they fade after `life` seconds (never if negative).
func _spill(at: Vector3, count: int, color: Color, size: float, life: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([party.case_seed, at])
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.4
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for i in count:
		var stone := RigidBody3D.new()
		stone.collision_layer = 0
		stone.collision_mask = 1
		stone.mass = 0.01
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3.ONE * size
		shape.shape = box
		stone.add_child(shape)
		var look := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = size / 2
		mesh.height = size
		mesh.radial_segments = 6
		mesh.rings = 3
		mesh.material = material
		look.mesh = mesh
		stone.add_child(look)
		party.add_child(stone)
		stone.global_position = at
		stone.linear_velocity = Vector3(rng.randf_range(-0.8, 0.8), 0.5, rng.randf_range(-0.8, 0.8))
		if life > 0.0:
			get_tree().create_timer(life).timeout.connect(stone.queue_free)
