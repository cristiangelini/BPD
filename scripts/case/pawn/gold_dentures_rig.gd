class_name GoldDenturesRig
extends PawnRig

## The gold dentures (allanamiento-empenos.md, "Las dentaduras de oro"): the dentist's box of gold dentures (8 kg, the
## main evidence) is hidden in the shop with his pliers and his patient list. Chicharra smiles with a gold tooth, and
## fed a cookie he says "Open wide!": that's the story's clue. A customer tells how Don Regateo paid far too much for
## grandpa's dentures. Every number here is (propuesta).

## Under the parrot's beak (his space).
const TOOTH_AT := Vector3(0, -0.445, 0.08)
const GOLD := Color(0.95, 0.75, 0.2)

var tooth: MeshInstance3D


func setup(place: PawnShop) -> void:
	super.setup(place)
	tooth = MeshInstance3D.new()
	tooth.name = "GoldTooth"
	var box := BoxMesh.new()
	box.size = Vector3(0.028, 0.03, 0.014)
	tooth.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = GOLD
	material.metallic = 0.6
	material.roughness = 0.3
	material.emission_enabled = true
	material.emission = GOLD * 0.6
	tooth.material_override = material
	tooth.position = TOOTH_AT
	place.parrot.add_child(tooth)
	place.parrot.fed.connect(func(_cop: Cop) -> void: place.raid.add_clue(tr("CLUE_GOLD_DENTURES")))
	var customer := place.customers[1]
	customer.rumor = "PAWN_RUMOR_GOLD_DENTURES"
	customer.rumored.connect(place.raid.add_clue)
