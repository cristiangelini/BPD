class_name GoldGnomeRig
extends NurseryRig

## The golden gnome (allanamiento-vivero.md, "El enano de oro"): Doña Hortensia took the mayor's solid gold garden
## gnome. One gnome in the row by the front has fresh paint: a cop this close to it makes it peel, and gold shows
## under the blue, the story's own clue (on the checklist the first time). And the row of gnomes turns to look toward
## the golden one, wherever it is. Every number here is (propuesta).

const PEEL_RANGE := 1.5
const CHECK_EVERY := 0.5
const GOLD := Color(0.95, 0.78, 0.29)
## Where the gold shows through on the painted gnome (its own space).
const FLAKES: Array[Vector3] = [Vector3(0.1, 0.15, 0.08), Vector3(-0.09, 0.2, 0.07), Vector3(0.02, 0.1, 0.12)]

## The gnome of the row with fresh paint, and whether it peeled already.
var painted := 0
var peeled := false
var _since := 0.0


func setup(place: Nursery) -> void:
	super.setup(place)
	painted = nursery.case_seed % nursery.gnomes.size()
	_turn_gnomes()


func _physics_process(delta: float) -> void:
	_since += delta
	if _since < CHECK_EVERY:
		return
	_since = 0.0
	_turn_gnomes()
	if peeled:
		return
	var gnome := nursery.gnomes[painted]
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var off := cop.global_position - gnome.global_position
		off.y = 0.0
		if off.length() <= PEEL_RANGE:
			peel()
			break


## The fresh paint peels off the gnome and gold shows: the first time it's a clue.
func peel() -> void:
	if peeled:
		return
	peeled = true
	var gnome := nursery.gnomes[painted]
	var paint := StandardMaterial3D.new()
	paint.albedo_color = GOLD
	paint.metallic = 0.8
	paint.roughness = 0.25
	paint.emission_enabled = true
	paint.emission = GOLD * 0.5
	for i in FLAKES.size():
		var flake := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.1, 0.08, 0.03)
		flake.mesh = box
		flake.material_override = paint
		flake.position = FLAKES[i]
		flake.name = "Flake%d" % i
		gnome.add_child(flake)
	nursery.raid.add_clue(tr("CLUE_FRESH_PAINT"))
	nursery.raid.float_label(tr("NURSERY_GOLD_SHOWS"), gnome.global_position + Vector3.UP * 0.9, GOLD)


## Every gnome of the row turns to look at the golden one.
func _turn_gnomes() -> void:
	var target := nursery.to_local(nursery.main.global_position)
	for gnome in nursery.gnomes:
		var to := target - gnome.position
		to.y = 0.0
		if to.length() > 0.1:
			gnome.rotation.y = atan2(to.x, to.z)
