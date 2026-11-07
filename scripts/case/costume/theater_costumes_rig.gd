class_name TheaterCostumesRig
extends CostumeRig

## The theater's costumes (allanamiento-disfraces.md, "Los trajes del teatro"): Don Fantoche rents out the costumes
## stolen from the Mime Theater. The theater's trunk (15 kg, the main evidence), its stamp and the play's program are
## hidden. One costume on the jobs rack still has the theater's tag (a ClueSpot, the story's clue), and on the east
## wall hangs the theater's poster: "Show cancelled: our costumes were stolen". Every number here is (propuesta).

const POSTER_MODEL := preload("res://assets/models/theater_poster.glb")
## The tagged costume, on the jobs rack (RACKS[4]), and the poster on the east wall, facing the shop.
const TAG_AT := Vector3(-1.18, CostumeShop.FLOOR_TOP + 1.1, 2.5)
const TAG_SIZE := Vector3(0.14, 0.9, 0.5)
const POSTER_AT := Vector3(CostumeShop.HALF_X - PlaceBuilder.WALL / 2 - 0.01, 1.9, 4.4)

var tag: ClueSpot


func setup(place: CostumeShop) -> void:
	super.setup(place)
	tag = ClueSpot.new()
	tag.size = TAG_SIZE
	tag.prompt = "PROMPT_COSTUME_TAG"
	tag.text = tr("CLUE_THEATER_TAG")
	tag.position = TAG_AT
	tag.read.connect(place.raid.add_clue)
	place.add_child(tag)
	var label := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.13, 0.06, 0.04)
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.97, 0.96, 0.92)
	box.material = white
	label.mesh = box
	label.position = Vector3(0, 0.35, 0.26)
	tag.add_child(label)
	var poster: Node3D = POSTER_MODEL.instantiate()
	poster.position = POSTER_AT
	poster.rotation.y = PI
	place.add_child(poster)
	var words := Label3D.new()
	words.text = "THEATER_POSTER"
	words.font_size = 22
	words.pixel_size = 0.004
	words.outline_size = 0
	words.modulate = Color(0.15, 0.1, 0.2)
	words.width = 180.0
	words.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.double_sided = false
	words.position = POSTER_AT + Vector3(-0.02, -0.33, 0)
	words.rotation.y = -PI / 2
	place.add_child(words)
