class_name ReviewsRig
extends HotelRig

## The fake reviews (hotel-allanamiento.md, "Las reseñas falsas"): don Bostezo writes hundreds of glowing reviews of
## the Gran Siesta on a typewriter and mails them as postcards from "happy guests". The typewriter is the main evidence,
## hidden like the extras (the bundle of postcards and the postmark stamp). The story's own clue: carbon paper in the
## lobby's bin with "5 estrellas" backwards. And he writes in his sleep: while he naps, a cop within HEARS hears
## "tac tac tac" from wherever the typewriter is. Every number here is (propuesta).

const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## The lobby's bin, by the reception desk, with the carbon paper on top.
const BIN_AT := Vector3(Hotel.DESK_AT.x + Hotel.DESK_SIZE.x / 2 + 0.5, Hotel.FLOOR_TOP, Hotel.DESK_AT.z + 0.4)
const BIN_RADIUS := 0.18
const BIN_HEIGHT := 0.4
const HEARS := 6.0
const BIN := Color(0.3, 0.32, 0.35)

var bin_paper: ClueNote
var tac_heard := false
var _tac: Label3D


func setup(place: HotelRaid) -> void:
	super.setup(place)
	place.add_child(_bin())
	bin_paper = NOTE_SCENE.instantiate()
	bin_paper.prompt = "PROMPT_CARBON_PAPER"
	bin_paper.text = tr("CLUE_REVIEWS_CARBON")
	bin_paper.position = BIN_AT + Vector3(0, BIN_HEIGHT + 0.02, 0)
	bin_paper.read.connect(place.raid.add_clue)
	place.add_child(bin_paper)
	_tac = Label3D.new()
	_tac.name = "Tac"
	_tac.text = "REVIEWS_TAC"
	_tac.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_tac.no_depth_test = true
	_tac.pixel_size = 0.004
	_tac.outline_size = 8
	_tac.font_size = 40
	_tac.visible = false
	place.add_child(_tac)


## True while don Bostezo naps and the typewriter waits where it was hidden: it types by itself.
func typing() -> bool:
	return hotel_raid.concierge.is_asleep() and not hotel_raid.main.is_held()


func _physics_process(_delta: float) -> void:
	var heard := false
	if typing():
		var at := hotel_raid.main.global_position
		for node in get_tree().get_nodes_in_group("cops"):
			if (node as Cop).global_position.distance_to(at) < HEARS:
				heard = true
		_tac.position = at + Vector3.UP * 0.5
	_tac.visible = heard
	if heard and not tac_heard:
		tac_heard = true
		hotel_raid.raid.add_clue(tr("CLUE_REVIEWS_TAC"))


func _bin() -> StaticBody3D:
	var bin := StaticBody3D.new()
	bin.name = "Bin"
	bin.position = BIN_AT
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = BIN_RADIUS
	cylinder.height = BIN_HEIGHT
	shape.shape = cylinder
	shape.position.y = BIN_HEIGHT / 2
	bin.add_child(shape)
	var look := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = BIN_RADIUS
	mesh.bottom_radius = BIN_RADIUS * 0.8
	mesh.height = BIN_HEIGHT
	look.mesh = mesh
	look.position.y = BIN_HEIGHT / 2
	var material := StandardMaterial3D.new()
	material.albedo_color = BIN
	look.material_override = material
	bin.add_child(look)
	return bin
